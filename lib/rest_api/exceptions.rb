module RestApi  
  module Exceptions
    class ParseResponseException < Exception
    
      attr_accessor :response_body
      
      def initialize(args = {})
        @response_body = args[:response_body]
        @error = args[:error]
        super(@error)
      end
    end

    class ApiConnectionException < Exception; end;
  end
end