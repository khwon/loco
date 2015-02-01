class AddIndices < ActiveRecord::Migration
  def change
    add_index :board_reads, [:user_id, :board_id]
    add_index :visitread_maxes, [:user_id, :board_id]
    add_index :fav_boards, [:user_id, :board_id]
    add_index :zap_boards, [:user_id, :board_id]
    remove_index :board_reads, :user_id
    remove_index :fav_boards, :user_id
    remove_index :zap_boards, :user_id
  end
end
