require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'バリデーション' do
    it '有効な回答であること' do
      answer = build(:answer, content: '回答内容', question: question)
      expect(answer).to be_valid
    end

    it 'contentがなければ無効であること' do
      answer = build(:answer, content: nil, question: question)
      answer.valid?
      expect(answer.errors[:content]).to include("can't be blank")
    end

    it 'questionがなければ無効であること' do
      answer = build(:answer, question: nil)
      answer.valid?
      expect(answer.errors[:question]).to include("must exist")
    end
  end
end 