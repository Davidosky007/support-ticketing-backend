# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :email, String
    field :role, String # Changed from Integer to String for better client usage
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Add relationships
    field :tickets, [Types::TicketType], null: true
    field :assigned_tickets, [Types::TicketType], null: true
    field :comments, [Types::CommentType], null: true

    # Add resolver methods for efficiency
    def tickets
      Loaders::AssociationLoader.for(User, :tickets).load(object)
    end

    def assigned_tickets
      Loaders::AssociationLoader.for(User, :assigned_tickets).load(object)
    end

    def comments
      Loaders::AssociationLoader.for(User, :comments).load(object)
    end

    # Helper method to get role as a string
    def role
      object.role.to_s
    end
  end
end
