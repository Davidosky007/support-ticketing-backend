# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
  

    # Add mutations
    field :create_comment, mutation: Mutations::CreateComment,
      description: "Create a new comment on a ticket"

    field :create_ticket, mutation: Mutations::CreateTicket,
      description: "Create a new support ticket"

    field :generate_tickets_csv, mutation: Mutations::GenerateTicketsCsv,
      description: "Generate CSV export of tickets (agents only)"
  end
end
