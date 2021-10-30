require 'gollum-lib'
require 'gollum_search/backend'

module GollumSearch
  class Indexer

    # Mix in methods from the configured search provider.
    include GollumSearch::Backend

    def initialize(path)
      @path = path
    end

    def reindex()
      wiki.pages.each do |page|
        save(page)
      end
    end


    private

    def wiki()
      @wiki ||= Gollum::Wiki.new(@path)
    end

  end
end
