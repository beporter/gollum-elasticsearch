require 'gollum_search/elasticsearch/backend'

RSpec.describe GollumSearch::Elasticsearch::Backend do
  before :example do
    #@es_class = class_double(::Elasticsearch::Client)
    #@es_client = instance_double(::Elasticsearch::Client)
    #allow(::Elasticsearch::Client).to receive(:new).and_return(@es_client)
  end

  describe '#connection' do
    it 'raises error on missing ELASTICSEARCH_URL env var' do
      ENV['ELASTICSEARCH_URL'] = nil
      expect { GollumSearch::Elasticsearch::Backend.new().connection() }.to raise_exception(/define ELASTICSEARCH_URL/)
    end

    it 'merges initialized options' do
      ENV['ELASTICSEARCH_URL'] = 'http://user:pass@es-server:9200'
      backend = GollumSearch::Elasticsearch::Backend.new({
        foo: 'bar',
        transport_options: { fast: true },
      })
      expect(::Elasticsearch::Client).to receive(:new).with(
        url: ENV['ELASTICSEARCH_URL'],
        transport_options: {
          request: {timeout: 10},
          headers: {content_type: 'application/json'},
          fast: true,
        },
        foo: 'bar',
      ).and_return('conn')

      expect(backend.connection()).to eq('conn')
    end
  end

  describe '#save' do
    it 'calls connection.index' do
      page = ['ID', {attrs: 'set'}]
      backend = GollumSearch::Elasticsearch::Backend.new()
      conn = spy(::Elasticsearch::Client)
      allow(conn).to receive(:index)
        .with(index: 'wiki', type: 'page', id: page.first, body: page.last)
        .and_return('canary')

      expect(backend).to receive(:connection).and_return(conn)
      expect(backend.save(*page)).to eq('canary')
    end
  end

  describe '#search' do
    it 'calls connection.search' do
      query = 'search term'
      backend = GollumSearch::Elasticsearch::Backend.new()
      conn = spy(::Elasticsearch::Client)
      allow(conn).to receive(:search)
        .with(query)
        .and_return('canary')

      expect(backend).to receive(:connection).and_return(conn)
      expect(backend.search(query)).to eq('canary')
    end
  end
end
