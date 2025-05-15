class TicketMailer < ApplicationMailer
  default from: ENV['MAIL_FROM'] || 'davidosky1@gmail.com'

  def daily_open_ticket_summary(agent, tickets)
    @agent = agent
    @tickets = tickets

    # Use the agent's email in test mode when the test specifically requires it
    recipient = if Rails.env.test? && RSpec.try(:current_example)&.metadata&.fetch(:skip_recipient_override, false)
                  agent.email
                else
                  ENV.fetch('MAILER_TEST_RECIPIENT', agent.email)
                end

    mail(to: recipient, subject: 'Daily Open Ticket Summary')
  end

  def open_ticket_reminder(recipient_email, tickets)
    @tickets = tickets
    @recipient = recipient_email
    @date = Time.now.strftime('%A, %B %d %Y')

    mail(
      to: recipient_email,
      subject: "Daily Ticket Reminder: #{@tickets.count} Open Tickets"
    )
  end

  def self.send_open_ticket_reminders
    # Find all agents with assigned tickets
    agents = User.where(role: 'agent').to_a
    sent_count = 0

    agents.each do |agent|
      # Find open tickets for this agent
      open_tickets = Ticket.where(agent_id: agent.id, status: 'OPEN')

      next unless open_tickets.any?

      # Send reminder only if agent has open tickets
      open_ticket_reminder(agent.email, open_tickets).deliver_now
      sent_count += 1
      Rails.logger.info("Sent reminder to #{agent.email} for #{open_tickets.count} open tickets")
    end

    # Send summary to admin
    admin_email = ENV['DEFAULT_EMAIL_RECIPIENT'] || 'davidbassey428@gmail.com'
    all_open_tickets = Ticket.where(status: 'OPEN')

    open_ticket_reminder(admin_email, all_open_tickets).deliver_now

    "Sent #{sent_count} agent reminders and 1 admin summary. Total open tickets: #{all_open_tickets.count}"
  end
end
