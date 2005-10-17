#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs
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

require "src/rule_std"
require "test/unit"

class TestBoard < Test::Unit::TestCase    
    def test_coord_to_alg
        assert_equal(Rule_Std::Engine.coord_to_alg(Board::Coord.new(0, 0)), "a1")
        assert_equal(Rule_Std::Engine.coord_to_alg(Board::Coord.new(0, 7)), "a8")
        assert_equal(Rule_Std::Engine.coord_to_alg(Board::Coord.new(7, 0)), "h1")
        assert_equal(Rule_Std::Engine.coord_to_alg(Board::Coord.new(7, 7)), "h8")
    end
end