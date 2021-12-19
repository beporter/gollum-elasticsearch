require 'gollum-lib'
require 'gollum_search'

module GollumSearch
  class Indexer
    @@backend = nil
    class <<self
      def backend
        if @@backend.nil?
          require 'gollum_search/elasticsearch/backend'
          @@backend = GollumSearch::Elasticsearch::Backend.new()
        end
        @@backend
      end

      def backend=(backend)
        %w[save search].each do |method|
          raise "Backend does not respond to #{method}." unless backend.respond_to?(method)
        end

        @@backend = backend
      end

      def reindex(wiki)
        raise "Not a Gollum::Wiki instance: #{wiki.to_s}" unless wiki.is_a?(Gollum::Wiki)
        wiki.pages.map do |p|
          page(p)
        end
      end

      def page(p)
        @@backend.save(*payload(p))
      end

      def hook(committer, sha1)
        wiki = committer.wiki
        committer.diff.deltas
          .map { |delta| [ delta.new_file[:path], delta.old_file[:path] ] }
          .flatten
          .uniq
          .map { |path| page(wiki.page(path)) }

        # Precious::App.settings.gollum_path
        # GollumSearch::Indexer.page(committer.index.tree.TODO_GET_PAGES_MODIFIED)
        # wiki.commit_for('HEAD').commit.diff.deltas.each do |delta|
        #   backend.update(wiki.page(delta.new_file[:path]))
        #   backend.update(wiki.page(delta.old_file[:path]))
        # end

        # wiki = Gollum::Wiki.new('wiki', { ref: 'main'})
      end

      private

      # Define the data to index in the search database as a tuple containing
      # the "ID" for the page and all additional "fields".
      def payload(page)
        [
          page.dig('url_path'),
          {
            path: page.dig('url_path'),
            title: page.dig('title') || '',
            toc: page.dig('toc_data') || '',
            tags: page.dig('metadata', 'tags') || [],
            version_short: page.dig('version_short') || '',
            format: page.dig('format') || '',
            content: page.dig('text_data') || '',
          }
        ]
      end

    end
  end
end
