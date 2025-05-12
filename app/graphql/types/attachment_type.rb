# frozen_string_literal: true

module Types
  class AttachmentType < Types::BaseObject
    field :id, ID, null: false
    field :filename, String, null: false
    field :content_type, String, null: false
    field :url, String, null: false
    
    def url
      Rails.application.routes.url_helpers.rails_blob_url(object, only_path: true)
    end
  end
end