require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/reloader'

module GollumElasticsearch

  class Middleware < Sinatra::Base

    register Sinatra::Namespace

    configure :development do
      enable :logging
      register Sinatra::Reloader
    end

    get '/gollum/search' do
      'TODO: Overriden search results go here.'
    end

  end
end
