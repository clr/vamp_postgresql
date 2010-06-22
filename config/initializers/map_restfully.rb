module ActionDispatch
  module Routing
    class Mapper
      module MapRestfully

        def map_restfully(resource_name, options={})
          singular = resource_name.to_s
          plural = options[:plural] || singular.pluralize
          %w(get post put delete).each do |verb|
            match({"#{singular}(/:id(.:format))" => "#{plural}##{verb}", :via => verb, :as => 'widget'}.merge(options))
            match "#{plural}(/:ids(.:format))" => "#{plural}##{verb}s", :via => verb, :as => 'widgets'
          end
        end
      end

      include MapRestfully

    end
  end
end
