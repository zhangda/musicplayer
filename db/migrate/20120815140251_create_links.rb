class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url, :limit => 512
      t.references :song

      t.timestamps
    end
    add_index :links, :song_id
  end
end
