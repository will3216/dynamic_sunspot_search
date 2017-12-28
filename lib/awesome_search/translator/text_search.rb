require 'awesome_search/translator/all'
require 'awesome_search/translator/any'
require 'awesome_search/translator/fulltext'

module AwesomeSearch
  module Translator
    module TextSearch
      def self.apply(query_object, options)
        return unless options.present?
        case options
        when Array
          options.each do |option|
            apply(query_object, option)
          end
        when Hash
          apply_text_search_hash(query_object, options)
        else
          raise NotImplementedError
        end
      end

      def self.apply_text_search_hash(query_object, options)
        All.apply(query_object, options.delete(:all))
        Any.apply(query_object, options.delete(:any))
        Fulltext.apply(query_object, options.delete(:fulltext))
        raise ArgumentError.new("Unknown keys detected: #{options.keys}") unless options.blank?
      end
    end
  end
end
