class LogOutput < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  after_update_commit :broadcast_log_output

  private

  def broadcast_log_output
    broadcast_replace_to dom_id(loggable, :logs), target: dom_id(loggable, :logs), partial: "log_outputs/logs", locals: { loggable: loggable }
  end
end