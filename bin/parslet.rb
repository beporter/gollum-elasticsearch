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
    (quote >> (term >> space.maybe).repeat >> quote)
  end
  rule(:clause) { (phrase | term) }
  rule(:subquery) { field.as(:key) >> separator >> clause.as(:value) >> space.maybe }

  # Root
  rule(:query) { (operator.maybe >> (subquery | clause.as(:value)) >> space.maybe).repeat.as(:queries) }
  root(:query)
end

class Transformer < Parslet::Transform

  rule(term: simple(:term)) { term.to_s }

  rule(term: sequence(:terms)) { term.join(' ') }

  rule(operator: simple(:o)) do
    case o
    when '+'
      :must
    when '-'
      :must_not
    when nil
      :should
    else
      raise "Unrecognized operator: #{o}"
    end
  end

  rule(value: simple(:value)) do
    {
      operator: nil,
      key: nil,
      value: value.to_s,
    }
  end

  rule(value: sequence(:values)) do
    {
      operator: nil,
      key: nil,
      value: values.join(' '),
    }
  end

  rule(operator: simple(:operator), value: simple(:value)) do
    {
      operator: operator,
      key: nil,
      value: value.to_s,
    }
  end

  rule(operator: simple(:operator), value: sequence(:values)) do
    {
      operator: operator,
      key: nil,
      value: values.join(' '),
    }
  end

  rule(key: simple(:key), value: simple(:value)) do
    {
      operator: nil,
      key: key.to_s,
      value: value.to_s,
    }
  end

  rule(key: simple(:key), value: sequence(:values)) do
    {
      operator: nil,
      key: key.to_s,
      value: values.join(' '),
    }
  end

  rule(operator: simple(:operator), key: simple(:key), value: simple(:value)) do
    {
      operator: operator,
      key: key.to_s,
      value: value.to_s,
    }
  end

  rule(operator: simple(:operator), key: simple(:key), value: sequence(:values)) do
    {
      operator: operator,
      key: key.to_s,
      value: values.join(' '),
    }
  end

  rule(queries: subtree(:subqueries)) { puts 'HERE'; pp subqueries; Query.new(subqueries) }
end

class Query

  def initialize(subqueries)
    grouped = subqueries.group_by {|q| op(q[:operator]) }.to_h

  pp grouped
    @must = grouped.fetch(:must, [])
    @must_not = grouped.fetch(:must_not, [])
    @should = grouped.fetch(:should, [])
  end

  def to_elasticsearch()
    query = {
      bool: {}
    }

    query[:bool][:must] = @must.map { |sq| match(sq) } if @must.any?
    query[:bool][:must_not] = @must_not.map { |sq| match(sq) } if @must_not.any?
    query[:bool][:should] = @should.map { |sq| match(sq) } if @should.any?

    { query: query }
  end

  private

  def op(o)
    case o
    when '+'
      :must
    when '-'
      :must_not
    when nil
      :should
    else
      raise "Unrecognized operator: #{o}"
    end
  end

  def match(term)
    match_type = term[:value] =~ /\s/ ? :match_phrase : :match
    field = term[:key] || '_all'
    {
      match_type => {
        field.to_sym => {
          query: term[:value]
        }
      }
    }
  end

end

# ===========================================================================
inputs = [
  '"quoted tag" "second" third fourth',
  'title:"quoted tag" tag:"second" tag:fourth',
  'title:"quoted tag" tag:"second" tag:fourth actual search term',
  'title:"quoted tag" tag:"second" -tag:fourth actual +search -term "quoted thing" -"never this"',
  'title:hobbit +bilbo',
]
begin
  parsed = Parser.new.parse(inputs[4])
  pp parsed
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end

puts '=' * 10
query = Transformer.new.apply(parsed)
pp query

puts '=' * 10
pp query.to_elasticsearch
