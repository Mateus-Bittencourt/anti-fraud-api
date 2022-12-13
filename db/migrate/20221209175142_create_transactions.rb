class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :device, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.datetime :date, null: false
      t.float :amount, null: false
      t.string :recommendation, null: false, default: 'approve'
      t.boolean :chargeback, default: false

      t.timestamps
    end
  end
end
