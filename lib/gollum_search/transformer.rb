require 'parslet'

# Ref: https://asok.github.io/ruby/2016/10/03/parslet.html

module GollumSearch
  class Transform < Parslet::Transform

    rule(filter_field: simple(:filter_field), value: simple(:value)) do
      {
        filter: {
          term: {
            filter_field => value
          }
        }
      }
    end

    rule(match_field: simple(:match_field), value: simple(:value)) do
      {:match => { match_field => value}}
    end

    rule(subqueries: subtree(:subqueries)) do |dict|
      # dict is already transformed Hash using the rules defined above
      dict = dict[:subqueries]

      output = {
        filtered: {
          # look if there's a `match` rule, if not include the `match_all` clause
          query: dict.detect(-> { {match_all: {}} }){ |d| d[:match] },
        }
      }

      filters = dict.map{ |d| d[:filter] }.compact

      if filters.any?
        # if any filters are present merge them under `filtered` key
        output[:filtered].merge!(filter: {and: filters})
        output
      else
        output
      end
    end
  end
end
