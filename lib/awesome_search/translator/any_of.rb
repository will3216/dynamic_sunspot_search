require 'awesome_search/translator/scope'

module AwesomeSearch
  module Translator
    module AnyOf
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          search.any_of do
            Scope.apply(self, options)
          end
        end
      end
    end
  end
end
