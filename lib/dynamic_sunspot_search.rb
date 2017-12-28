require 'active_support'
require 'active_support/core_ext'
require 'dynamic_sunspot_search/version'
require 'dynamic_sunspot_search/translator'

module DynamicSunspotSearch
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def dynamic_search(query_hash, search_options={})
      search(search_options) do
        Translator.translate(self, query_hash)
      end
    end
  end
end
