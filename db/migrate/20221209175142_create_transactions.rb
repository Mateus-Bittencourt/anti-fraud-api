class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.integer :transaction_id, null: false
      t.references :merchant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :device, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.string :transaction_date, null: false
      t.float :transaction_amount, null: false
      t.string :recommendation, null: false
      t.integer :score, default: 10
      t.boolean :chargeback, default: false

      t.timestamps
    end
      add_index :transactions, :transaction_id, unique: true
  end
end
