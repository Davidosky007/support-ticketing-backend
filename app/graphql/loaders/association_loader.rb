# frozen_string_literal: true

module Loaders
  class AssociationLoader < GraphQL::Dataloader::Source
    def initialize(model, association_name)
      @model = model
      @association_name = association_name
    end

    def fetch(records)
      # Preload the association for all records
      ::ActiveRecord::Associations::Preloader.new(
        records: records,
        associations: @association_name
      ).call

      # Return the association for each record
      records.map { |record| record.public_send(@association_name) }
    end
  end
end