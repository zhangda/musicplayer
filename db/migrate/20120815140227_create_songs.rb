class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name
      t.string :cover, :limit => 512

      t.timestamps
    end
    add_index :songs, :name
  end
end
