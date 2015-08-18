class CreateLocoMails < ActiveRecord::Migration
  def change
    create_table :loco_mails do |t|
      t.references :sender, index: true
      t.references :receiver, index: true
      t.string :title
      t.text :content
      t.boolean :has_read, default: false

      t.timestamps null: false
    end
  end
end
