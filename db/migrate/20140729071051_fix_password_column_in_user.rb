class FixPasswordColumnInUser < ActiveRecord::Migration
  def change
    rename_column :users, :password, :password_digest
    add_column :users, :old_crypt_password, :string
  end
end
