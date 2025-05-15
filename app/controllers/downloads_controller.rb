class DownloadsController < ApplicationController
  # Remove the problematic line that's causing the app to crash
  # No need to skip verify_authenticity_token in API mode since it's not included

  def show
    filename = params[:filename]
    filepath = Rails.root.join('tmp', filename)

    Rails.logger.info("Attempting to download file: #{filename}")

    if File.exist?(filepath)
      Rails.logger.info("File found, sending: #{filepath}")
      send_file filepath,
                disposition: 'attachment',
                filename: filename,
                type: 'text/csv'
    else
      Rails.logger.warn("File not found: #{filepath}")
      render json: {
        error: 'File not found',
        possible_cause: 'No closed tickets in date range or file generation failed'
      }, status: 404
    end
  end



 
end
