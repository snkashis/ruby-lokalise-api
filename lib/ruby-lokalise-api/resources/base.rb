module Lokalise
  module Resources
    class Base
      extend Lokalise::Request
      extend Lokalise::Utils::AttributeHelpers
      include Lokalise::Utils::AttributeHelpers
      extend Lokalise::Utils::EndpointHelpers

      attr_reader :raw_data, :project_id, :client, :path

      # Initializes a new resource based on the response
      #
      # @param response [Hash]
      # @return [Lokalise::Resources::Base]
      def initialize(response)
        populate_attributes_for response['content']

        @raw_data = response['content']
        @project_id = response['content']['project_id']
        @client = response['client']
        @path = infer_path_from response
      end

      class << self
        # Dynamically add attribute readers for each inherited class.
        # Attributes are defined in the `data/attributes.json` file.
        # Also set the `ATTRIBUTES` constant to assign values to each attribute later when
        # the response arrives from the API
        def inherited(subclass)
          klass_attributes = attributes_for subclass
          subclass.class_exec do
            const_set :ATTRIBUTES, klass_attributes
            attr_reader(*klass_attributes)
          end
          super
        end

        # Defines CRUD instance methods. In the simplest case it delegates work to the
        # class method. In more complex case it is possible to specify sub-path and the
        # class method name to call.
        # Usage: `supports :update, :destroy, [:complex_method, '/sub/path', :update]`
        def supports(*methods)
          methods.each do |m_data|
            method_name, sub_path, c_method = m_data.is_a?(Array) ? m_data : [m_data, '', m_data]
            define_method method_name do |params = {}|
              path = instance_variable_get(:@path)
              # If there's a sub_path, preserve the initial path to allow further chaining
              params = params.merge(_initial_path: path) if sub_path
              self.class.send c_method, instance_variable_get(:@client),
                              path + sub_path, params
            end
          end
        end

        # Fetches a single record
        def find(client, path, params = {})
          new get(path, client, params)
        end

        # Creates one or multiple records
        def create(client, path, params)
          response = post path, client, params

          object_from response, params
        end

        # Updates one or multiple records
        def update(client, path, params)
          response = put path, client, params

          object_from response, params
        end

        # Destroys records by given ids
        def destroy(client, path, params = {})
          delete(path, client, params)['content']
        end

        private

        # Instantiates a new resource or collection based on the given response
        def object_from(response, params)
          model_class = name.base_class_name
          data_key_plural = data_key_for model_class, true
          # Preserve the initial path to allow chaining
          response['path'] = params.delete(:_initial_path) if params.key?(:_initial_path)

          if response['content'].key?(data_key_plural)
            produce_collection model_class, response, params
          else
            produce_resource model_class, response
          end
        end

        def produce_resource(model_class, response)
          data_key_singular = data_key_for model_class

          if response['content'].key? data_key_singular
            data = response['content'].delete data_key_singular
            response['content'].merge! data
          end

          new response
        end

        def produce_collection(model_class, response, params)
          Module.const_get("Lokalise::Collections::#{model_class}").new(response, params)
        end
      end

      # Generates path for the individual resource based on the path for the collection
      def infer_path_from(response)
        id_key = id_key_for self.class.name.base_class_name
        data_key = data_key_for self.class.name.base_class_name

        path_with_id response, id_key, data_key
      end

      def path_with_id(response, id_key, data_key)
        # Some resources do not have ids at all
        return nil unless response['content'].key?(id_key) || response['content'].key?(data_key)

        # ID of the resource
        id = id_from response, id_key, data_key

        path = response['path'] || response['base_path']
        # If path already has id - just return it
        return path if path.match?(/#{id}\z/)

        # Otherwise this seems like a collection path, so append the resource id to it
        path.remove_trailing_slash + "/#{id}"
      end

      def id_from(response, id_key, data_key)
        # Content may be `{"project_id": '123', ...}` or {"snapshot": {"snapshot_id": '123', ...}}
        # Sometimes there is an `id_key` but it has a value of `null`
        # (for example when we do not place the actual order but only check its price).
        # Therefore we must explicitly check if the key is present
        return response['content'][id_key] if response['content'].key?(id_key)

        response['content'][data_key][id_key]
      end

      # Store all resources attributes under the corresponding instance variables.
      # `ATTRIBUTES` is defined inside resource-specific classes
      def populate_attributes_for(content)
        data_key = data_key_for self.class.name.base_class_name

        self.class.const_get(:ATTRIBUTES).each do |attr|
          value = if content.key?(data_key) && content[data_key].is_a?(Hash)
                    content[data_key][attr]
                  else
                    content[attr]
                  end

          instance_variable_set "@#{attr}", value
        end
      end
    end
  end
end
