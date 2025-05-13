require "rails_helper"

RSpec.describe TicketMailer, type: :mailer do
  describe "daily_open_ticket_summary", skip_recipient_override: true do
    let(:agent) { create(:user, :agent, name: "Test Agent", email: "agent@example.com") }
    let!(:tickets) do
      [
        create(:ticket, subject: "Ticket 1", status: :open, agent: agent),
        create(:ticket, subject: "Ticket 2", status: :open, agent: agent),
        create(:ticket, subject: "Ticket 3", status: :open, agent: agent)
      ]
    end
    
    let(:mail) { TicketMailer.daily_open_ticket_summary(agent, tickets) }

    it "renders the headers" do
      expect(mail.subject).to eq("Daily Open Ticket Summary")
      expect(mail.to).to eq(["agent@example.com"])
      expect(mail.from).to eq([ENV.fetch('MAIL_FROM', 'from@example.com')])
    end

    it "renders the body with ticket information" do
      expect(mail.body.encoded).to include("You have 3 open tickets")
      expect(mail.body.encoded).to include("Ticket 1")
      expect(mail.body.encoded).to include("Ticket 2")
      expect(mail.body.encoded).to include("Ticket 3")
    end
  end
end