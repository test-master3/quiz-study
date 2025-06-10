require 'rails_helper'

RSpec.describe Quiz, type: :model do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'バリデーション' do
    it '有効なクイズであること' do
      quiz = build(:quiz,
        quiz_text: 'クイズ内容',
        send_to_line: true,
        question: question
      )
      expect(quiz).to be_valid
    end

    it 'quiz_textがなければ無効であること' do
      quiz = build(:quiz, quiz_text: nil, question: question)
      quiz.valid?
      expect(quiz.errors[:quiz_text]).to include("can't be blank")
    end

    it 'questionがなければ無効であること' do
      quiz = build(:quiz, question: nil)
      quiz.valid?
      expect(quiz.errors[:question]).to include("must exist")
    end

    context 'send_to_lineのバリデーション' do
      it 'trueは有効であること' do
        quiz = build(:quiz, send_to_line: true, question: question)
        expect(quiz).to be_valid
      end

      it 'falseは有効であること' do
        quiz = build(:quiz, send_to_line: false, question: question)
        expect(quiz).to be_valid
      end

      it 'true/false以外は無効であること' do
        quiz = build(:quiz, send_to_line: nil, question: question)
        quiz.valid?
        expect(quiz.errors[:send_to_line]).to include("is not included in the list")
      end
    end
  end
end 