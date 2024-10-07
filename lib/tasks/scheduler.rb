# frozen_string_literal: true

namespace :scheduler do
  desc "flush metrics"
  task flush_metrics: :environment do |_, args|
    Metric.where("created_at < ?", 1.days.ago).destroy_all
  end
end
