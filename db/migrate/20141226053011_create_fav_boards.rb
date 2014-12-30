class CreateFavBoards < ActiveRecord::Migration
  def change
    create_table :fav_boards do |t|
      t.references :user
      t.references :board

      t.timestamps null: false
    end
  end
end
