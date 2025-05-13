require 'rails_helper'

RSpec.describe Mutations::UploadAttachment, type: :request do
  let(:customer) { create(:user, :customer) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, user: customer, agent: agent) }
  
  let(:query) do
    <<~GQL
      mutation($ticketId: ID!, $file: String!, $filename: String!, $contentType: String!) {
        uploadAttachment(input: {
          ticketId: $ticketId
          file: $file
          filename: $filename
          contentType: $contentType
        }) {
          success
          attachment {
            id
            filename
            contentType
            url
          }
          errors
        }
      }
    GQL
  end
  
  context 'when customer uploads a file to their ticket' do
    it 'successfully attaches the file' do
      token = generate_token_for(customer)
      
      # Create a base64 encoded test file
      file_content = "This is a test file"
      base64_content = Base64.strict_encode64(file_content)
      
      variables = {
        ticketId: ticket.id.to_s,
        file: base64_content,
        filename: "test.txt",
        contentType: "text/plain"
      }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
          
        ticket.reload
      }.to change { ActiveStorage::Attachment.count }.by(1)
      
      json = JSON.parse(response.body)
      data = json['data']['uploadAttachment']
      
      expect(data['success']).to be true
      expect(data['attachment']).to be_present
      expect(data['attachment']['filename']).to eq('test.txt')
      expect(data['attachment']['contentType']).to eq('text/plain')
      expect(data['errors']).to be_empty
    end
  end
  
  context 'when unauthorized user tries to upload' do
    it 'returns an error' do
      other_customer = create(:user, :customer)
      token = generate_token_for(other_customer)
      
      file_content = "This is a test file"
      base64_content = Base64.strict_encode64(file_content)
      
      variables = {
        ticketId: ticket.id.to_s,
        file: base64_content,
        filename: "test.txt",
        contentType: "text/plain"
      }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
      }.not_to change { ActiveStorage::Attachment.count }
      
      json = JSON.parse(response.body)
      data = json['data']['uploadAttachment']
      
      expect(data['success']).to be false
      expect(data['attachment']).to be_nil
      expect(data['errors']).to include(/don't have permission/)
    end
  end
  
  private
  
  def generate_token_for(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end