class TicketMailer < ApplicationMailer
  def daily_open_ticket_summary(agent, tickets)
    @agent = agent
    @tickets = tickets
    mail(to: agent.email, subject: 'Daily Open Ticket Summary')
  end
end