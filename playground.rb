# This is a minimal proof of concept for taking git data and
# loading it into Elasticsearch.

# Run `dce gollum ruby playground.rb` to index the repo into Elasticsearch.
# Then visit: http://localhost:9200/_search?q=bilbo or ?q=ring


require 'bundler/setup'
require 'elasticsearch'
require 'gollum-lib'

es_conn = Elasticsearch::Client.new(
  url: ENV.fetch('ELASTICSEARCH_URL') { raise 'You must define ELASTICSEARCH_URL in your environment.' },
  transport_options: {
    request: {timeout: 5},
    headers: {content_type: 'application/json'},
  },
)
wiki_path = '/app/test/examples/lotr.git'
wiki = Gollum::Wiki.new(wiki_path)

wiki.pages.each do |page|
  pp page
  payload = {
    title: page.title,
    toc: page.toc_data,
    tags: page.metadata.fetch('tags', []),
    version_short: page.version_short,
    content: page.text_data,
  }
  es_conn.index(
    index: 'wiki',
    type: 'page',
    id: page.name,
    body: payload,
  )
end

# TODO: Convert this example into the already stubbed out GollumSearch::Elasticsearch::* classes, and integrate with the plugin at large.
# - Write a class/method that takes a single Wiki.page and indexes it in ES. Also consider monkeypatch in a Gollum::Page.search_data method that returns ES formatted data for easier use?

# - Write a Rake script that will batch-index an entire repo from a given file path (like above but "official".)
# - Write a search method that returns results compatible with Wiki.search() results.
# Figure out how to monkeypatch our search method on top of Gollum::Wiki.search: https://github.com/gollum/gollum-lib/blob/master/lib/gollum-lib/wiki.rb#L492 (This would be "easier" and less invasive than overriding the /gollum/search route.)
# Make this plugin able to register Gollum hooks for after_commit (to write the updated page into the ES index) and `Gollum::Hook.register(:post_wiki_initialize, :hook_id)` (we can save a reference to that wiki instance for use), and update "installation" docs for how to do that in your own Gollum wiki.


# Refs:
# - [Using raw Elasticsearch client](https://rubydoc.info/gems/elasticsearch-api)
# - [gollumb-lib's Page class](https://github.com/gollum/gollum-lib/blob/master/lib/gollum-lib/page.rb)
# - [ES Repository pattern](https://github.com/elastic/elasticsearch-rails/tree/main/elasticsearch-persistence#the-repository-pattern)
# - [Example ES Sinatra app](https://github.com/elastic/elasticsearch-rails/blob/main/elasticsearch-persistence/examples/notes/application.rb)
# - []()
# - []()
# - []()
# - []()
