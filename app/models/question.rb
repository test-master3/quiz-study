class Question < ApplicationRecord
  belongs_to :user
  has_one :quiz, dependent: :destroy

  validates :content, presence: true, length: { maximum: 1000 }
  validates :quiz_question, presence: true, if: :quiz_question?
  validates :quiz_choices, presence: true, if: :quiz_question?
  validates :quiz_answer, presence: true, if: :quiz_question?

  def quiz_question?
    quiz_question.present?
  end
end
