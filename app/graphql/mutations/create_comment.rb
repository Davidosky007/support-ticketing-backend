# frozen_string_literal: true

module Mutations
  class CreateComment < Mutations::BaseMutation
    argument :ticket_id, ID, required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [String], null: false

    def resolve(ticket_id:, content:)
      # Get current user from context
      user = context[:current_user]
      
      # Ensure user is authenticated
      unless user
        return {
          comment: nil,
          errors: ["You must be logged in to create a comment"]
        }
      end
      
      # Ensure user has proper role
      unless [:customer, :agent].include?(user.role.to_sym)
        return {
          comment: nil, 
          errors: ["You are not authorized to perform this action"]
        }
      end

      # Find the ticket
      ticket = Ticket.find_by(id: ticket_id)
      
      unless ticket
        return {
          comment: nil,
          errors: ["Ticket not found"]
        }
      end

      # Enforce comment restriction for customers
      if user.customer? && !ticket.agent_commented
        return {
          comment: nil,
          errors: ["You can only comment after an agent has responded"]
        }
      end

      # Create the comment
      comment = Comment.new(
        ticket: ticket,
        user: user,
        content: content
      )

      if comment.save
        {
          comment: comment,
          errors: []
        }
      else
        {
          comment: nil,
          errors: comment.errors.full_messages
        }
      end
    end
  end
end