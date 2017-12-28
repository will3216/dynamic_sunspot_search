require 'awesome_search/translator/text_search'

module AwesomeSearch
  module Translator
    module All
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          search.all do
            TextSearch.apply(self, options)
          end
        end
      end
    end
  end
end
