class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :name
      t.text :body
      t.timestamps
    end
    add_index :posts, :name, length: 255, unique: true # explicit length is required for MySQL
  end
 
  def self.down
    drop_table :posts
  end
end
