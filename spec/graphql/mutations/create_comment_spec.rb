require 'rails_helper'

RSpec.describe Mutations::CreateComment, type: :request do
  let(:agent) { create(:user, :agent) }
  let(:customer) { create(:user, :customer) }
  let(:ticket) { create(:ticket, user: customer, agent: agent) }
  
  let(:query) do
    <<~GQL
      mutation($ticketId: ID!, $content: String!) {
        createComment(input: {
          ticketId: $ticketId
          content: $content
        }) {
          comment {
            id
            content
            user {
              id
              name
              role
            }
          }
          errors
        }
      }
    GQL
  end
  
  context 'when agent comments first' do
    it 'creates a comment and marks the ticket as agent commented' do
      token = generate_token_for(agent)
      
      variables = {
        ticketId: ticket.id.to_s,
        content: "This is an agent comment"
      }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
      }.to change(Comment, :count).by(1)
      
      json = JSON.parse(response.body)
      data = json['data']['createComment']
      
      expect(data['comment']).to be_present
      expect(data['comment']['content']).to eq('This is an agent comment')
      expect(data['comment']['user']['role']).to eq('AGENT')
      expect(data['errors']).to be_empty
      
      # Check that the ticket is marked as agent commented
      ticket.reload
      expect(ticket.agent_commented).to be true
    end
  end
  
  context 'when customer tries to comment before agent' do
    it 'returns an error' do
      token = generate_token_for(customer)
      ticket_without_agent_comment = create(:ticket, user: customer, agent: agent, agent_commented: false)
      
      variables = {
        ticketId: ticket_without_agent_comment.id.to_s,
        content: "This is a customer comment"
      }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
      }.not_to change(Comment, :count)
      
      json = JSON.parse(response.body)
      data = json['data']['createComment']
      
      expect(data['comment']).to be_nil
      expect(data['errors']).to include(/agent must comment first/i)
    end
  end
  
  context 'when customer comments after agent' do
    it 'allows customer to comment' do
      # First have the agent comment
      ticket.update(agent_commented: true)
      
      token = generate_token_for(customer)
      
      variables = {
        ticketId: ticket.id.to_s,
        content: "This is a customer response"
      }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
      }.to change(Comment, :count).by(1)
      
      json = JSON.parse(response.body)
      data = json['data']['createComment']
      
      expect(data['comment']).to be_present
      expect(data['comment']['content']).to eq('This is a customer response')
      expect(data['comment']['user']['role']).to eq('CUSTOMER')
      expect(data['errors']).to be_empty
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