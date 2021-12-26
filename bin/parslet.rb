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

  # Query string
  rule(:word) { chars >> space? }
  rule(:quoted_word) { quote >> word.repeat >> quote >> space? }
  #rule(:quoted_word) { (quote >> (word >> ( space | quote )).repeat).repeat(1) }
  rule(:term) { (quoted_word.as(:phrase) | word.as(:phrase)).repeat }
  rule(:identifier) { chars.as(:key) >> separator }
  rule(:subquery) { identifier >> term.as(:value) }

  rule(:expression) { (subquery >> space).repeat(1) }

  root(:expression)
end

class Transformer < Parslet::Transform

end

begin
  inputs = [
    '"quoted tag" "second" third fourth',
    'title:"quoted tag" tag:"second" third:fourth',
  ]

  parsed = Parser.new.parse(inputs[1])
  pp parsed.inspect
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end


