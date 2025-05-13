FactoryBot.define do
  factory :ticket_assignment do
    ticket
    association :agent, factory: [:user, :agent]
    assigned_at { Time.current }
  end
end