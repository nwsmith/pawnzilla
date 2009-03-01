#
#   Copyright 2005-2009 Nathan Smith, Ron Thomas, Sheldon Fuchs
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "test/unit"
require "lib/pz_unit"
require "colour"

class TestColour < Test::Unit::TestCase
  def test_black_should_be_black
    assert(Colour::BLACK.black?)
  end

  def test_black_should_not_be_white
    assert(!Colour::BLACK.white?)
  end

  def test_white_should_be_white
    assert(Colour::WHITE.white?)
  end

  def test_white_should_not_be_black
    assert(!Colour::WHITE.black?)
  end

  def test_white_should_be_opposite_of_black
    assert(Colour::WHITE.opposite?(Colour::BLACK))
  end

  def test_white_should_not_be_opposite_of_white
    assert(!Colour::WHITE.opposite?(Colour::WHITE))
  end

  def test_black_should_be_opposite_of_white
    assert(Colour::BLACK.opposite?(Colour::WHITE))
  end

  def test_black_should_not_be_opposite_of_black
    assert(!Colour::BLACK.opposite?(Colour::BLACK))
  end

  def test_white_should_be_equal_to_white
    assert_equal(Colour::WHITE, Colour::WHITE)
  end

  def test_white_should_not_be_equal_to_black
    assert_not_equal(Colour::WHITE, Colour::BLACK)
  end

  def test_black_should_be_equal_to_black
    assert_equal(Colour::BLACK, Colour::BLACK)
  end

  def test_black_should_not_be_equal_to_white
    assert_not_equal(Colour::BLACK, Colour::WHITE)
  end

  def test_white_should_return_correct_hash
    assert_equal(Colour::WHITE.hash, 0)
  end

  def test_black_should_return_correct_hash
    assert_equal(Colour::BLACK.hash, 1)
  end
end
