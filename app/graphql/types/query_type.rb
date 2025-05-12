# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add ticket queries
    field :tickets, [Types::TicketType], null: false,
      description: "Get all tickets"
    
    field :ticket, Types::TicketType, null: true,
      description: "Get a ticket by ID" do
      argument :id, ID, required: true
    end
    
    # Add user queries
    field :users, [Types::UserType], null: false,
      description: "Get all users"
    
    field :user, Types::UserType, null: true,
      description: "Get a user by ID" do
      argument :id, ID, required: true
    end
    
    # Resolver methods
    def tickets
      Ticket.all
    end
    
    def ticket(id:)
      Ticket.find_by(id: id)
    end
    
    def users
      User.all
    end
    
    def user(id:)
      User.find_by(id: id)
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

  end
end
