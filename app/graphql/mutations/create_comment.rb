# frozen_string_literal: true

module Mutations
  # Mutation for creating a comment on a ticket
  class CreateComment < Mutations::BaseMutation
    argument :ticket_id, ID, required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [String], null: false

    def resolve(ticket_id:, content:)
      user = context[:current_user]

      result = authenticate_user(user)
      return result if result

      result = validate_user_role(user)
      return result if result

      ticket = Ticket.find_by(id: ticket_id)

      result = validate_ticket(ticket)
      return result if result

      result = check_customer_permissions(user, ticket)
      return result if result

      create_and_save_comment(ticket, user, content)
    end

    private

    def authenticate_user(user)
      return nil if user

      {
        comment: nil,
        errors: ['You must be logged in to create a comment']
      }
    end

    def validate_user_role(user)
      return nil if %i[customer agent].include?(user.role.to_sym)

      {
        comment: nil,
        errors: ['You are not authorized to perform this action']
      }
    end

    def validate_ticket(ticket)
      return nil if ticket

      {
        comment: nil,
        errors: ['Ticket not found']
      }
    end

    def check_customer_permissions(user, ticket)
      return nil unless user.customer? && !ticket.agent_commented

      {
        comment: nil,
        errors: ['Agent must comment first']
      }
    end

    def create_and_save_comment(ticket, user, content)
      comment = Comment.new(
        ticket: ticket,
        user: user,
        content: content
      )

      if comment.save
        ticket.update(agent_commented: true) if user.agent?
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
