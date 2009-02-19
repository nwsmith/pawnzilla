#
#   Copyright 2005-2009 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "test/unit"
require "lib/pz_unit"
require "rules_engine";

# Because they are in a particular format and won't always fit into the other test classes,
# we're gathering tests based on game monitor failures into one place.

class MonitorFailuresTest < Test::Unit::TestCase
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
end
