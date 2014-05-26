class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.text :body
      t.integer :exit_code
      t.timestamps
    end
  end
 
  def self.down
    drop_table :tasks
  end
end
