require 'parslet'
require 'time'

include Parslet

module Crewtime
  module Parser
    # Parses the DSL and returns a hashmap of tokens
    class TimelineGrammarParser < Parslet::Parser
      rule(:at) { str('@').repeat(1) }
      rule(:space) { match('[\s]').repeat(1) }
      rule(:space?) { space.maybe }
      rule(:timestamp) do
        (
        # just make sure it looks like 9999-99-99T99:99:99
        # let the ISO8601 parser sort out the rest like leap years, etc
        match('[0-9]').repeat(4, 4) >>
            str("-") >>
            match('[0-9]').repeat(1, 2) >>
            str("-") >>
            match('[0-9]').repeat(1, 2) >>
            str("T") >>
            match('[0-9]').repeat(1, 2) >>
            str(":") >>
            match('[0-9]').repeat(1, 2) >>
            str(":") >>
            match('[0-9]').repeat(1, 2)
        ).as(:t_timestamp)
      end
      rule(:coming) { (str('COMING') >> at >> timestamp).as(:t_coming) }
      rule(:pause) { (str('PAUSE') >> at >> timestamp).as(:t_pause) }
      rule(:going) { (str('GOING') >> at >> timestamp).as(:t_going) }
      rule(:day) { (coming | going | pause |  space).repeat }
      root(:day)
    end
  end
end
