class AddQuizToAnswers < ActiveRecord::Migration[7.1]
  def change
    add_reference :answers, :quiz, null: false, foreign_key: true
  end
end
