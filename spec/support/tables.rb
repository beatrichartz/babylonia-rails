class CreateTestTables < ActiveRecord::Migration
  def up
    create_table :babylonian_fields do |t|
      t.text :marshes
      t.timestamps
    end
  end
  def down
    drop_table :babylonian_fields
  end
end
