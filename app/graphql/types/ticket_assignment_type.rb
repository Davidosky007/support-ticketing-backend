# frozen_string_literal: true

module Types
  class TicketAssignmentType < Types::BaseObject
    field :id, ID, null: false
    field :ticket, Types::TicketType, null: false
    field :agent, Types::UserType, null: false
    field :assigned_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Simple direct resolvers
    def ticket
      object.ticket
    end
    
    def agent
      object.agent
    end
  end
end