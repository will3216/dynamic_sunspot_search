module AwesomeSearch
  module Translator
    module OrderBy
      def self.apply(query_object, order_by)
        return unless order_by.present?
        query_object.tap do |search|
          Array.wrap(order_by).each do |order_options|
            case order_options
            when Hash
              field, direction = order_options.first
              search.order_by(field, direction)
            when Symbol, String
              search.order_by(order_options)
            else
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end
