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
require "rules_engine";

# Because they are in a particular format and won't always fit into the other test classes,
# we're gathering tests based on game monitor failures into one place.

class MonitorFailuresTest < Test::Unit::TestCase
  def test_should_calculate_checkmate_from_game_part_one
    e = RulesEngine.new
    place_pieces(e, "
      R - B - - R - -
      - - K P - - - -
      - P - p - P - -
      - - P - P p n P
      n - p - - - - -
      p q - p - - - r
      - - - b - - b -
      r - - - k - - -
    ")
    assert(!e.checkmate?(Colour::BLACK))
  end

  def test_should_calculate_checkmake_from_game_part_two
    e = RulesEngine.new
    place_pieces(e, "
      R N B - K - R -
      - P P P - - P -
      - - - - - Q - P
      P - B - P P - -
      - - - - - N p p
      p p - p p n - -
      n - p - k p - -
      - r b q - b - r
    ")
    assert(!e.checkmate?(Colour::WHITE))
  end

  def test_should_not_be_checkmate_from_game_part_one
    e = RulesEngine.new
    place_pieces(e, "
      p - - p R - - K
      B - - - R - - -
      - - - - - - b p
      - - - - - - p -
      - P - - - - - -
      - - - - - - P -
      - - - P - - B -
      - - - r - - k -
    ")
    assert(!e.checkmate?(Colour::WHITE))
  end

  def test_king_should_be_in_check_by_rook
    e = RulesEngine.new
    place_pieces(e, "
- - r - - K - -
- p - - - - - R
p - - n P - - -
- - - - p - - P
- r P - p b - -
- - Q - - p - -
- - - - k - - -
- - Q - - - B -
")
    assert(e.in_check?(Colour::BLACK), "Black king should be in check")
  end


  def test_king_should_not_be_able_to_move_into_check_by_capturing_rook
    e = RulesEngine.new
    place_pieces(e, "
- - r - - r - -
- p - - - - K R
p - - n P - - -
- - - - p - - P
- r P - p b - -
- - Q - - p - -
- - - - k - - -
- - Q - - - B -
")
    assert(!e.chk_mv(G7, F8), "This move should be illegal")
  end

  def test_bishop_should_not_be_able_to_leave_king_in_check
    e = RulesEngine.new
    place_pieces(e, "
- - q - - - - -
- - - B - - - -
- - - - K - - -
- - - - P - - p
P - r - - - n -
p - P k - r - -
- - - - - - - -
- R - - R - - -
")
    assert(!e.chk_mv(D7, B5), "This move should be illegal")
  end

  def test_bishop_should_not_be_able_to_leave_king_in_check_2
    e = RulesEngine.new
    place_pieces(e, "
r - B K - - - -
- - r - - p - -
- - - P - p - -
R - - - - - - p
- - - N R - - -
- - - - - Q - -
N n - - - - - k
- - - b r - - -
")
    assert(!e.chk_mv(C8, A6))
  end

  def test_king_should_not_be_in_check
    e = RulesEngine.new
    place_pieces(e, "
- - - r - - - -
- - - b k - - -
- - Q - - - K -
- - - - p - - -
- - - - - - - -
- - - - B - - -
- - - - - - - -
- Q - - - - - - ")
    assert(!e.in_check?(Colour::BLACK))
  end

  def test_king_should_be_able_to_move_out_of_check
    e = RulesEngine.new
    place_pieces(e, "
- - - r - - - -
- - - b - - - -
- - Q - k - K -
- - - - p - - -
- - - - - - - -
- - - - B - - -
- - - - - - - -
- Q - - - - - - ")
    assert(e.chk_mv(E6, E7))
  end

  def test_rook_should_not_leave_king_in_check
    e = RulesEngine.new
    place_pieces(e, "
- - R - - - R -
- - - - N - - P
- - - - - - - p
- - - - - - K -
- - - - r - - -
- - - P k - - b
- P B r - - - -
- - B - - - - -
")
    assert(!e.chk_mv(D2, C2))
  end
end
