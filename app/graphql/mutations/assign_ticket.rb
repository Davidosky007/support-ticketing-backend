# frozen_string_literal: true

module Mutations
  class AssignTicket < Mutations::BaseMutation
    argument :ticket_id, ID, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [String], null: false

    def resolve(ticket_id:)
      # Get current user from context
      user = context[:current_user]
      
      # Ensure user is authenticated
      unless user
        return {
          ticket: nil,
          errors: ["You must be logged in to assign tickets"]
        }
      end
      
      # Ensure user has agent role
      unless user.role.to_sym == :agent
        return {
          ticket: nil, 
          errors: ["Only agents can assign tickets"]
        }
      end

      # Find the ticket
      ticket = Ticket.find_by(id: ticket_id)
      
      unless ticket
        return {
          ticket: nil,
          errors: ["Ticket not found"]
        }
      end

      # Update the ticket with the agent assignment
      if ticket.update(agent: user)
        # Create ticket assignment record
        TicketAssignment.create!(
          ticket: ticket, 
          agent: user, 
          assigned_at: Time.current
        )
        
        # If status is open, change it to pending
        if ticket.open?
          ticket.update(status: :pending)
        end
        
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