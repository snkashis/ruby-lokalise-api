module Lokalise
  module Resources
    class Contributor < Base
      class << self
        def endpoint(project_id, contributor_id = nil)
          path_from projects: project_id,
                    contributors: contributor_id
        end
      end
    end
  end
end
