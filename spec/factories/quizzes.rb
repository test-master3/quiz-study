FactoryBot.define do
  factory :quiz do
    quiz_text { 'クイズのテスト内容です' }
    send_to_line { false }
    association :question
  end
end 