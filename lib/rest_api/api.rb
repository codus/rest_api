require "rest_api/api/request_parser"

module RestApi  
  module API
    @@custom_calls = []

    def self.url
      @@url
    end

    def self.url=(value)
      if value.match(/.+\/$/)
        @@url = value
      else
        @@url = value + "/"
      end
    end

    def self.api_key_name
      @@api_key_name = "" unless defined?(@@api_key_name)
      @@api_key_name
    end

    def self.api_key_name=(value)
      @@api_key_name=value
    end

    def self.api_key_value
      @@api_key_value = "" unless defined?(@@api_key_value)
      @@api_key_value
    end

    def self.api_key_value=(value)
      @@api_key_value=value
    end
  end
end