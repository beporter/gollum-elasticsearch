require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/reloader'

module Gollum
  module Elasticsearch
    class Middleware < Sinatra::Base

      register Sinatra::Namespace

      configure :development do
        enable :logging
        register Sinatra::Reloader
      end

      get '/gollum/search' do
        'TODO: Overriden search results go here.'
      end

      # get '/search' do
      #   @query     = params[:q] || ''
      #   @name      = @query
      #   if @query.empty?
      #     @results = []
      #     @search_terms = []
      #   else
      #     @page_num  = [params[:page_num].to_i, 1].max
      #     @max_count = 10
      #     wiki       = wiki_new
      #     @results, @search_terms = wiki.search(@query)
      #   end
      #   mustache :search
      # end
    end
  end
end
