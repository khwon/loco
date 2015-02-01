class CreateVisitreadMaxes < ActiveRecord::Migration
  def change
    create_table :visitread_maxes do |t|
      t.references :user
      t.references :board
      t.integer :num

      t.timestamps null: false
    end
  end
end
