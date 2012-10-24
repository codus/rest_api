require 'set'

module RestApi
  module API
    module RequestParser
      class << self
        def get_url_from_method method_id, resources_params = nil
          tokens_array = get_url_tokens_from_method method_id
          tokens_array = insert_resources_params_in_tokens_array tokens_array, resources_params unless (resources_params.nil? || resources_params.empty?)
          API.url + tokens_array.join("/")
        end

        def get_url_from_map array_resources_names, resources_map, resources_params = nil
          # insert the params before translate the url with a map so the rousources_params
          # must be relative the array resrouces_names
          # tokens_array = array_resources_names

          tokens_array = insert_resources_params_in_tokens_array array_resources_names, resources_params unless (resources_params.nil? || resources_params.empty?)
          tokens_array ||= array_resources_names
          tokens_array_mapped = tokens_array.map do |resource_name|
            if resources_map.respond_to?(resource_name.to_sym)
              resources_map.send(resource_name.to_sym) 
            else
              resource_name
            end
          end

          API.url + tokens_array_mapped.join("/")
        end

        def get_request_type_from_method method_id
          request_type = method_id.to_s.match(/^get|put|delete|post/i)
          request_type.nil? ? request_type : request_type[0].to_sym 
        end

        def get_url_tokens_from_method method_id
          method_name_without_pronouns = method_id.to_s.gsub(/_(in|of|from)_/,"_").gsub(/(put|get|post|delete)_/, "")
          method_name_with_reserved_mask = method_name_without_pronouns
          ensured_resource_names.each { |ensured_resource_name| 
            method_name_with_reserved_mask.gsub!(ensured_resource_name, ensured_resource_name.split("_").join("+"))
          }
          url_tokens = method_name_with_reserved_mask.split("_").map { |resource_name_masked| resource_name_masked.gsub("+", "_")}
          url_tokens.reverse
        end

        def insert_resources_params_in_tokens_array tokens_array, resources_params
          resources_params_hash = {}
          tokens_array_copy = Array.new tokens_array #copy so the original remains intact
          if resources_params.is_a? Hash
            resources_params_hash = resources_params
          else  
            tokens_array_copy.each_with_index { |token, index| 
              resources_params_hash[token.to_sym] = resources_params[index] unless resources_params[index].nil?
            }
          end
          params_insert_positions = Array.new
          tokens_array_copy.each_with_index do |token, index|
            params_insert_positions << { :param => resources_params_hash[token.to_sym], :position => (index + 1)} if resources_params_hash.has_key? token.to_sym
          end

          params_insert_positions.inject(0) do |insert_offset,insert_position_hash|
            insert_position = insert_position_hash[:position] + insert_offset
            tokens_array_copy.insert(insert_position, insert_position_hash[:param].to_s)
            insert_offset = insert_offset + 1
          end

          tokens_array_copy
        end

        def pluralize_resource resource_name
          (resource_name.match(/(\d+|s)$/).nil?) ? (resource_name + "s") : (resource_name)
        end

        def ensure_resource_name *resource_names
          if resource_names.length == 0
            raise ArgumentError.new("wrong number of arguments (0 for N)")
          else
            resource_names.each do |resource_name|
              ensured_resource_names << resource_name.to_s
            end
          end
        end

        def reset_ensure_resource_name
          @ensured_resource_names = Set.new
        end

        private
        def ensured_resource_names
          @ensured_resource_names ||= Set.new
          @ensured_resource_names
        end
      end
    end
  end
end
