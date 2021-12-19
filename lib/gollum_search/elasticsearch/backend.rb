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
        connection.search(query)
      end

      private

      def connection()
        @conn ||= ::Elasticsearch::Client.new(
          url: ENV.fetch('ELASTICSEARCH_URL') { raise 'You must define ELASTICSEARCH_URL in your environment.' },
          transport_options: {
            request: {timeout: 10},
            headers: {content_type: 'application/json'},
          }.merge(options),
        )
      end

    end
  end
end
