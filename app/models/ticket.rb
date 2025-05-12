class Ticket < ApplicationRecord
  belongs_to :user, foreign_key: :customer_id
  belongs_to :agent, class_name: 'User', optional: true
  has_many :comments, dependent: :destroy
  has_many_attached :attachments
  has_many :ticket_assignments, dependent: :destroy
  enum status: { open: 0, pending: 1, closed: 2 }
  validates :subject, presence: true
  validates :description, presence: true
end
