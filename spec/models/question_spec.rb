require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    it '有効な質問であること' do
      question = build(:question, content: '質問内容', user: user)
      expect(question).to be_valid
    end

    it 'contentがなければ無効であること' do
      question = build(:question, content: nil, user: user)
      question.valid?
      expect(question.errors[:content]).to include("can't be blank")
    end

    it 'userがなければ無効であること' do
      question = build(:question, user: nil)
      question.valid?
      expect(question.errors[:user]).to include("must exist")
    end

    context 'クイズ関連のバリデーション' do
      it 'クイズ質問がある場合、関連フィールドが必須であること' do
        question = build(:question,
          quiz_question: '問題文',
          quiz_choices: nil,
          quiz_answer: nil,
          user: user
        )
        question.valid?
        expect(question.errors[:quiz_choices]).to include("can't be blank")
        expect(question.errors[:quiz_answer]).to include("can't be blank")
      end

      it 'クイズ質問がない場合、関連フィールドは任意であること' do
        question = build(:question,
          quiz_question: nil,
          quiz_choices: nil,
          quiz_answer: nil,
          user: user
        )
        expect(question).to be_valid
      end
    end
  end
end 