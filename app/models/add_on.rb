class AddOn < ApplicationRecord
  belongs_to :cluster
  enum add_on_type: {
    postgres: 0,
    redis: 1,
    helm_chart: 2,
  }
  enum status: {
    installing: 0,
    installed: 1,
    uninstalling: 2,
    uninstalled: 3,
  }
end
