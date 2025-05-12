class ApplicationController < ActionController::API

  def authorize_role!(*roles)
    unless current_user && roles.include?(current_user.role.to_sym)
      raise GraphQL::ExecutionError, "You are not authorized to perform this action."
    end
  end
end
