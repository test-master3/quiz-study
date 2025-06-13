class AddAnalogyOptionsToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :abstraction_level, :string
    add_column :questions, :analogy_genre, :string
  end
end 