module Lokalise
  module Collections
    class Key < Base
      class << self
        private

        def endpoint(project_id, *_args)
          "projects/#{project_id}/keys"
        end
      end
    end
  end
end