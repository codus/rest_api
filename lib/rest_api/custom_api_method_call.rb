require 'ostruct'
require 'set'

module RestApi 
  @@mapped_methods = Set.new
  # custom map to api call
  # Example: 
  # RestApi.map_custom_api_method :put, :casas_in_usuarios do |map| 
  #   map.casas = "casinha"
  #   map.usuarios = "usuarionsinhos"
  # end
  # RestApi.request.put_casas_in_usuarios -> PUT "<APIURL>/usuarionsinhos/casinha"
  # RestApi.request.put_casas_in_usuarios(5) -> PUT "<APIURL>/usuarionsinhos/5/casinha"
  # RestApi.map_custom_api_method :get, :boss_from_offices
  # RestApi.request.get_boss_from_offices -> GET "<APIURL>/offices/boss"
  # RestApi.request.get_boss_from_offices(:resources_params => { :offices => 5} ) -> GET "<APIURL>/offices/5/boss"

  def self.map_custom_api_method request_type, request_resources
    array_resources_names = API::RequestParser.get_url_tokens_from_method request_resources
    
    # initialize the resource map and pass to the yield
    resources_map = OpenStruct.new
    if block_given?
      yield resources_map
    end

    # complete the resource map is necessary
    array_resources_names.each do |resource_name|
      resources_map.send("#{resource_name}=", resource_name) unless resources_map.respond_to?(resource_name.to_sym)
    end

    # create the method
    method_name = "#{request_type}_#{request_resources}"

    self.mapped_methods << method_name.to_sym
  
    RequestHandler.class_eval do
      eigenclass = class << self
        self
      end 

      eigenclass.class_eval do
        # self = RestApi::RequestHandler
        define_method method_name do |*arguments|
          params = get_params_from_array_arguments arguments
          request_url = API::RequestParser.get_url_from_map(array_resources_names, resources_map, params[:resources_params])
          make_request request_type, request_url, params[:request_params]
        end
      end
    end
  end

  def self.unmap_resources
    self.mapped_methods.each do |mapped_method_id|
      RequestHandler.class_eval do
        eigenclass = class << self
          self
        end 

        eigenclass.class_eval do
          undef_method mapped_method_id
        end
      end
    end
    @@mapped_methods = Set.new
  end

  def self.mapped_methods
    @@mapped_methods
  end

  def self.add_restful_api_methods request_resources, &block
    [:get, :put, :post, :delete].each do |request_type|
      self.map_custom_api_method request_type, request_resources, &block
    end
  end
end
