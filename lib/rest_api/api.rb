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
  end
end