module AwesomeSearch
  module Translator
    module With
      def self.apply(query_object, with_scope)
        return unless with_scope.present?
        query_object.tap do |search|
          case with_scope
          when Array
            return with_scope.map do |filter|
              apply(search, filter)
            end
          when Hash
            return with_scope.map do |key, value|
              case value
              when Hash
                value.map do |method, args|
                  search.with(key).send(method, *Array.wrap(args))
                end
              when /^range:.+\.\..+$/
                range_start, range_end = value.match(/^range:(.+)\.\.(.+)$/).values_at(1, 2)
                search.with(key, (range_start..range_end))
              else
                search.with(key, value)
              end
            end
          end
        end
      end
    end
  end
end
