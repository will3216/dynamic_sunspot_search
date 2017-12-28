require 'awesome_search/translator/all_of'
require 'awesome_search/translator/any_of'
require 'awesome_search/translator/with'
require 'awesome_search/translator/without'

module AwesomeSearch
  module Translator
    module Scope
      def self.apply(query_object, options)
        return unless options.present?
        case options
        when Array
          options.each do |option|
            apply(query_object, option)
          end
        when Hash
          apply_scope_hash(query_object, options)
        else
          raise NotImplementedError
        end
      end

      def self.apply_scope_hash(query_object, options)
        Scope.apply(query_object, options.delete(:scope))
        With.apply(query_object, options.delete(:with))
        Without.apply(query_object, options.delete(:without))
        AnyOf.apply(query_object, options.delete(:any_of))
        AllOf.apply(query_object, options.delete(:all_of))
        raise ArgumentError.new("Unknown keys detected: #{options.keys}") unless options.blank?
      end
    end
  end
end
