require 'rails_helper'

RSpec.describe Mutations::Login, type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123', role: :customer) }
  let(:query) do
    <<~GQL
      mutation($email: String!, $password: String!) {
        login(input: {
          email: $email
          password: $password
        }) {
          token
          user {
            id
            email
            role
          }
          errors
        }
      }
    GQL
  end

  before do
    # Ensure user exists
    user
  end

  context 'with valid credentials' do
    it 'returns a token and user' do
      post '/graphql', params: {
        query: query,
        variables: { email: 'test@example.com', password: 'password123' }
      }

      json = JSON.parse(response.body)
      data = json['data']['login']

      expect(data['token']).to be_present
      expect(data['user']).to be_present
      expect(data['user']['email']).to eq('test@example.com')
      expect(data['errors']).to be_empty
    end
  end

  context 'with invalid credentials' do
    it 'returns errors and no token' do
      post '/graphql', params: {
        query: query,
        variables: { email: 'test@example.com', password: 'wrongpassword' }
      }

      json = JSON.parse(response.body)
      data = json['data']['login']

      expect(data['token']).to be_nil
      expect(data['user']).to be_nil
      expect(data['errors']).not_to be_empty
      expect(data['errors'].first).to eq('Invalid email or password')
    end
  end
end