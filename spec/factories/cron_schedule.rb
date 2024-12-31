require 'rails_helper'

FactoryBot.define do
  factory :cron_schedule do
    schedule { '0 0 * * *' } # Every day at midnight
    association :service

    trait :daily do
      schedule { '0 0 * * *' } # Every day at midnight
    end

    trait :weekly do
      schedule { '0 0 * * 0' } # Every Sunday at midnight
    end

    trait :monthly do
      schedule { '0 0 1 * *' } # Monthly on the 1st at midnight
    end

    trait :hourly do
      schedule { '0 * * * *' } # Every hour
    end

    trait :every_minute do
      schedule { '* * * * *' } # Every minute
    end
  end
end