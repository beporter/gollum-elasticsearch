require 'elasticsearch'

module GollumSearch
  module Elasticsearch
    class Backend

      def initialize(options = {})
        @options = options
      end

      def save(id, attributes)
        connection.index(
          index: 'wiki',
          type: 'page',
          id: id,
          body: attributes,
        )
      end

      def search(query)
        request = { q: query }

        #request = {body: { query: { match: query } } }
        # TODO: Split "exact terms": https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-wildcard-query.html
        # TODO: Process `f*zzy` wildcards: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-wildcard-query.html
        # TODO: Handle boolean operations: https://www.elastic.co/guide/en/elasticsearch/reference/current/compound-queries.html

        results = connection.search(index: 'wiki', **request)

        pp results
        hits = results.dig('hits', 'hits') || []
        payload = hits.map {|hit| format(hit)}

        [payload, [query]]
      end

      def format(hit)
        {
          count: 1, # TODO: Extract from `hit`
          name: hit.fetch('_id'),
          filename_count: 0, # TODO: Extract from document `id` from `hit.`
          context: hit.dig('_source', 'content'), # TODO: Extract from `hit`
        }
      end


      # Public: Search all pages for this wiki.
      #
      # query - The string to search for
      #
      # Returns an Array with Objects of page name and count of matches
      # def search(query)
      #   options = {:path => page_file_dir, :ref => ref}
      #   search_terms = query.scan(/"([^"]+)"|(\S+)/).flatten.compact.map {|term| Regexp.escape(term)}
      #   search_terms_regex = search_terms.join('|')
      #   query = /^(.*(?:#{search_terms_regex}).*)$/i
      #   results = @repo.git.grep(search_terms, options) do |name, data|
      #     result = {:count => 0}
      #     result[:name] = extract_page_file_dir(name)
      #     result[:filename_count] = result[:name].scan(/#{search_terms_regex}/i).size
      #     result[:context] = []
      #     if data
      #       begin
      #         data.scan(query) do |match|
      #           result[:context] << match.first
      #           result[:count] += match.first.scan(/#{search_terms_regex}/i).size
      #         end
      #       rescue ArgumentError # https://github.com/gollum/gollum/issues/1491
      #         next
      #       end
      #     end
      #     ((result[:count] + result[:filename_count]) == 0) ? nil : result
      #   end
      #   [results, search_terms]
      # end

      def connection()
        @conn ||= ::Elasticsearch::Client.new(**{
          url: ENV.fetch('ELASTICSEARCH_URL') { raise 'You must define ELASTICSEARCH_URL in your environment.' },
          transport_options: {
            request: {timeout: 10},
            headers: {content_type: 'application/json'},
          }}.merge(@options) {|key, a, b| a.merge(b) },
        )
      end

    end
  end
end
