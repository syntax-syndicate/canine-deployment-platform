class CreateBuilds < ActiveRecord::Migration[7.1]
  def change
    create_table :builds do |t|
      t.references :project, null: false, foreign_key: true
      t.string :repository_url
      t.string :git_sha
      t.string :commit_message
      t.integer :status

      t.timestamps
    end
  end
end
