#!/usr/bin/env ruby
# Run `gem install parslet`

require 'parslet'

class Parser < Parslet::Parser
  # Character rules
  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:quote) { str("\"") || str("\'") }
  rule(:quote?) { quote.maybe }
  rule(:separator) { str(':') }
  rule(:chars) { match(/\w/).repeat(1) }

  # Fields
  rule(:title) { str('title') }
  rule(:tag) { str('tag') }
  #rule(:identifier) { chars.as(:key) >> separator } # `title:`
  rule(:field) { title | tag }

  # Query string
  rule(:word) { chars >> space? } # `word`
  rule(:quoted_word) { quote >> word.repeat(1) >> quote >> space? } # `"two words"` or `'many words here'`
  #rule(:quoted_word) { (quote >> (word >> ( space | quote )).repeat).repeat(1) }
  rule(:term) { (word | quoted_word.repeat).as(:phrase) }
  rule(:subquery) { field.as(:key) >> separator >> term.as(:value) >> space? }
  rule(:query) { term.repeat }

  rule(:expression) { subquery.repeat(1) }

  root(:expression)
end

class Transformer < Parslet::Transform

end

begin
  inputs = [
    '"quoted tag" "second" third fourth',
    'title:"quoted tag" tag:"second" tag:fourth',
    'title:"quoted tag" tag:"second" tag:fourth actual search term',
  ]

  parsed = Parser.new.parse(inputs[1])
  pp parsed
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end


