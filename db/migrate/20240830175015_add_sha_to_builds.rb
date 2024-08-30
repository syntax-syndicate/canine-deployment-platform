class AddShaToBuilds < ActiveRecord::Migration[7.1]
  def change
    add_column :builds, :sha, :string
  end
end
