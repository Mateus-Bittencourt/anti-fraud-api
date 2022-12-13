class CreateDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :devices do |t|

      t.references :user, null: false, foreign_key: true
      t.boolean :blocked, default: false
      t.timestamps
    end
  end
end
