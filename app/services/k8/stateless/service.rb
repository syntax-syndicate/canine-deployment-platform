# frozen_string_literal: true

class K8::Stateless::Service < K8::Base
  attr_accessor :name, :target_port

  def initialize(project)
    super
    @name = project.name
    @target_port = 3000
  end
end
