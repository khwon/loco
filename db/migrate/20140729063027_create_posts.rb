class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.references :board, index: true
      t.references :parent, index: true
      t.text :content
      t.references :writer, index: true

      t.timestamps
    end
  end
end
