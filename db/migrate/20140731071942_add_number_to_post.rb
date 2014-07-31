class AddNumberToPost < ActiveRecord::Migration
  def change
    add_column :posts, :num, :integer
  end
end
