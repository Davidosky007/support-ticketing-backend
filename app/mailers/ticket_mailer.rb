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
    # Find all agents
    agents = User.where(role: 'agent').to_a
    sent_count = 0
    
    # Get all open tickets once
    all_open_tickets = Ticket.where(status: :open)
    
    # Exit early if no open tickets
    return "No open tickets to send reminders for" unless all_open_tickets.any?
    
    # Send the same list of all open tickets to each agent
    agents.each do |agent|
      begin
        open_ticket_reminder(agent.email, all_open_tickets).deliver_now
        sent_count += 1
        Rails.logger.info("Sent reminder to #{agent.email} for #{all_open_tickets.count} open tickets")
      rescue => e
        Rails.logger.error("❌ Failed to send email to #{agent.email}: #{e.message}")
      end
    end

    # Still send summary to admin
    admin_email = ENV['DEFAULT_EMAIL_RECIPIENT'] || 'davidbassey428@gmail.com'
    open_ticket_reminder(admin_email, all_open_tickets).deliver_now

    "Sent #{sent_count} agent reminders and 1 admin summary. Total open tickets: #{all_open_tickets.count}"
  end
end
