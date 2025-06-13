class AddDetailsToQuizzes < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :quiz_choices, :text
    add_column :quizzes, :quiz_link, :string
  end
end
