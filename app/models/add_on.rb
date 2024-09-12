class AddOn < ApplicationRecord
  include Loggable
  belongs_to :cluster
  enum status: {
    installing: 0,
    installed: 1,
    uninstalling: 2,
    uninstalled: 3,
    failed: 4,
  }
  validates :chart_type, presence: true
  validate :chart_type_exists
  validates :name, presence: true, format: { with: /\A[a-z0-9_-]+\z/, message: "must be lowercase, numbers, hyphens, and underscores only" }

  protected

  def chart_definition
    charts = YAML.load_file(Rails.root.join('resources', 'helm', 'charts.yml'))['helm']['charts']
    charts.find { |chart| chart['name'] == chart_type }
  end

  def chart_type_exists
    if chart_definition.nil?
      errors.add(:chart_type, "does not exist")
    end
  end

  def validate_keys(required_keys)
    missing_keys = required_keys - metadata.keys

    if missing_keys.any?
      errors.add(:metadata, "is missing required keys: #{missing_keys.join(', ')}")
    end
  end
end
