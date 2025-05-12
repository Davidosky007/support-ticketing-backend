namespace :tickets do
  desc 'Send daily email reminders to agents with open tickets'
  task send_open_ticket_reminders: :environment do
    puts "Starting to send ticket reminders to agents..."
    
    # Find all agents
    User.where(role: :agent).find_each do |agent|
      # Find open tickets assigned to the agent
      open_tickets = Ticket.where(agent: agent, status: :open)
      
      # Only send email if there are open tickets
      if open_tickets.any?
        puts "Sending reminder to #{agent.email} for #{open_tickets.count} open tickets"
        TicketMailer.daily_open_ticket_summary(agent, open_tickets).deliver_now
      else
        puts "No open tickets for #{agent.email}, skipping..."
      end
    end
    
    puts "Finished sending ticket reminders."
  end
end