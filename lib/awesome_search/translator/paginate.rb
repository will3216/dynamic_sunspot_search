module AwesomeSearch
  module Translator
    module Paginate
      def self.apply(query_object, pagination)
        return unless pagination.present?
        query_object.tap do |search|
          Array.wrap(pagination).each do |paging|
            search.paginate paging
          end
        end
      end
    end
  end
end
