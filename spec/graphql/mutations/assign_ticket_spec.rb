require 'rails_helper'

RSpec.describe Mutations::AssignTicket, type: :request do
  let(:agent) { create(:user, :agent) }
  let(:customer) { create(:user, :customer) }
  let(:ticket) { create(:ticket, user: customer) }
  
  let(:query) do
    <<~GQL
      mutation($ticketId: ID!) {
        assignTicket(input: {
          ticketId: $ticketId
        }) {
          ticket {
            id
            subject
            status
            agent {
              id
              name
              email
            }
          }
          errors
        }
      }
    GQL
  end
  
  context 'when agent assigns ticket to themselves' do
    it 'assigns the ticket to the agent' do
      token = generate_token_for(agent)
      
      variables = { ticketId: ticket.id.to_s }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
          
        ticket.reload
      }.to change(ticket, :agent_id).from(nil).to(agent.id)
      
      json = JSON.parse(response.body)
      data = json['data']['assignTicket']
      
      expect(data['ticket']).to be_present
      expect(data['ticket']['agent']['id'].to_i).to eq(agent.id)
      expect(data['errors']).to be_empty
    end
  end
  
  context 'when customer tries to assign a ticket' do
    it 'returns an authorization error' do
      token = generate_token_for(customer)
      
      variables = { ticketId: ticket.id.to_s }
      
      expect {
        post '/graphql', 
          params: { query: query, variables: variables },
          headers: { 'Authorization' => "Bearer #{token}" }
          
        ticket.reload
      }.not_to change(ticket, :agent_id)
      
      json = JSON.parse(response.body)
      
      expect(json['errors']).to be_present
      expect(json['errors'].first['message']).to include('Only agents can')
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