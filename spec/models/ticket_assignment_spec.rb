require 'rails_helper'

RSpec.describe TicketAssignment, type: :model do
  describe 'associations' do
    it { should belong_to(:ticket) }
    it { should belong_to(:agent).class_name('User') }
  end
  
  describe 'validations' do
    it 'should validate agent has the agent role' do
      agent = create(:user, :agent)
      ticket = create(:ticket)
      assignment = build(:ticket_assignment, agent: agent, ticket: ticket)
      expect(assignment).to be_valid
      
      customer = create(:user, :customer)
      invalid_assignment = build(:ticket_assignment, agent: customer, ticket: ticket)
      expect(invalid_assignment).not_to be_valid
      expect(invalid_assignment.errors[:agent]).to include("must have agent role")
    end
  end
end