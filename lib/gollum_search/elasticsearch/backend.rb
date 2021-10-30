require 'elasticsearch'

module GollumSearch
  module Elasticsearch
    module Backend

      def save(page)
        connection.index(
          index: 'wiki',
          type: 'page',
          id: page.name,
          body: payload(page),
        )
      end

      def search(query)
        connection.search(query)
      end

      private

      def connection()
        @conn ||= ::Elasticsearch::Client.new(
          url: ENV.fetch('ELASTICSEARCH_URL') { raise 'You must define ELASTICSEARCH_URL in your environment.' },
          transport_options: {
            request: {timeout: 10},
            headers: {content_type: 'application/json'},
          },
        )
      end

      def payload(page)
        {
          path: page.url_path,
          title: page.title,
          toc: page.toc_data,
          tags: page.metadata.fetch('tags', []),
          version_short: page.version_short,
          format: page.format,
          content: page.text_data,
        }
      end

    end
  end
end
