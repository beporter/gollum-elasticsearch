require 'gollum_search/elasticsearch/backend'
require 'fakes/backend'

RSpec.describe GollumSearch::Indexer do

  describe 'default backend' do
    it 'uses Elasticsearch' do
      backend = GollumSearch::Indexer.backend
      expect(backend).to be_an_instance_of(GollumSearch::Elasticsearch::Backend)
    end
  end

  describe 'custom backend' do
    it 'raises error on incompatible interface' do
      expect { GollumSearch::Indexer.backend = Object.new }.to raise_exception(/Backend does not respond to/)
    end

    it 'accepts a compatible interface' do
      dbl = double(save: true, search: true)
      expect { GollumSearch::Indexer.backend = dbl }.not_to raise_exception
      expect(GollumSearch::Indexer.backend).to be_a_kind_of(dbl.class)
    end
  end

  describe '#reindex' do
    it 'raises an error when passed wrong arg' do
      GollumSearch::Indexer.backend = Fakes::Backend.new(save: 42)
      expect { GollumSearch::Indexer.reindex('string') }.to raise_exception(/Not a Gollum::Wiki instance:/)
    end

    it 'loops over records and calls @@backend.save' do
      backend = Fakes::Backend.new()
      GollumSearch::Indexer.backend = backend

      page = OpenStruct.new({
        title: 'Foo',
        url_path: '/foo.md',
      })
      expect(backend).to receive(:save).with('/foo.md', {
        path: '/foo.md',
        title: 'Foo',
        toc: '',
        tags: [],
        version_short: '',
        format: '',
        content: '',
      }).and_return('results')
      wiki = instance_double('Gollum::Wiki', is_a?: true, pages: [page])
      expect(wiki).to receive(:pages)
      #expect { GollumSearch::Indexer.reindex(wiki) }.not_to raise_exception
      expect(GollumSearch::Indexer.reindex(wiki)).to eq(['results'])
    end
  end

  describe '#page' do
    it 'calls @@backend.save' do
      backend = Fakes::Backend.new(save: 'result')
      GollumSearch::Indexer.backend = backend

      page = {
        title: 'Foo',
        #url_path: '/foo.md',
      }
      expect(GollumSearch::Indexer.page(page)).to eq('result')
    end
  end

  describe '#hook' do
    it 'digs into the commit and calls @@backend.save' do
      backend = Fakes::Backend.new(save: 'result')
      GollumSearch::Indexer.backend = backend

      page = OpenStruct.new({
        title: 'Foo',
        url_path: '/foo.md',
      })
      wiki = double({})
      allow(wiki).to receive(:page).and_return(page)
      committer = double({})
      allow(committer).to receive(:wiki).and_return(wiki)
      allow(committer).to receive(:page).and_return(page)

      allow(committer).to receive_message_chain(:diff, :deltas).and_return([
        OpenStruct.new({
          new_file: { path: 'new.md' },
          old_file: { path: 'old.md' },
        })
      ])
      allow(GollumSearch::Indexer).to receive(:page).with(page).and_return('result')

      expect(GollumSearch::Indexer.hook(committer, 'abc123')).to eq(['result', 'result'])
    end
  end
end
