class AddStatusToClusters < ActiveRecord::Migration[7.1]
  def change
    add_column :clusters, :status, :integer, default: 0
  end
end
