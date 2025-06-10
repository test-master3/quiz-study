FactoryBot.define do
  factory :answer do
    content { '回答のテスト内容です' }
    from_gpt { false }
    association :question
  end
end 