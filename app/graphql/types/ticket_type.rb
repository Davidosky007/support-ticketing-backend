# frozen_string_literal: true

module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :subject, String
    field :description, String
    field :status, String # Changed from Integer to String for better client usage
    field :agent_commented, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Replace IDs with object references
    field :customer, Types::UserType, null: false
    field :agent, Types::UserType, null: true
    field :comments, [Types::CommentType], null: true
    field :attachments, [Types::AttachmentType], null: true
    
    # Add resolver methods for efficiency
    def comments
      Loaders::AssociationLoader.for(Ticket, :comments).load(object)
    end
    
    def customer
      Loaders::RecordLoader.for(User).load(object.customer_id)
    end
    
    def agent
      return nil unless object.agent_id
      Loaders::RecordLoader.for(User).load(object.agent_id)
    end
    
    # Helper method to get status as a string
    def status
      object.status.to_s
    end
  end
end
