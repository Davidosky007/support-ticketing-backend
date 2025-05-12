module Mutations
  class Register < BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true

    field :user, Types::UserType, null: true
    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(name:, email:, password:, role:)
      # Convert role from string to enum value
      role_value = User.roles[role.downcase]
      
      unless role_value
        return {
          user: nil,
          token: nil,
          errors: ["Invalid role. Must be 'customer' or 'agent'"]
        }
      end

      user = User.new(
        name: name,
        email: email,
        password: password,
        role: role_value
      )

      if user.save
        # Generate token for the new user
        token = generate_token(user)
        
        {
          user: user,
          token: token,
          errors: []
        }
      else
        {
          user: nil,
          token: nil,
          errors: user.errors.full_messages
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