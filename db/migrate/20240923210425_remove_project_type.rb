# frozen_string_literal: true

class RemoveProjectType < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    remove_column :projects, :project_type, :integer
  end
end
