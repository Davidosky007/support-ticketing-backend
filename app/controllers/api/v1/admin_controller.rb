class Api::V1::AdminController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:trigger_daily_emails]
  before_action :authenticate_api_key, only: [:trigger_daily_emails]
  
  def trigger_daily_emails
    result = TicketMailer.send_open_ticket_reminders
    render json: { success: true, message: result }
  end
  
  private
  
  def authenticate_api_key
    api_key = request.headers['X-API-KEY']
    unless api_key && api_key == ENV['ADMIN_API_KEY']
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end