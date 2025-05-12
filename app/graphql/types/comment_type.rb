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
    
    def user
      Loaders::RecordLoader.for(User).load(object.user_id)
    end
    
    def ticket
      Loaders::RecordLoader.for(Ticket).load(object.ticket_id)
    end
  end
end
