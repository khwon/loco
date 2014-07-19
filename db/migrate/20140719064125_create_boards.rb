class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name1
      t.string :name2
      t.string :name3
      t.references :owner, index: true
      t.string :title
      t.references :linked_board, index: true
      t.references :alias_board, index: true

      t.timestamps
    end
  end
end
