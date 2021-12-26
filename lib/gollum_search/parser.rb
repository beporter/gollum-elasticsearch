require ''

module GollumSearch
  class Parser < Parslet::Parser
    # def date(input)
    #   match(/\d{4}-\d{1,2}-\d{1,2}/).as(input)
    # end

    rule(:title_field) do
      str('title')
    end

    rule(:tag_field) do
      str('tag')
    end

    rule(:value) do
      (str(',').absent? >> any).repeat
    end

    rule(:subquery) do
      (title_field.as(:title_field) | tag_field.as(:tag_field)) >>
        str(':') >>
        (range.as(:range) | value.as(:value))
    end

    rule(:subqueries) do
      (subquery >> (str(',') >> subquery).repeat(0)).repeat(1).as(:subqueries)
    end

    root(:subqueries)
  end
end
