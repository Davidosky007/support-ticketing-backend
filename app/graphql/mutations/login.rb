# frozen_string_literal: true

module Mutations
  class Login < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email)
      
      # Check if user exists and password is correct
      if user&.authenticate(password)
        # Generate token
        token = generate_token(user)
        
        {
          token: token,
          user: user,
          errors: []
        }
      else
        {
          token: nil,
          user: nil,
          errors: ["Invalid email or password"]
        }
      end
    end

    private

    def generate_token(user)
      payload = {
        user_id: user.id,
        exp: 24.hours.from_now.to_i
      }
      
      JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end
  end
end