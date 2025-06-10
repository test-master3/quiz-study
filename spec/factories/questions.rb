FactoryBot.define do
  factory :question do
    content { '質問のテスト内容です' }
    answer_text { nil }
    quiz_question { nil }
    quiz_choices { nil }
    quiz_answer { nil }
    association :user
  end
end 