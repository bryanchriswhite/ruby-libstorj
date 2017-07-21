gem "minitest"
require "minitest/autorun"
require "ruby/libstorj"

module TestRuby; end

class TestRuby::TestLibstorj < Minitest::Test
  def test_sanity
    flunk "write tests or I will kneecap you"
  end
end
