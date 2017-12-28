require 'awesome_search/translator/scope'

module AwesomeSearch
  module Translator
    module Fulltext
      def self.apply(query_object, fulltext)
        return unless fulltext.present?
        query_object.tap do |search|
          case fulltext
          when String, Symbol
            search.fulltext fulltext.to_s
          when Array
            fulltext.each do |ft|
              apply(search, ft)
            end
          when Hash
            query = fulltext.delete(:query)
            search.fulltext(query) do
              fulltext.each do |method, args|
                method_mapper(self, method, args)
              end
            end
          else
            raise NotImplementedError
          end
        end
      end

      def self.method_mapper(query_object, method, options)
        case method
        when :boost
          apply_boost(query_object, options)
        when :boost_fields
          apply_boost_fields(query_object, options)
        when :fields
          apply_fields(query_object, options)
        when :phrase_fields
          apply_phrase_fields(query_object, options)
        when :phrase_slop
          apply_phrase_slop(query_object, options)
        when :query_phrase_slop
          apply_query_phrase_slop(query_object, options)
        else
          raise NotImplementedError
        end
      end

      def self.apply_boost(query_object, options)
        query_object.tap do |search|
          if options[:scope]
            search.boost(2.0) do
              Scope.apply(self, options[:scope])
            end
          else
            search.boost(2.0)
          end
        end
      end

      def self.apply_boost_fields(query_object, options)
        query_object.tap do |search|
          search.boost_fields options
        end
      end

      def self.apply_fields(query_object, options)
        query_object.tap do |search|
          search.fields *Array.wrap(options)
        end
      end

      def self.apply_phrase_fields(query_object, options)
        query_object.tap do |search|
          search.phrase_fields options
        end
      end

      def self.apply_phrase_slop(query_object, options)
        query_object.tap do |search|
          search.phrase_slop options
        end
      end

      def self.apply_query_phrase_slop(query_object, options)
        query_object.tap do |search|
          search.query_phrase_slop options
        end
      end
    end
  end
end
