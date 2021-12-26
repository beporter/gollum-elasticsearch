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
        backend.save(*payload(p))
      end

      def hook(committer, sha1)
        w = committer.wiki
        deltas = committer.parents[0].commit.diff.deltas
        changed_paths = deltas.map { |delta| [ delta.new_file[:path], delta.old_file[:path] ] }.flatten.uniq
        changed_paths.map { |path| page(w.page(path)) }
      end

      # Input and output must mimic `Gollum::Wiki.search(query)`
      def search(query)
        backend.search(query)
      end

      private

      # Define the data to index in the search database as a tuple containing
      # the "ID" for the page and all additional "fields".
      def payload(page)
        [
          page.url_path,
          {
            path: page.url_path,
            title: page.title || '',
            toc: page.toc_data || '',
            tags: page.metadata.fetch('tags', []),
            version_short: page.version_short || '',
            format: page.format || '',
            content: page.text_data || '',
          }
        ]
      end

    end
  end
end
