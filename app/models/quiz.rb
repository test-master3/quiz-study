class Quiz < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many :answers, dependent: :destroy

  validates :quiz_text, presence: true
  validates :send_to_line, inclusion: { in: [true, false] }
end
