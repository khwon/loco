class AddIndexes < ActiveRecord::Migration
  def change
    add_index :zap_boards, :user_id
    add_index :zap_boards, :board_id
    add_index :fav_boards, :user_id
    add_index :fav_boards, :board_id
    remove_index :posts, :board_id
    add_index :posts, [:board_id, :num], :unique => true
  end
end
