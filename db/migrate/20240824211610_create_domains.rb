class CreateDomains < ActiveRecord::Migration[7.1]
  def change
    create_table :domains do |t|
      t.references :project, null: false, foreign_key: true
      t.string :domain_name, null: false

      t.timestamps
    end
  end
end
