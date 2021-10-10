# This config file is injected into the local Docker Compose environment
# for the purposes of engaging the GollumElasticsearch plugin as middleware
# in front of the Gollum app.

$stderr.puts '!!! Rack config engaged !!!'

require_relative 'lib/gollum-elasticsearch.rb'
use GollumElasticsearch::Middleware

require 'gollum/app'
wiki_path = '/app/test/examples/lotr.git'
Precious::App.set(:gollum_path, wiki_path)
run Precious::App
