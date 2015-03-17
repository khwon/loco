class CreateZapBoards < ActiveRecord::Migration
  def change
    create_table :zap_boards do |t|
      t.references :user
      t.references :board

      t.timestamps null: false
    end
  end
end
