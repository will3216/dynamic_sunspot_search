module AwesomeSearch
  module Translator
    module Without
      def self.apply(query_object, without_scope)
        return unless without_scope.present?
        query_object.tap do |search|
          case without_scope
          when Array
            return without_scope.map do |filter|
              apply(search, filter)
            end
          when Hash
            return without_scope.map do |key, value|
              case value
              when Hash
                value.map do |method, *args|
                  search.without(key).send(method, *args)
                end
              when /^range:.+\.\..+$/
                range_start, range_end = value.match(/^range:(.+)\.\.(.+)$/).values_at(1, 2)
                search.without(key, (range_start..range_end))
              else
                search.without(key, value)
              end
            end
          end
        end
      end
    end
  end
end
