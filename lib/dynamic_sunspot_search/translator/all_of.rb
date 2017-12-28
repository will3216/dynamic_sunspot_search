require 'dynamic_sunspot_search/translator/scope'

module DynamicSunspotSearch
  module Translator
    module AllOf
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          search.all_of do
            Scope.apply(self, options)
          end
        end
      end
    end
  end
end
