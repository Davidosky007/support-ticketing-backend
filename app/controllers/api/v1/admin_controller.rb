class Api::V1::AdminController < ActionController::API
  before_action :authenticate_api_key, only: [:trigger_daily_emails]

  def trigger_daily_emails
    result = TicketMailer.send_open_ticket_reminders
    render json: { success: true, message: result }
  end

  private

  def authenticate_api_key
    api_key = request.headers['X-API-KEY']
    return if api_key && api_key == ENV['ADMIN_API_KEY']

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
