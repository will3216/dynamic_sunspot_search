require 'awesome_search/translator/with'
require 'awesome_search/translator/without'

module AwesomeSearch
  module Translator
    module Facet
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          case options
          when String, Symbol, Array
            search.facet *options
          when Hash
            fields = options.values_at(:field, :fields).flatten.compact
            exclude_filter = get_exclude_filter(search, options.delete(:exclude))
            search.facet(*fields, exclude: exclude_filter)
          else
            raise NotImplementedError
          end
        end
      end

      def self.get_exclude_filter(query_object, options)
        case options
        when Array
          options.map do |option|
            get_exclude_filter(query_object, option)
          end.flatten
        when Hash
          [
            With.apply(query_object, options.delete(:with)),
            Without.apply(query_object, options.delete(:without)),
          ].flatten.compact
        else
          raise NotImplementedError
        end
      end
    end
  end
end
