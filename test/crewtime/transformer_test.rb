require "test_helper"

class Crewtime::ParserTest < Minitest::Test

  def test_that_transformer_can_be_instantiated
    assert Crewtime::Parser::TimelineGrammarTransformer.new
  end

  def parse(text)
    Crewtime::Parser::TimelineGrammarParser.new.parse(text)
  end

  def transform(hashes)
    Crewtime::Parser::TimelineGrammarTransformer.new.apply(hashes)
  end

  def test__atom_coming
    parsed = parse("COMING@9876-12-31T11:22:33")
    transformed = transform(parsed)

    assert_equal 1, transformed.length, "Exactly one event is returned"

    event = transformed[0]

    assert_equal :coming, event.type
    assert_equal Time.new(9876, 12, 31, 11, 22, 33), event.timestamp
  end


  def test__atom_going
    parsed = parse("GOING@9876-12-31T11:22:33")
    transformed = transform(parsed)

    assert_equal 1, transformed.length, "Exactly one event is returned"

    event = transformed[0]

    assert_equal :going, event.type
    assert_equal Time.new(9876, 12, 31, 11, 22, 33), event.timestamp
  end

  def test__atom_pause
    parsed = parse("PAUSE@9876-12-31T11:22:33")
    transformed = transform(parsed)

    assert_equal 1, transformed.length, "Exactly one event is returned"

    event = transformed[0]

    assert_equal :pause, event.type
    assert_equal Time.new(9876, 12, 31, 11, 22, 33), event.timestamp
  end

  def test__working_day
    parsed = parse(
        "COMING@9876-12-31T10:00:00 GOING@9876-12-31T11:11:11")
    transformed = transform(parsed)

    assert_equal 2, transformed.length

    coming = transformed[0]
    going = transformed[1]

    assert_equal :coming, coming.type
    assert_equal :going, going.type
  end

  def test_invalid_dates_are_rejected
    parsed = parse("GOING@9876-12-31T25:11:11")

    exception = assert_raises ArgumentError do
      # there is no 25 o'clock
      transform(parsed)
    end
  end
end
