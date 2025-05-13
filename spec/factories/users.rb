FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    role { :customer }  # Default role
    
    trait :customer do
      role { :customer }
    end
    
    trait :agent do
      role { :agent }
    end
  end
end