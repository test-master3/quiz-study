FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    sequence(:line_uid) { |n| "line_uid_#{n}" }
    line_linked { false }
  end
end 