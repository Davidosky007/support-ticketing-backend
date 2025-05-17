require 'rails_helper'
require 'rake'

RSpec.describe 'tickets:send_open_ticket_reminders', type: :task do
  before do
    # Load the Rake file
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    
    # Clear any existing mail deliveries
    ActionMailer::Base.deliveries.clear
    
    # Configure mailer for testing
    ActionMailer::Base.delivery_method = :test
  end

  let!(:agent1) { create(:user, :agent) }
  let!(:agent2) { create(:user, :agent) }
  
  let!(:open_tickets) do
    [
      create(:ticket, status: :open, agent: agent1),
      create(:ticket, status: :open, agent: agent1),
      create(:ticket, status: :open, agent: agent2)
    ]
  end
  
  let!(:closed_ticket) { create(:ticket, :closed, agent: agent1) }
  
  it "sends emails to agents with all open tickets", skip_recipient_override: true do
    # Allow the mailer to be spied on so we can check calls
    allow(TicketMailer).to receive(:daily_open_ticket_summary).and_call_original

    expect { Rake::Task['tickets:send_open_ticket_reminders'].invoke }
      .to change { ActionMailer::Base.deliveries.count }.by(3) # 2 agents + 1 admin summary

    # Check that the mailer was called for both agents
    agent_emails = [agent1.email, agent2.email]
    delivered_to = ActionMailer::Base.deliveries.map(&:to).flatten
    expect(delivered_to).to include(*agent_emails)
  end
end
