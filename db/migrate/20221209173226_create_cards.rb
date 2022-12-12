class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :card_number, null: false
      t.boolean :blocked, default: false
      t.references :user, null: false, foreign_key: true


      t.timestamps
    end
    add_index :cards, :card_number, unique: true
  end
end
