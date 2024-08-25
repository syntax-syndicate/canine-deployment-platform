class CreateAddOns < ActiveRecord::Migration[7.1]
  def change
    create_table :add_ons do |t|
      t.references :cluster, null: false, foreign_key: true
      t.integer :add_on_type, null: false
      t.string :name, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
