require 'active_support'
require 'active_support/core_ext'
require 'awesome_search/version'
require 'awesome_search/translator'

module AwesomeSearch
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def awesome_search(query_hash, search_options={})
      search(search_options) do
        Translator.translate(self, query_hash)
      end
    end
  end
end
