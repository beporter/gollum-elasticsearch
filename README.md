# Gollum + Elasticsearch

Aims to integrate Elasticsearch features into the Gollum wiki project.

* [ ] Improved relevancy of search results.
* [ ] Ability to tune search results for specific topic domains.
* [ ] Find-as-you-type search results.
* [ ] Perhaps improved search performance in very large wikis(?) (Should be tested!)
* [ ] FUTURE: Per-user search conversion tracking.

Based on gollum/gollum#1768.


## Requirements

* An active and functional [Gollum](https://github.com/gollum/gollum#installation) installation.
* An available [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html) v7+ server instance.
  * A Docker container is provided for development of this plugin.


## Installation

TODO: Explain how to install. Probably either `gem 'gollum-elasticsearch', '~> LATEST_VERSION'` in your Gemfile or `gem install gollum-elasticsearch` globally.


## Configuration

TODO: Explain how to active that plugin in Gollum. Hopefully just adding a line to your gouum config file.


## Usage

TODO: Explain how to use the plugin. The design goal is that installing this gem and calling a single setup method in your gollum config is enough to "hook" into Gollum in the appropriate places.


## Contributing

### Code of Conduct

Please note that this project is released with a [code of conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.


### Getting Help or Reporting Issues

[Create an issue](https://github.com/beporter/gollum-elasticsearch/issues).

TODO: Better details.


### Development

* [Create an issue](https://github.com/beporter/gollum-elasticsearch/issues) to propose and discuss the contribution.
  * The authors have little time to maintain this project. Your contributions are invited, but we wish to not waste anyone's time. A quick conversation to determine alignment and fit is usually a good investment.
* If the contribution is a good fit, clone the repo, start a topic branch, and open a pull request.
  * Clone the repository.
  * Run `docker-compose up` to launch the development environment, which contains a ruby container running gollum and a test wiki, and an Elasticsearch container.
  * The test suite should continue to pass.


### Testing

It is recommended to run the test suite inside the provided Docker Compose environment.

* `docker-compose ruby rspec`
* `docker-compose ruby rubocop`


## Copyright & License

Copyright &copy; 2021 Brian Porter.

This software is released under the [MIT License](LICENSE).
