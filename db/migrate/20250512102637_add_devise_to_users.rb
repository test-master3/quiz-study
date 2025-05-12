class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      # t.string :email,              null: false, default: "" ← すでにあるのでコメントアウト！
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    # add_index :users, :email,                unique: true ← これも必要ならコメントアウト
    add_index :users, :reset_password_token, unique: true
  end
end