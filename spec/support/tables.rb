class CreateTestTables < ActiveRecord::Migration
  def up
    create_table :babylonian_fields, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin' do |t|
      t.text :marshes
      t.boolean :some_value
      t.timestamps
    end
  end
  def down
    drop_table :babylonian_fields
  end
end
