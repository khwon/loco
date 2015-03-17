class CreateBoardReads < ActiveRecord::Migration
  def change
    # (V)isited, (R)ead, (M)arked
    execute <<-SQL
      CREATE TYPE board_reads_status AS ENUM ('V', 'R', 'M');
    SQL
    create_table :board_reads do |t|
      t.references :user, index: true
      t.references :board, index: true
      t.int4range :posts
      t.column :status, :board_reads_status

#      t.timestamps
    end
    execute "CREATE INDEX posts_idx ON board_reads USING gist(posts);"
  end
end
