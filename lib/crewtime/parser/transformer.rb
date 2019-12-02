module Crewtime
  module Parser

    class Event
      attr_reader :timestamp,  :type

      def initialize(timestamp, type)
        @timestamp = timestamp
        @type = type
      end
      def to_s
        "Event of type #{@type} @ #{@timestamp}"
      end
    end

    # Interprets the parsers tokens and builds a stream of events
    class TimelineGrammarTransformer < Parslet::Transform
      rule(:t_going => simple(:ts)) do
        Event.new(ts, :going)
      end
      rule(:t_pause => simple(:ts)) do
        Event.new(ts, :pause)
      end
      rule(:t_coming => simple(:ts)) do
        Event.new(ts, :coming)
      end
      rule(:t_timestamp => simple(:ts)) do
        Time.iso8601(ts)
      end
    end
  end
end