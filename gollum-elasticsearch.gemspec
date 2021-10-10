lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gollum/elasticsearch/version'

Gem::Specification.new do |spec|
  spec.name          = 'gollum-elasticsearch'
  spec.version       = Gollum::Elasticsearch::VERSION
  spec.authors       = ['Brian Porter']
  spec.email         = ['beporter@users.sourceforge.net']

  spec.summary       = %q{Add Elasticsearch to the Gollum wiki.}
  spec.description   = %q{Overrides Gollum's default search functionality to use an Elasticsearch service. This allws find-as-you-type and the ability to tune the priority of search results within a wiki's particular knowledge domain.}
  spec.homepage      = 'https://github.com/beporter/gollum-elasticsearch'
  spec.license       = 'MIT'

  # spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/beporter/gollum-elasticsearch'
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = [
    'lib/gollum/elasticsearch.rb',
    'lib/gollum/elasticsearch/version.rb',
  ]
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  # spec.bindir        = 'exe'
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'searchkick', '~> 4.6.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'gollum', '~> 5.2'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.22'

end
