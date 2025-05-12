module Authentication
  def authenticate!
    unless context[:current_user]
      raise GraphQL::ExecutionError, "You need to be authenticated to perform this action"
    end
  end
  
  def authenticate_agent!
    authenticate!
    
    unless context[:current_user].role == 'agent'
      raise GraphQL::ExecutionError, "Only agents can perform this action"
    end
  end
  
  def authenticate_customer!
    authenticate!
    
    unless context[:current_user].role == 'customer'
      raise GraphQL::ExecutionError, "Only customers can perform this action"
    end
  end
  
  # For customer tickets - only the owner or agents can see them
  def authorize_ticket_access!(ticket)
    authenticate!
    
    user = context[:current_user]
    
    if user.role == 'customer' && ticket.customer_id != user.id
      raise GraphQL::ExecutionError, "You don't have permission to access this ticket"
    end
  end
end