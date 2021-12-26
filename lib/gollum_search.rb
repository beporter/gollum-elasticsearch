require 'gollum_search/version'
require 'gollum_search/indexer'
require 'gollum_search/middleware'

module GollumSearch
  # Define a monkey-patch for `Gollum::Wiki.search` to use
  # GollumSearch::Indexer.search instead. This is (arguably) cleaner than
  # overriding the entire `/gollum/search` route with Sinatra middleware.
  module Patch
    def search(query)
      $stderr.puts "Query = #{query}"
      begin
        Indexer.search(query)
      rescue Faraday::Error # Fall back on any error to native Gollum grep search.
        return search_original(query)
      end
    end
  end

  def self.apply_patch
    # Monkey-patch Gollum::Wiki.
    wiki_klass = begin
      Kernel.const_get('Gollum::Wiki')
    rescue NameError
    end
    wiki_klass.alias_method(:search_original, :search)
    wiki_klass.prepend(GollumSearch::Patch) if wiki_klass

    # Also register a callback to index edited pages.
    Gollum::Hook.register(:post_commit, :update_search_index) do |committer, sha1|
      Indexer.hook(committer, sha1)
    end
  end

end

GollumSearch.apply_patch
