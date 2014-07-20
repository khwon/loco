class ChangeColumnsToBoards < ActiveRecord::Migration
  def change
    change_table :boards do |t|
      t.remove :name1
      t.remove :name2
      t.remove :name3
      t.references :parent, index: true
      t.boolean :is_dir
      t.string :name, index: true
    end
  end
end
