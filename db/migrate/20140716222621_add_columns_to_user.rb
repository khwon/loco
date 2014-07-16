class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :password, :string
    add_column :users, :nickname, :string
    add_column :users, :realname, :string
    add_column :users, :sex, :string
    add_column :users, :email, :string
  end
end
