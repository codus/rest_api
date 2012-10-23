require 'rest-client'
require 'json'

module RestApi
  module RequestHandler
    module Client
      class << self
        def get url, params = {}
          parse_response(RestClient.get(url, :params => params))
        end

        def post url, params = {}
          parse_response(RestClient.post(url, params))
        end

        def put url, params = {}
          parse_response(RestClient.put(url, params))
        end
        
        def delete url, params = {}
          parse_response(RestClient.delete(url, :params => params))
        end

        def parse_response string_response
          begin 
            puts string_response
            return JSON.parse(string_response)
          rescue
            { :status => 500 }
          end
        end
      end
    end
  end
end
