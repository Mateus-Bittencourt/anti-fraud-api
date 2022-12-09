class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants do |t|
      t.integer :merchant_id, null: false

      t.timestamps
    end
    add_index :merchants, :merchant_id, unique: true
  end
end
