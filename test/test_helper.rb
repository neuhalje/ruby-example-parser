$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "crewtime/parser/parser"
require "crewtime/parser/transformer"
require "crewtime/interpreter/interpreter"

require "crewtime/version"

require "minitest/autorun"
