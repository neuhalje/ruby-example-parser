require 'date'

module Crewtime
  module Interpreter

    class Interval
      attr_reader :start, :end, :type

      def initialize(interval_start, interval_end, type)
        @start = interval_start
        @end = interval_end
        @type = type
      end

      def to_s
        "{'type': '#{@type}', 'from': '#{@start.iso8601}', 'to': '#{@end.iso8601}' }"
      end
    end

    # current state[input] -> new state
    ERROR_HASH = Hash.new(:error)

    STATE_MACHINE = {
        :start => {
            :coming => :at_work,
            :pause => :in_pause
        },
        :at_work => {
            :pause => :in_pause,
            :going => :end
        },
        :in_pause => {
            :coming => :at_work,
            :going => :end
        }
    }
    STATE_MACHINE.default = ERROR_HASH
    STATE_MACHINE.each_value { |v| v.default = ERROR_HASH }

    INTERVAL_BUILDER = {
        :at_work => -> (start_event, end_event) { Interval.new(start_event.timestamp, end_event.timestamp, :working_time) },
        :in_pause => -> (start_event, end_event) { Interval.new(start_event.timestamp, end_event.timestamp, :pause_time) },
    }
    INTERVAL_BUILDER.default = -> (_, _) { nil }

    FINAL_STATES = [:end]


    class TimelineGrammarInterpreter
      # Gets a list of Events and builds Intervals.
      # Since the business logic can easily described as a
      # finite state machine, this class also implements one.
      #
      # A strict prerequisite is that
      # - timestamps are in order

      def interpret(events)
        state = :start
        last_event = nil
        intervals = []

        for event in events
          interval = INTERVAL_BUILDER[state].call(last_event, event)
          intervals.append(interval) if interval
          state = STATE_MACHINE[state][event.type]

          if state == :error
            raise ArgumentError.new("Unexpected end. Caused by the transition from event #{last_event} to #{event}.")
          end

          last_event = event
        end

        raise ArgumentError.new("Unexpected end. The last event found was #{event}") unless FINAL_STATES.include?(state)
        intervals
      end
    end
  end
end
