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
    field :ticket_assignments, [Types::TicketAssignmentType], null: true
    
    # Simple direct resolvers
    def comments
      object.comments
    end
    
    def customer
      object.user
    end
    
    def agent
      object.agent
    end
    
    def attachments
      object.attachments
    end
    
    def ticket_assignments
      object.ticket_assignments
    end
    
    # Helper method to get status as a string
    def status
      object.status.to_s
    end
  end
end
