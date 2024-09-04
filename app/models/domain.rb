class Domain < ApplicationRecord
  belongs_to :project
  has_one :cluster, through: :project
  validates :domain_name, presence: true, uniqueness: { scope: :project_id }
  validate :domain_name_has_tld
  before_save :downcase_domain_name
  before_save :strip_protocol

  private

  def domain_name_has_tld
    errors.add(:domain_name, "is not valid") unless domain_name.split(".").length > 1
  end

  def downcase_domain_name
    self.domain_name = domain_name.downcase
  end

  def strip_protocol
    self.domain_name = domain_name.gsub(/^https?:\/\//, "")
  end
end
