require 'active_support/core_ext/hash/conversions'
require "rest_api/version"
require "rest_api/api"
require "rest_api/request_handler"
require "rest_api/custom_api_method_call"

module RestApi

  @@custom_methods = []

  # SETUP
  def self.setup
    yield self
  end

  def self.api_url
    self.api.url
  end

  def self.api_url=(value)
    if value.match(/.+\/$/)
      self.api.url = value
    else
      self.api.url = value + "/"
    end
  end
  
  # GYP api reference
  def self.api
    return RestApi::API
  end

  # GYP request reference
  def self.request
    RestApi::RequestHandler
  end

end
