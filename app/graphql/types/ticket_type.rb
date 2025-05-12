# frozen_string_literal: true

module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :subject, String
    field :description, String
    field :status, Integer
    field :customer_id, Integer
    field :agent_id, Integer
    field :agent_commented, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
