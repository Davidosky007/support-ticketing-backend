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

    field :current_user, Types::UserType, null: true,
      description: "Get the currently authenticated user"

    # Secured resolver methods
    def tickets
      # Check authentication
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "You need to be authenticated to access tickets"
      end
      
      user = context[:current_user]
      if user.role == 'agent'
        Ticket.includes(:user, :agent, :comments)
      else
        # Customers should only see their own tickets
        Ticket.where(customer_id: user.id).includes(:user, :agent, :comments)
      end
    end
    
    def ticket(id:)
      # Check authentication
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "You need to be authenticated to access ticket details"
      end
      
      Ticket.includes(:user, :agent, :comments).find_by(id: id)
    end
    
    def users
      # Check authentication and role
      user = context[:current_user]
      if user.nil?
        raise GraphQL::ExecutionError, "You need to be authenticated to access users"
      end
      
      # Only agents can list all users
      if user.role != 'agent'
        raise GraphQL::ExecutionError, "Only agents can access user list"
      end
      
      User.includes(:tickets, :assigned_tickets, :comments)
    end
    
    def user(id:)
      # Check authentication
      user = context[:current_user]
      if user.nil?
        raise GraphQL::ExecutionError, "You need to be authenticated to access user details"
      end
      
      # Users can only access their own profile unless they're agents
      if user.role != 'agent' && user.id.to_s != id.to_s
        raise GraphQL::ExecutionError, "You can only access your own user details"
      end
      
      User.includes(:tickets, :assigned_tickets, :comments).find_by(id: id)
    end

    def current_user
      context[:current_user]
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

  end
end
