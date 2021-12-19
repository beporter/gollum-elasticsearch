# Gollum + Search

Aims to improve the [Gollum wiki project](https://github.com/gollum/gollum)'s default `git grep`-based searching by integrating Elasticsearch features. A secondary goal is to allow for additional search services to be plugged into Gollum via this one.

:warning: This is all very much pre-release! The current version doesn't actually do anything yet.

* [ ] Improved relevancy of search results.
* [ ] Ability to tune search results for specific topic domains.
* [ ] Find-as-you-type search results.
* [ ] Perhaps improved search performance in very large wikis(?) (Should be tested!)
* [ ] FUTURE: Per-user search conversion tracking.
* [ ] FUTURE: Make this project pluggable to support additional search backends.

Based on gollum/gollum#1768.


## Requirements

* An active and functional [Gollum](https://github.com/gollum/gollum#installation) installation.
* An available [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html) v7+ server instance.
  * A Docker container is provided for development of this plugin.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gollum_search', '~> LATEST_VERSION'
```

Then execute `bundle`.

Or install the gem yourself:

```shell
$ gem install gollum_search
```


## Configuration

TODO: Explain how to active that plugin in Gollum. Hopefully just adding a line to your gollum config file.


## Usage

Creating (or recreating) an index can be done from the command line using `bundle exec gollum_search_reindex /path/to/your/wiki branch_name`.

This plugin is implemented as Rack middleware that overrides the `/gollum/search` request path. This means you must run Gollum as a Rack app via `config.ru` and inject this plugin _before_ Gollum.

```ruby
# config.ru

require 'gollum_search'
use GollumSearch::Middleware

# Trigger "live" updates to the index as pages are edited.
Gollum::Hook.register(:post_commit, :update_search_index) do |committer, sha1|
  GollumSearch::Indexer.hook(committer, sha1)
end

require 'gollum/app'
Precious::App.set(:gollum_path, '/path/to/your/wiki/repo/dir')
run Precious::App
```

This plugin uses Elasticsearch by default and therefore looks for an `ELASTICSEARCH_URL` to establish a connection to Elasticsearch. This can be defined in the above config.ru file, or in the runtime environment for your server. In development, this is set by the `docker-compose.yml` file to point to the elasticsearch Docker container.

Please check [config.ru](config.ru) for example usage. Further documentation about [launching Gollum via Rack](https://github.com/gollum/gollum/wiki/Gollum-via-Rack) is available in [Gollum's own wiki](https://github.com/gollum/gollum/wiki/)



## Contributing

### Code of Conduct

Everyone interacting in the gollum_search project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/beporter/gollum_search/blob/master/CODE_OF_CONDUCT.md).


### Getting Help or Reporting Issues

[Create an issue](https://github.com/beporter/gollum_search/issues).

TODO: Better details.


### Development

* [Create an issue](https://github.com/beporter/gollum_search/issues) to propose and discuss the contribution.
  * The authors have little time to maintain this project. Your contributions are invited, but we wish to not waste anyone's time. A quick conversation to determine alignment and fit is usually a good investment.
* If the contribution is a good fit, clone the repo, start a topic branch, and open a pull request.

#### Workflow

* Clone the repository.
* Run `docker-compose up` to launch the development environment, which contains a ruby container running gollum and a test wiki, and an Elasticsearch container.
* Visit http://localhost:4567 to check the running copy of Gollum with this plugin injected.
  * Changes to the code in this plugin should be reloaded automatically.
  * You can override the exposed port by creating a local `.env` file and placing `GOLLUM_PORT=4568` in it.
  * You can confirm that the gollum container can reach the elasticsearch container by running `docker compose run gollum bash`, then `curl $ELASTICSEARCH_URL/_cluster/state?pretty`.
* Visit http://localhost:9200/ to check the Elasticsearch instance.
  * You can override the exposed port by creating a local `.env` file and placing `ELASTICSEARCH_PORT=9201` in it.
* All normal ruby/bundler commands should be _prefixed_ with `docker compose exec gollum YOUR COMMAND HERE`.

To check the local docker elasticsearch index:

* Run `docker-compose exec gollum exe/gollum_search_reindex /app/test/examples/lotr.git`
* Visit: http://localhost:9200/_search?q=bilbo or ?q=ring


#### Testing

It is recommended to run the test suite inside the provided Docker Compose environment.

* `docker-compose gollum bundle exec rspec` - The test suite should continue to pass.
* `docker-compose gollum bundle exec rubocop` - Rubocop should emit no warnings or errors.


#### Releasing

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Copyright & License

Copyright &copy; 2021 Brian Porter.

This software is released under the [MIT License](LICENSE).


## TODO

- Write a search method that returns results compatible with Wiki.search() results.
- Figure out how to monkeypatch our search method on top of `Gollum::Wiki.search`: https://github.com/gollum/gollum-lib/blob/master/lib/gollum-lib/wiki.rb#L492 (This would be "easier" and less invasive than overriding the /gollum/search route.)
- Make this plugin able to register Gollum hooks for after_commit (to write the updated page into the ES index) and `Gollum::Hook.register(:post_wiki_initialize, :hook_id)` (we can save a reference to that wiki instance for use), and update "installation" docs for how to do that in your own Gollum wiki.
- Register our own sinatra routes for search-as-you-type.
- Override the necessary Mustache templates to offer search as you type.
  - Pull in the **minimum** necessary Javascript to query the new route and use the results.

### Refs
- [Using raw Elasticsearch client](https://rubydoc.info/gems/elasticsearch-api)
- [gollumb-lib's Page class](https://github.com/gollum/gollum-lib/blob/master/lib/gollum-lib/page.rb)
- [ES Repository pattern](https://github.com/elastic/elasticsearch-rails/tree/main/elasticsearch-persistence#the-repository-pattern)
- [Example ES Sinatra app](https://github.com/elastic/elasticsearch-rails/blob/main/elasticsearch-persistence/examples/notes/application.rb)
