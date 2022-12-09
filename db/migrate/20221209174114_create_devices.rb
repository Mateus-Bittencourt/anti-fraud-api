class CreateDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :devices do |t|
      t.integer :device_id, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :devices, :device_id, unique: true
  end
end
