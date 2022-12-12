class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :user_id, null: false
      t.boolean :blocked, default: false
      t.integer :chargeback_count, default: 0

      t.timestamps
    end
    add_index :users, :user_id, unique: true
  end
end
