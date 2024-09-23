# == Schema Information
#
# Table name: accounts
#
#  id                  :bigint           not null, primary key
#  account_users_count :integer          default(0)
#  billing_email       :string
#  domain              :string
#  extra_billing_info  :text
#  name                :string           not null
#  personal            :boolean          default(FALSE)
#  subdomain           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  owner_id            :bigint
#
# Indexes
#
#  index_accounts_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Account < ApplicationRecord
  has_prefix_id :acct

  include Billing
  include Domains
  include Transfer

  belongs_to :owner, class_name: "User"
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :account_notifications, dependent: :destroy, class_name: "Noticed::Event"
  has_many :users, through: :account_users
  has_many :addresses, as: :addressable, dependent: :destroy

  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }

  has_one_attached :avatar

  validates :avatar, resizable_image: true
  validates :name, presence: true

  def team?
    !personal?
  end

  def personal_account_for?(user)
    personal? && owner?(user)
  end

  def owner?(user)
    owner_id == user.id
  end
end
