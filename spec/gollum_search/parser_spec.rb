require 'gollum_search/parser'
require 'parslet/rig/rspec'

RSpec.describe GollumSearch::Parser do

  describe 'parse' do
    it 'raises on unrecognizable input' do
      bad_inputs = [
        'bad_field:foo',
      ]

      bad_inputs.each do |input|
        expect { subject.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end

    it 'produces parse trees for valid input' do
      valid_inputs = [
        ['foo', {:queries=>[{:value=>{:term=>"foo"}}]}],
        ['title:foo', {:queries=>[{:key=>"title", :value=>{:term=>"foo"}}]}],
      ]

      valid_inputs.each do |input|
        expect(subject).to parse(input[0])
        expect(subject.parse(input[0])).to eq(input[1])
      end
    end
  end

end
