class AddAnswerTextToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :answer_text, :text
  end
end
