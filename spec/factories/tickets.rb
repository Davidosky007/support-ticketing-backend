FactoryBot.define do
  factory :ticket do
    subject { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { :open }
    
    association :user, factory: [:user, :customer], strategy: :create
    
    trait :with_agent do
      association :agent, factory: [:user, :agent], strategy: :create
    end
    
    trait :pending do
      status { :pending }
      with_agent
    end
    
    trait :closed do
      status { :closed }
      with_agent
    end
  end
end