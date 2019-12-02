require "test_helper"

class Crewtime::InterpreterTest < Minitest::Test
  def _parse(text)
    Crewtime::Parser::TimelineGrammarParser.new.parse(text)
  end

  def _transform(hashes)
    Crewtime::Parser::TimelineGrammarTransformer.new.apply(hashes)
  end

  def _interpret(events)
    Crewtime::Interpreter::TimelineGrammarInterpreter.new.interpret(events)
  end

  def interpret(text)
    _interpret(_transform(_parse(text)))
  end

  def test_detects_missing_end
    exception = assert_raises ArgumentError do
      interpret("COMING@9999-12-31T11:22:33")
    end
  end

  def test_detects_duplicate_coming
    exception = assert_raises ArgumentError do
      interpret("COMING@9999-12-31T11:22:33 COMING@9999-12-31T11:22:34")
    end
  end

  def test_detects_coming_back_after_going
    exception = assert_raises ArgumentError do
      interpret("COMING@9999-12-31T11:22:33 GOING@9999-12-31T11:22:34 COMING@9999-12-31T11:22:35 GOING@9999-12-31T11:22:36")
    end
  end

  def test_detects_double_pause
    exception = assert_raises ArgumentError do
      interpret("COMING@9999-12-31T11:22:33 PAUSE@9999-12-31T11:22:34 PAUSE@9999-12-31T11:22:35 COMING@9999-12-31T11:22:36")
    end
  end

  def test_interprets_simple_working_day
    intervals = interpret("COMING@9999-12-31T11:22:33 GOING@9999-12-31T11:22:34")
    assert_equal 1, intervals.length, "Only a single interval is expected"
    working_interval = intervals[0]

    assert_equal :working_time, working_interval.type
    assert_equal Time.new(9999,12,31,11,22,33), working_interval.start
    assert_equal Time.new(9999,12,31,11,22,34), working_interval.end
  end


  def test_interprets_day_with_pause
    intervals = interpret("
    COMING@2019-12-03T08:30:00
    PAUSE@2019-12-03T12:30:00
    COMING@2019-12-03T13:00:00
    GOING@2019-12-03T18:00:00")

    puts intervals
    assert_equal 3, intervals.length, "Expect work, pause, work: three elements"

    working_interval_1 = intervals[0]
    pause_interval = intervals[1]
    working_interval_2 = intervals[2]

    assert_equal :working_time, working_interval_1.type
    assert_equal Time.new(2019,12,3,8,30,00), working_interval_1.start
    assert_equal Time.new(2019,12,3,12,30,00), working_interval_1.end

    assert_equal :pause_time, pause_interval.type
    assert_equal Time.new(2019,12,3,12,30,00), pause_interval.start
    assert_equal Time.new(2019,12,3,13,00,00), pause_interval.end

    assert_equal :working_time, working_interval_2.type
    assert_equal Time.new(2019,12,3,13,00,00), working_interval_2.start
    assert_equal Time.new(2019,12,3,18,00,00), working_interval_2.end
  end

  def test_interprets_day_with_pause_at_the_end
    intervals = interpret("COMING@9999-12-31T11:22:33 PAUSE@9999-12-31T11:22:34 GOING@9999-12-31T11:22:35")
    assert_equal 2, intervals.length, "Expect work, pause: two elements"
    working_interval_1 = intervals[0]
    pause_interval = intervals[1]

    assert_equal :working_time, working_interval_1.type
    assert_equal Time.new(9999,12,31,11,22,33), working_interval_1.start
    assert_equal Time.new(9999,12,31,11,22,34), working_interval_1.end

    assert_equal :pause_time, pause_interval.type
    assert_equal Time.new(9999,12,31,11,22,34), pause_interval.start
    assert_equal Time.new(9999,12,31,11,22,35), pause_interval.end
  end
end
