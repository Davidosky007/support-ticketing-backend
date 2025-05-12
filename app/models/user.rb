class User < ApplicationRecord
  has_secure_password

  has_many :tickets, foreign_key: :customer_id
  has_many :assigned_tickets, class_name: 'Ticket', foreign_key: :agent_id
  has_many :comments
  has_many :ticket_assignments, foreign_key: :agent_id

  enum role: { customer: 0, agent: 1 }

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
end
