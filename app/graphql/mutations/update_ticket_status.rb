module Mutations
  class UpdateTicketStatus < Mutations::BaseMutation
    argument :ticket_id, ID, required: true
    argument :status, String, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [String], null: false

    def resolve(ticket_id:, status:)
      # Get current user from context
      user = context[:current_user]

      # Ensure user is authenticated
      unless user
        return {
          ticket: nil,
          errors: ['You must be logged in to update ticket status']
        }
      end

      # Ensure user has agent role
      unless user.role.to_sym == :agent
        return {
          ticket: nil,
          errors: ['Only agents can update ticket status']
        }
      end

      # Find the ticket
      ticket = Ticket.find_by(id: ticket_id)

      unless ticket
        return {
          ticket: nil,
          errors: ['Ticket not found']
        }
      end

      # Update the ticket status
      if ticket.update(status: status.downcase)
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
