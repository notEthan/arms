require "test_helper"

class ARMSTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ARMS::VERSION
  end
end
