#!/usr/bin/env ruby
# Run `gem install parslet`

require 'parslet'

class Parser < Parslet::Parser
  # Characters
  rule(:space)  { match('\s').repeat(1) }
  rule(:quote) { str('"') }
  rule(:separator) { str(':') }
  rule(:operator) { (str('+') | str('-')).as(:operator) }
  rule(:term) { match('[^\s":]').repeat(1).as(:term) }

  # Fields
  rule(:title) { str('title') }
  rule(:tag) { str('tag') }
  #rule(:identifier) { chars.as(:key) >> separator } # `title:`
  rule(:field) { title | tag }

  # Compositions
  rule(:phrase) do
    (quote >> (term >> space.maybe).repeat >> quote).as(:phrase)
  end
  rule(:clause) { (phrase | term).as(:clause) }
  rule(:subquery) { field.as(:key) >> separator >> clause.as(:value) >> space.maybe }

  # Root
  rule(:query) { (operator.maybe >> (subquery | clause) >> space.maybe).repeat.as(:query) }
  root(:query)
end

class Transformer < Parslet::Transform

end

begin
  inputs = [
    '"quoted tag" "second" third fourth',
    'title:"quoted tag" tag:"second" tag:fourth',
    'title:"quoted tag" tag:"second" tag:fourth actual search term',
    'title:"quoted tag" tag:"second" -tag:fourth actual +search -term',
  ]

  parsed = Parser.new.parse(inputs[3])
  pp parsed
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end


