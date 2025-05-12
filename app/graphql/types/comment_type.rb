# frozen_string_literal: true

module Types
  class CommentType < Types::BaseObject
    field :id, ID, null: false
    field :content, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Replace IDs with object references
    field :user, Types::UserType, null: false
    field :ticket, Types::TicketType, null: false
    
    # Simple direct resolvers
    def user
      object.user
    end
    
    def ticket
      object.ticket
    end
  end
end
