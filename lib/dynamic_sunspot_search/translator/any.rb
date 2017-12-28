require 'dynamic_sunspot_search/translator/text_search'

module DynamicSunspotSearch
  module Translator
    module Any
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          search.any do
            TextSearch.apply(self, options)
          end
        end
      end
    end
  end
end
