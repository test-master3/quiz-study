class AddQuizFieldsToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :quiz_question, :text
    add_column :questions, :quiz_choices, :text
    add_column :questions, :quiz_answer, :string
  end
end
