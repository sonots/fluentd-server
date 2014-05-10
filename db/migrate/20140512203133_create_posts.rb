class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
    add_index :posts, :title, length: 255 # explicit length is required for MySQL
  end
 
  def self.down
    drop_table :posts
  end
end
