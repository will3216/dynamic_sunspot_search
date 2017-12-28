require 'awesome_search/translator/facet'
require 'awesome_search/translator/field_list'
require 'awesome_search/translator/order_by'
require 'awesome_search/translator/order_by_function'
require 'awesome_search/translator/paginate'
require 'awesome_search/translator/scope'
require 'awesome_search/translator/text_search'

module AwesomeSearch
  module Translator
    def self.translate(query_object, query_hash)
      query = query_hash.deep_dup.deep_symbolize_keys
      query_object.tap do |search|
        TextSearch.apply(search, query.extract!(:fulltext, :all, :any))
        Scope.apply(search, query.extract!(:with, :without, :any_of, :all_of, :scope))
        FieldList.apply(search, query.delete(:field_list))
        OrderBy.apply(search, query.delete(:order_by))
        OrderByFunction.apply(search, query.delete(:order_by_function))
        Paginate.apply(search, query.delete(:paginate))
        Facet.apply(search, query.delete(:facet))
        raise ArgumentError.new("Unknown keys detected: #{options.keys}") unless query.blank?
      end
    end
  end
end
