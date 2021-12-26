# This config file is injected into the local Docker Compose environment
# for the purposes of engaging the GollumSearch::Middleware plugin
# in front of the Gollum app, and configuring a post-commit hook to update
# the index with saved page changes.

$stderr.puts '!!! Rack config engaged !!!'

require_relative 'lib/gollum_search.rb'
#use GollumSearch::Middleware

# Monkey-patch `Gollum::Wiki.search` to use GollumSearch::Indexer.search instead.
# This is (arguably) cleaner than overriding the entire route with Sinatra middleware.
module Gollum
  class Wiki
    alias search_original search
    def search(query)
      $stderr.puts "Query = #{query}"
      begin
        GollumSearch::Indexer.search(query)
      rescue Faraday::Error # Fall back on any error to native Gollum grep search.
        return search_original(query)
      end
    end
  end
end

Gollum::Hook.register(:post_commit, :update_search_index) do |committer, sha1|
  GollumSearch::Indexer.hook(committer, sha1)
end

require 'gollum/app'
wiki_path = '/app/test/examples/lotr.git'
wiki_options = {}
Precious::App.set(:gollum_path, wiki_path)
Precious::App.set(:wiki_options, wiki_options)
run Precious::App
#test2
