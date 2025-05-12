# frozen_string_literal: true

module Mutations
  class CreateTicket < Mutations::BaseMutation
    argument :subject, String, required: true
    argument :description, String, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [String], null: false

    def resolve(subject:, description:)
      # Get current user from context
      user = context[:current_user]
      
      # Ensure user is authenticated
      unless user
        return {
          ticket: nil,
          errors: ["You must be logged in to create a ticket"]
        }
      end
      
      # Ensure user has customer role
      unless user.role.to_sym == :customer
        return {
          ticket: nil, 
          errors: ["Only customers can create tickets"]
        }
      end

      # Create the ticket
      ticket = Ticket.new(
        subject: subject,
        description: description,
        user: user,  # Uses customer_id foreign key through association
        status: :open
      )

      if ticket.save
        {
          ticket: ticket,
          errors: []
        }
      else
        {
          ticket: nil,
          errors: ticket.errors.full_messages
        }
      end
    end
  end
end