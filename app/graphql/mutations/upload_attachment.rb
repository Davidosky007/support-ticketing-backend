module Mutations
  class UploadAttachment < Mutations::BaseMutation
    argument :ticket_id, ID, required: true
    argument :file, String, required: true, description: "Base64 encoded file"
    argument :filename, String, required: true
    argument :content_type, String, required: true

    field :success, Boolean, null: false
    field :attachment, Types::AttachmentType, null: true
    field :errors, [String], null: false

    def resolve(ticket_id:, file:, filename:, content_type:)
      # Authenticate user
      authenticate!
      
      # Find the ticket
      ticket = Ticket.find_by(id: ticket_id)
      
      unless ticket
        return {
          success: false,
          attachment: nil,
          errors: ["Ticket not found"]
        }
      end
      
      # Check permissions (only ticket owner or assigned agent can upload)
      user = context[:current_user]
      unless user.id == ticket.customer_id || user.id == ticket.agent_id
        return {
          success: false,
          attachment: nil,
          errors: ["You don't have permission to upload files to this ticket"]
        }
      end
      
      # Decode base64 file
      decoded_file = Base64.decode64(file)
      
      # Create a temp file for active storage
      temp_file = Tempfile.new(filename)
      temp_file.binmode
      temp_file.write(decoded_file)
      temp_file.rewind
      
      # Attach the file to the ticket
      begin
        attachment = ticket.attachments.attach(
          io: temp_file,
          filename: filename,
          content_type: content_type
        )
        
        # Return success response
        {
          success: true,
          attachment: ticket.attachments.last,
          errors: []
        }
      rescue => e
        {
          success: false,
          attachment: nil,
          errors: [e.message]
        }
      ensure
        # Clean up temp file
        temp_file.close
        temp_file.unlink
      end
    end
  end
end