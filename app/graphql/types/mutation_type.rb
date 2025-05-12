# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Add mutations
    field :login, mutation: Mutations::Login,
      description: "Login with email and password"

    field :register, mutation: Mutations::Register,
      description: "Register a new user account"

    field :create_comment, mutation: Mutations::CreateComment,
      description: "Create a new comment on a ticket"

    field :create_ticket, mutation: Mutations::CreateTicket,
      description: "Create a new support ticket"
      
    field :assign_ticket, mutation: Mutations::AssignTicket,
      description: "Assign a ticket to the current agent"

    field :generate_tickets_csv, mutation: Mutations::GenerateTicketsCsv,
      description: "Generate CSV export of tickets (agents only)"

    field :upload_attachment, mutation: Mutations::UploadAttachment,
      description: "Upload a file attachment to a ticket"
  end
end
