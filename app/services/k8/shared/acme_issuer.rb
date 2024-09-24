# frozen_string_literal: true

class K8::Shared::AcmeIssuer < K8::Base
  attr_accessor :email

  def initialize(email)
    super
    @email = email
  end
end
