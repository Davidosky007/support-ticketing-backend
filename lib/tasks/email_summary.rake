namespace :email do
  desc 'Send a summary email with active agent and ticket counts'
  task daily_summary: :environment do
    puts 'Generating system status summary email...'

    # Gather stats
    agent_count = User.where(role: 'agent').count
    open_tickets = Ticket.where(status: 'OPEN').count
    pending_tickets = Ticket.where(status: 'PENDING').count
    closed_tickets = Ticket.where(status: 'CLOSED').count

    # Build email content
    subject = "Daily Support System Status: #{open_tickets} open tickets"

    body = <<~EMAIL
      Support System Daily Summary
      ===========================

      TICKET STATISTICS:
      - Open Tickets: #{open_tickets}
      - Pending Tickets: #{pending_tickets}
      - Closed Tickets: #{closed_tickets}
      - Total Tickets: #{open_tickets + pending_tickets + closed_tickets}

      AGENT STATISTICS:
      - Active Agents: #{agent_count}

      EMAIL STATISTICS:
      - Daily emails will be sent to #{agent_count} agents with open tickets
      - The next scheduled email will be sent tomorrow at 9:00 AM

      This is an automated message from your Support Ticketing System.
    EMAIL

    # Send the email
    recipient = ENV.fetch('DEFAULT_EMAIL_RECIPIENT', 'davidbassey428@gmail.com')

    begin
      ActionMailer::Base.mail(
        from: ENV.fetch('MAIL_FROM', 'davidosky1@gmail.com'),
        to: recipient,
        subject: subject,
        body: body
      ).deliver_now

      puts "Summary email sent successfully to #{recipient}"
    rescue StandardError => e
      puts "ERROR: Failed to send summary email: #{e.message}"
    end
  end
end
