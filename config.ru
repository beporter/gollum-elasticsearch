# This config file is injected into the local Docker Compose environment
# for the purposes of engaging the GollumSearch::Middleware plugin
# in front of the Gollum app, and configuring a post-commit hook to update
# the index with saved page changes.

$stderr.puts '!!! Rack config engaged !!!'

use Rack::Reloader

# Engage the GolumSearch plugin.
require_relative 'lib/gollum_search.rb'
#use GollumSearch::Middleware

# Normal Gollum boilerplate.
require 'gollum/app'
wiki_path = '/app/test/examples/lotr.git' # Path inside the `gollum` Docker container.
wiki_options = {}
Precious::App.set(:gollum_path, wiki_path)
Precious::App.set(:wiki_options, wiki_options)
run Precious::App
