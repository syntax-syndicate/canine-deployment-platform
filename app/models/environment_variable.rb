class EnvironmentVariable < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :value, presence: true

  before_save :strip_whitespace

  private

  def strip_whitespace
    self.name = name.strip.upcase
    self.value = value.strip
  end
end
