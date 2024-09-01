class AddShaToBuilds < ActiveRecord::Migration[7.1]
  def change
    add_column :builds, :commit_sha, :string, null: false
  end
end
