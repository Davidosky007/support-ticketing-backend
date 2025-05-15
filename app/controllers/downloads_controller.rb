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

  # Method to manually trigger daily email reminders
  def send_daily_emails
    # Call the mailer directly
    result = TicketMailer.send_open_ticket_reminders

    render json: {
      status: 'Success',
      message: 'Daily reminder emails have been sent',
      details: result
    }
  rescue StandardError => e
    Rails.logger.error("Email sending error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    render json: {
      error: 'Failed to send emails',
      message: e.message
    }, status: 500
  end
end
