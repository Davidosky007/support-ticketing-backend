require 'rails_helper'

RSpec.describe Mutations::GenerateTicketsCsv, type: :request do
  let(:agent) { create(:user, :agent) }
  let(:customer) { create(:user, :customer) }
  
  # Create some closed tickets
  before do
    travel_to 15.days.ago do
      3.times do
        create(:ticket, :closed, user: customer, agent: agent)
      end
    end
  end
  
  let(:query) do
    <<~GQL
      mutation($status: String, $startDate: ISO8601DateTime, $endDate: ISO8601DateTime) {
        generateTicketsCsv(input: {
          status: $status
          startDate: $startDate
          endDate: $endDate
        }) {
          url
          errors
        }
      }
    GQL
  end
  
  context 'when agent requests CSV export' do
    it 'generates a CSV of closed tickets' do
      token = generate_token_for(agent)
      
      variables = {
        status: "closed",
        startDate: 30.days.ago.iso8601,
        endDate: Time.current.iso8601
      }
      
      post '/graphql', 
        params: { query: query, variables: variables },
        headers: { 'Authorization' => "Bearer #{token}" }
      
      json = JSON.parse(response.body)
      data = json['data']['generateTicketsCsv']
      
      expect(data['url']).to be_present
      expect(data['url']).to include('.csv')
      expect(data['errors']).to be_empty
    end
  end
  
  context 'when customer tries to export CSV' do
    it 'returns an authorization error' do
      token = generate_token_for(customer)
      
      variables = {
        status: "closed",
        startDate: 30.days.ago.iso8601,
        endDate: Time.current.iso8601
      }
      
      post '/graphql', 
        params: { query: query, variables: variables },
        headers: { 'Authorization' => "Bearer #{token}" }
      
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