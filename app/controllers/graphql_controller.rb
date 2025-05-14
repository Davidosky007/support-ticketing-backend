# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    # Add this authentication check before execution
    context = {
      current_user: current_user,
      host_with_port: request.host_with_port
      # other context values...
    }

    # For unauthenticated requests that require authentication, provide a helpful error
    if requires_authentication?(query) && context[:current_user].nil?
      render json: { errors: [{ message: 'You must be authenticated to perform this action' }] }
      return
    end

    result = SupportTicketingBackendSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development? || Rails.env.test?

    handle_error_in_development(e)
  end

  private

  # Get current user from token
  def current_user
    # Return nil if no auth header
    header = request.headers['Authorization']
    return nil unless header

    # Extract token from header
    token = header.split(' ').last
    return nil unless token

    # Temporary Development Override: Always return first agent for testing
    # if Rails.env.development? && params[:skip_auth] == 'true'
    #   return User.find_by(email: 'agent1@example.com')
    # end

    begin
      # Decode token
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      # Find user by id in token payload
      user_id = decoded.first['user_id']
      User.find_by(id: user_id)
    rescue JWT::DecodeError
      nil
    end
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  # Helper method to determine if a query requires authentication
  def requires_authentication?(query)
    # Skip auth check for introspection and login/register
    return false if query.nil?
    return false if query.include?('IntrospectionQuery')
    return false if query.include?('login') || query.include?('register')

    # Otherwise require authentication for mutations and protected queries
    query.include?('mutation') || query.include?('tickets')
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
