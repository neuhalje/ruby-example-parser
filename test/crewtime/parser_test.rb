require "test_helper"

class Crewtime::ParserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Crewtime::VERSION
  end

  def test_that_parser_can_be_instantiated
    assert ::Crewtime::Parser::TimelineGrammarParser.new
  end

  # Parse the text and just return the tag-types
  def parse_unwrapped(booking_text)
    begin
      parsed = ::Crewtime::Parser::TimelineGrammarParser.new.parse(booking_text, reporter: Parslet::ErrorReporter::Deepest.new)
      # The parser returns arrays when it found tokens but either "" or a Parslet instance else
      parsed.kind_of?(Array) ? map_as_keys(parsed) : []
    rescue Parslet::ParseFailed => error
      puts error.parse_failure_cause.ascii_tree
      raise
    end
  end

  # gets a list of dictionaries (with only one element each) and return a list of the keys
  def map_as_keys(list_of_dict)
    list_of_dict.map { |single_element_dict| single_element_dict.keys[0] }
  end

  def test_parse_atom_coming
    assert_equal [:t_coming], parse_unwrapped("COMING@9999-99-99T11:22:33")
  end

  def test_parse_atom_going
    assert_equal [:t_going], parse_unwrapped("GOING@9999-99-99T11:22:33")
  end

  def test_parse_atom_pause
    assert_equal [:t_pause], parse_unwrapped("PAUSE@9999-99-99T11:22:33")
  end

  def test_parse_empty_string_is_ok
    assert_equal [], parse_unwrapped("")
    assert_equal [], parse_unwrapped("  "), "Spaces should be ignored and also yield a empty string"
  end

  COMING = "COMING@9999-99-99T11:22:33"
  GOING = "GOING@9999-99-99T11:22:44"
  PAUSE = "PAUSE@9999-99-99T11:22:55"

  def test_parse_complex_day
    # This only tests the syntax, not the semantic!
    assert_equal [:t_coming, :t_pause, :t_coming, :t_pause, :t_coming, :t_going],
                 parse_unwrapped("#{COMING} #{PAUSE} #{COMING} #{PAUSE} #{COMING} #{GOING}")
  end

  def test_parse_with_spaces
    assert_equal [:t_coming, :t_going], parse_unwrapped("#{COMING} #{GOING}")
    assert_equal [:t_coming, :t_going], parse_unwrapped("#{COMING}
                                                        #{GOING}"), "Linebreaks are valid spaces"
    assert_equal [:t_coming, :t_going], parse_unwrapped("  #{COMING} #{GOING}"), "Spaces at the start should be ignored."
    assert_equal [:t_coming, :t_going], parse_unwrapped("#{COMING} #{GOING}  "), "Spaces at the end should be ignored."
    assert_equal [:t_coming, :t_going], parse_unwrapped("#{COMING}       #{GOING}"), "Spaces in the middle should be ignored."
    assert_equal [:t_coming, :t_going], parse_unwrapped("#{COMING}#{GOING}"), "Spaces are optional."
  end

  def test_error_invalid_tokens
    exception = assert_raises Parslet::ParseFailed do
      parse_unwrapped("COMINGx")
    end

    exception = assert_raises Parslet::ParseFailed do
      parse_unwrapped("COMING x GOING")
    end
  end
end
