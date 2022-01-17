require 'parslet'

module GollumSearch
  class Parser < Parslet::Parser
    # Characters
    rule(:space)  { match('\s').repeat(1) }
    rule(:quote) { str('"') }
    rule(:separator) { str(':') }
    rule(:operator) { (str('+') | str('-')).as(:operator) } # `+` or `-`
    rule(:term) { match('[^\s":]').repeat(1).as(:term) } # `word`

    # Fields
    rule(:title) { str('title') }
    rule(:tag) { str('tag') }
    rule(:content) { str('content') }
    #rule(:identifier) { chars.as(:key) >> separator } # `title:`
    rule(:field) { title | tag | content }

    # Compositions
    rule(:phrase) do
      (quote >> (term >> space.maybe).repeat >> quote) # `"quoted phrase"`
    end
    rule(:clause) { (phrase | term) } # `word` or `"quoted phrase"`
    rule(:subquery) { field.as(:key) >> separator >> clause.as(:value) >> space.maybe } # `title:foo` or `tag:"two words"`

    # Root
    rule(:query) { (operator.maybe >> (subquery | clause.as(:value)) >> space.maybe).repeat.as(:queries) }
    root(:query)
  end
end
