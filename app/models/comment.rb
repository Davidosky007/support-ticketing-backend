class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :ticket
  validates :content, presence: true

  after_create :check_agent_comment

  private

  def check_agent_comment
    return unless user.agent?

    ticket.update(agent_commented: true)
  end
end
