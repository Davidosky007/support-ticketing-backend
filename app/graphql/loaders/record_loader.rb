# frozen_string_literal: true

module Loaders
  class RecordLoader < GraphQL::Dataloader::Source
    def initialize(model)
      @model = model
    end

    def fetch(ids)
      records = @model.where(id: ids)
      # Return records in the same order as the ids
      ids.map { |id| records.find { |record| record.id.to_s == id.to_s } }
    end
  end
end