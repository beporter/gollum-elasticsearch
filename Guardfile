interactor :off

guard 'rack', port: 80 do
  watch('gollum_search.gemspec')
  watch('config.ru')
  watch(%r{^lib/.*})
end
