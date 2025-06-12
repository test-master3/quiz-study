class AddAnalogyTextToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :analogy_text, :text
  end
end 