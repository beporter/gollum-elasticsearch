require 'gollum_search/elasticsearch/client'

module GollumSearch
  module Elasticsearch
    class Index
      def self.for_wiki(wiki)
        @es ||= GollumSearch::Elasticsearch::Client.connection
        wiki.pages.each do |page|
          # Construct the proper payload for ES.
          # Use Gollum::Elasticsearch::Client to push an index entry into ES, keyed on the page name.

          # TODO: Push into ES in batches.
        end
      end
    end
  end
end
