require 'bigdecimal'

module DynamicSunspotSearch
  module Translator
    module BoostRecency
      # Boost by recency: https://wiki.apache.org/solr/FunctionQuery#Date_Boosting
      def self.apply(query_object, options)
        return unless options.present?
        query_object.tap do |search|
          Array.wrap(options).each do |recency_boost|
            apply_recency_boost(query_object, recency_boost)
          end
        end
      end

      def self.apply_recency_boost(query_object, recency_boost)
        return unless recency_boost.present?
        field = recency_boost.delete(:field)
        half_life = recency_boost.delete(:half_life)
        query_object.tap do |search|
          search.adjust_solr_params do |sunspot_params|
            sunspot_params[:defType] = 'edismax'
            sunspot_params[:boost] = build_boost_string(field, half_life)
          end
        end
      end

      def self.build_boost_string(field, half_life)
        half_life_ms = calculate_half_life_ms(half_life).to_i
        half_life_recip = BigDecimal((1.0/(half_life_ms)).to_s).to_s('E').downcase
        "recip(ms(NOW,#{field.to_s}_dt),#{half_life_recip},100,1)"
      end

      def self.calculate_half_life_ms(options)
        options.reduce(0) do |half_life_ms, (period, value)|
          half_life_ms += value.to_f.send(period.to_sym).to_i*1000
        end
      end
    end
  end
end
