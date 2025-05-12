require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end
  
  describe 'associations' do
    it { should have_many(:tickets).with_foreign_key(:customer_id) }
    it { should have_many(:assigned_tickets).class_name('Ticket').with_foreign_key(:agent_id) }
    it { should have_many(:comments) }
    it { should have_many(:ticket_assignments).with_foreign_key(:agent_id) }
  end
  
  describe 'enum' do
    it { should define_enum_for(:role).with_values(customer: 0, agent: 1) }
  end
end