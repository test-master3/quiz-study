class AddLineLinkTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :line_link_token, :string
    add_index :users, :line_link_token, unique: true
    add_column :users, :line_link_token_sent_at, :datetime
  end
end
