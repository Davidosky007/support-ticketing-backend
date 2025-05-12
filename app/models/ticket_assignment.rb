class TicketAssignment < ApplicationRecord
  belongs_to :ticket
  belongs_to :agent, class_name: 'User'
end
