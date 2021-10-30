module Gollum
  module Elasticsearch
    class WikiPage

      def find(name)
      end

      def search_data
      end

    end
  end
end

# Intent here is to create a two-part persistence layer (Data object + Repository pattern) that links ES index records with Gollum::Page objects: https://www.elastic.co/guide/en/elasticsearch/client/ruby-api/7.x/persistence.html

