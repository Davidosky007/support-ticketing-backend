require 'rails_helper'

RSpec.describe Mutations::CreateTicket, type: :request do
  let(:customer) { create(:user, :customer) }
  let(:token) { generate_token_for(customer) }
  
  let(:query) do
    <<~GQL
      mutation($subject: String!, $description: String!) {
        createTicket(input: {
          subject: $subject
          description: $description
        }) {
          ticket {
            id
            subject
            status
          }
          errors
        }
      }
    GQL
  end
  
  context 'when user is authenticated' do
    it 'creates a new ticket' do
      post '/graphql', 
        params: {
          query: query,
          variables: { subject: "Test Ticket", description: "This is a test" }
        },
        headers: { 'Authorization' => "Bearer #{token}" }
      
      json = JSON.parse(response.body)
      data = json['data']['createTicket']
      
      expect(data['ticket']).to be_present
      expect(data['ticket']['subject']).to eq('Test Ticket')
      expect(data['ticket']['status']).to eq('OPEN')
      expect(data['errors']).to be_empty
    end
  end
  
  context 'when user is not authenticated' do
    it 'returns an error' do
      post '/graphql', 
        params: {
          query: query,
          variables: { subject: "Test Ticket", description: "This is a test" }
        }
      
      json = JSON.parse(response.body)
      errors = json['errors']
      
      expect(errors).to be_present
      expect(errors.first['message']).to include('authenticated')
    end
  end
  
  def generate_token_for(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end