class ExtendPostContent < ActiveRecord::Migration
  def change
    change_column :posts, :content, :text, :limit => 4294967295
  end
end
