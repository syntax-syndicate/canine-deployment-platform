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
  validates :name, presence: true, format: { with: /\A[a-z0-9_-]+\z/, message: "must be lowercase, numbers, hyphens, and underscores only" }

  protected

  def validate_keys(required_keys)
    missing_keys = required_keys - metadata.keys

    if missing_keys.any?
      errors.add(:metadata, "is missing required keys: #{missing_keys.join(', ')}")
    end
  end
end
