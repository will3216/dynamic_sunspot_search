module AwesomeSearch
  module Translator
    module OrderByFunction
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          search.order_by_function(*options)
        end
      end
    end
  end
end
