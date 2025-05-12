require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:description) }
  end
  
  describe 'associations' do
    it { should belong_to(:user).with_foreign_key(:customer_id) }
    it { should belong_to(:agent).class_name('User').optional }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:ticket_assignments).dependent(:destroy) }
  end
  
  describe 'enum' do
    it { should define_enum_for(:status).with_values(open: 0, pending: 1, closed: 2) }
  end
end