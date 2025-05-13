require 'rails_helper'

RSpec.describe Mutations::Register, type: :request do
  let(:query) do
    <<~GQL
      mutation($name: String!, $email: String!, $password: String!, $role: String!) {
        register(input: {
          name: $name
          email: $email
          password: $password
          role: $role
        }) {
          user {
            id
            name
            email
            role
          }
          token
          errors
        }
      }
    GQL
  end
  
  context 'with valid attributes' do
    it 'creates a new customer user' do
      variables = {
        name: 'New Customer',
        email: 'newcustomer@example.com',
        password: 'password123',
        role: 'customer'
      }
      
      expect {
        post '/graphql', params: { query: query, variables: variables }
      }.to change(User, :count).by(1)
      
      json = JSON.parse(response.body)
      data = json['data']['register']
      
      expect(data['token']).to be_present
      expect(data['user']['name']).to eq('New Customer')
      expect(data['user']['email']).to eq('newcustomer@example.com')
      expect(data['user']['role']).to eq('CUSTOMER')
      expect(data['errors']).to be_empty
    end
  end
  
  context 'with invalid attributes' do
    it 'returns errors when email is taken' do
      create(:user, email: 'taken@example.com')
      
      variables = {
        name: 'New User',
        email: 'taken@example.com',
        password: 'password123',
        role: 'customer'
      }
      
      post '/graphql', params: { query: query, variables: variables }
      
      json = JSON.parse(response.body)
      data = json['data']['register']
      
      expect(data['user']).to be_nil
      expect(data['token']).to be_nil
      expect(data['errors']).to include(/email has already been taken/i)
    end
  end
end