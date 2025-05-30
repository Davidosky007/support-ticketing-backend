# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :email, String
    field :role, String, null: false # Changed from Integer to String for better client usage
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Add relationships
    field :tickets, [Types::TicketType], null: true
    field :assigned_tickets, [Types::TicketType], null: true
    field :comments, [Types::CommentType], null: true
    field :ticket_assignments, [Types::TicketAssignmentType], null: true

    # Simple direct resolvers
    def tickets
      object.tickets
    end

    def assigned_tickets
      object.assigned_tickets
    end

    def comments
      object.comments
    end

    def ticket_assignments
      object.ticket_assignments
    end

    # Helper method to get role as a string
    def role
      object.role.upcase
    end
  end
end
