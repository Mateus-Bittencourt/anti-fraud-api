class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :user_id, null: false
      t.boolean :chargeback_block, default: false
      t.integer :score, default: 10

      t.timestamps
    end
    add_index :users, :user_id, unique: true
  end
end
