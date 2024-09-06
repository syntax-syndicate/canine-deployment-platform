class DropContainerRegistryFromProjects < ActiveRecord::Migration[7.1]
  def change
    remove_column :projects, :container_registry, :string
  end
end
