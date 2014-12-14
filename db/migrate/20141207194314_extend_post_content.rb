class ExtendPostContent < ActiveRecord::Migration
  def change
    change_column :posts, :content, :text, :limit => 1073741823
  end
end
