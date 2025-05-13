class TicketAssignment < ApplicationRecord
  belongs_to :ticket
  belongs_to :agent, class_name: 'User'
  
  validate :agent_has_agent_role
  
  private
  
  def agent_has_agent_role
    unless agent&.role == 'agent'
      errors.add(:agent, "must have agent role")
    end
  end
end
