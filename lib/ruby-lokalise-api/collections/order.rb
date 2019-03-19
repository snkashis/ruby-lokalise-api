module Lokalise
  module Collections
    class Order < Base
      class << self
        def endpoint(team_id, *_args)
          path_from teams: [team_id, 'orders']
        end
      end
    end
  end
end
