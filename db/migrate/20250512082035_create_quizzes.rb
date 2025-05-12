class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.text :quiz_text
      t.boolean :send_to_line
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
