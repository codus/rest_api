require "rest_api/request_handler/client"

module RestApi  
  module RequestHandler
    class << self 
      private
      def client
        RestApi::RequestHandler::Client
      end
    end

    def self.make_request request_type, request_url, request_params = nil
      request_params ||= {}
      begin      
        case request_type
          when :put
            client.put request_url, request_params
          when :post
            client.post request_url, request_params
          when :delete
            client.delete request_url, request_params
          when :get
            client.get request_url, request_params
          else
            raise Exception.new("Invalid request method")
        end
      rescue RestApi::Exceptions::ParseResponseException => e
        raise e
      rescue Exception => e
        raise RestApi::Exceptions::ApiConnectionException.new(e)
      end
    end

    # API CALL
    # make the request call if the method match with get,put,post or delete
    # the oder of the resources will be reversed
    # Example: method_missing :get_casas_from_usuarios will make a GET to <APIURL>/usuarios/casas
    # ----> request_params must can be a hash with the following keys 
    # 1) :resources_params - contains params for the corresponding resource. 
    #     The key of the param must has the name of the correspounding resource
    # 2) :request_params - params of the header)
    # ----> request_params must can be an Array of resources params
    # Example: method_missing :get_casas_from_usuarios, 4 will make a GET to <APIURL>/usuarios/4/casas
    # If the last item is a hash then it will be considered the :request_params

    def self.method_missing(method_id, *arguments)
      if request_type = API::RequestParser.get_request_type_from_method(method_id)
        params = get_params_from_array_arguments arguments
        request_url = API::RequestParser.get_url_from_method(method_id, params[:resources_params])
        make_request request_type, request_url, params[:request_params]
      else
        super
      end
    end

    def self.get_params_from_array_arguments arguments 
      params_hash = { }
      if arguments[0].is_a? Hash
        if (arguments[0].has_key?(:resources_params) || arguments[0].has_key?(:request_params))
          params_hash[:resources_params] = arguments[0][:resources_params]
          params_hash[:request_params] = arguments[0][:request_params] 
        else 
          #the only argument is the request params
          params_hash[:request_params] = arguments[0]
        end
      else
        if arguments.last
          params_hash[:request_params] = arguments.pop if arguments.last.is_a? Hash
        end
        params_hash[:resources_params] = Array.new arguments
      end
      params_hash.delete :request_params if params_hash[:request_params].nil?
      params_hash
    end

  end
end