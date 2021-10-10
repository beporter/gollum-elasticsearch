require 'elasticsearch'

module Gollum
  module Elasticsearch
    class Client

      class << self
        attr_accessor :timeout
      end
      self.timeout = 10

      def self.connection()
        @conn ||= ::Elasticsearch::Client.new(
          url: ENV.fetch('ELASTICSEARCH_URL') { raise 'You must define ELASTICSEARCH_URL in your environment.' },
          transport_options: {request: {timeout: timeout}, headers: {content_type: 'application/json'}},
        )
      end

    end
  end
end
