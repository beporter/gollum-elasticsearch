# Abstract class that provides mappings for all necessary API methods.
# Additional backends must provide the methods defined here.

require 'gollum_search/elasticsearch/backend'

module GollumSearch
  module Backend

    # Must add a Gollum::Page into the search index.
    #def save(page)
    #end

    # Search the search provider for a query term. Results must be returned in the same format as Gollum::Wiki.search:
    # [
    #   [
    #     {
    #       :count=>6,
    #       :name=>"Bilbo-Baggins.md",
    #       :filename_count=>1,
    #       :context=>
    #       [
    #         "# Bilbo Baggins",
    #         "Bilbo Baggins is the protagonist of The [[Hobbit]] and also makes a few",
    #         "Tolkien]]'s fantasy writings. The story of The Hobbit featuring Bilbo is also",
    #         "Bilbo is the author of The Hobbit and translator of The Silmarillion.",
    #         "From [http://en.wikipedia.org/wiki/Bilbo_Baggins](http://en.wikipedia.org/wiki/Bilbo_Baggins)."
    #       ]
    #     },
    #     {
    #       :count=>1,
    #       :name=>"Data.csv",
    #       :filename_count=>0,
    #       :context=>[
    #         "Bilbo,Baggins"
    #       ]
    #     },
    #     {
    #       :count=>1,
    #       :name=>"Hobbit.md",
    #       :filename_count=>0,
    #       :context=>[
    #         "Bilbo-Baggins.md"
    #       ]
    #     },
    #     {
    #       :count=>1,
    #       :name=>"Home.textile",
    #       :filename_count=>0,
    #       :context=>[
    #         "This wiki is awesome. You can learn about [[Bilbo Baggins]] or some [[evil|Eye Of Sauron]] stuff."
    #       ]
    #     }
    #   ],
    #   ["bilbo"]
    # ]
    #def search(query)
    #end

    # TODO: Make this configurable. We should always be able to use `GollumSearch::Backend` and get the correct provider.
    include GollumSearch::Elasticsearch::Backend

  end
end
