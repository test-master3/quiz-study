class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :line_uid
      t.boolean :line_linked

      t.timestamps
    end
  end
end
