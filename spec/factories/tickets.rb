FactoryBot.define do
  factory :ticket do
    subject { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { :open }
    
    association :user, factory: :user, strategy: :create
    
    trait :with_agent do
      association :agent, factory: [:user, :agent], strategy: :create
    end
    
    trait :pending do
      status { :pending }
    end
    
    trait :closed do
      status { :closed }
    end
  end
end