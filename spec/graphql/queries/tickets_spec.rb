require 'rails_helper'

RSpec.describe 'Tickets Query', type: :request do
  let(:agent) { create(:user, :agent) }
  let(:customer) { create(:user, :customer) }
  let!(:agent_ticket) { create(:ticket, :with_agent, agent: agent) }
  let!(:customer_ticket) { create(:ticket, user: customer) }
  
  let(:query) do
    <<~GQL
      query {
        tickets {
          id
          subject
          status
          customer {
            id
            name
          }
          agent {
            id
            name
          }
        }
      }
    GQL
  end
  
  context 'when user is an agent' do
    before do
      token = generate_token_for(agent)
      post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
    end
    
    it 'returns all tickets' do
      json = JSON.parse(response.body)
      tickets = json['data']['tickets']
      
      expect(tickets.size).to eq(2)
      ticket_ids = tickets.map { |t| t['id'].to_i }
      expect(ticket_ids).to include(agent_ticket.id, customer_ticket.id)
    end
  end
  
  context 'when user is a customer' do
    before do
      token = generate_token_for(customer)
      post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
    end
    
    it 'returns only the customer tickets' do
      json = JSON.parse(response.body)
      tickets = json['data']['tickets']
      
      expect(tickets.size).to eq(1)
      expect(tickets.first['id'].to_i).to eq(customer_ticket.id)
    end
  end
  
  context 'when user is not authenticated' do
    before do
      post '/graphql', params: { query: query }
    end
    
    it 'returns an authentication error' do
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
      expect(json['errors'].first['message']).to include('authenticated')
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