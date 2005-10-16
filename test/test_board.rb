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

require "src/board"
require "test/unit"

class TestBoard < Test::Unit::TestCase    
    def test_get_colour
        assert_equal(Board::Board.get_colour(Board::Coord.new(0,0)), "black")
        assert_equal(Board::Board.get_colour(Board::Coord.new(1,0)), "white")        
        assert_equal(Board::Board.get_colour(Board::Coord.new(0,1)), "white")
        assert_equal(Board::Board.get_colour(Board::Coord.new(1,1)), "black")                
    end
    
    def test_init
        b = Board::Board.new(2);

        assert_equal(b.sq_at(Board::Coord.new(0,0)).colour, Board::Board.get_colour(Board::Coord.new(0,0)))
        assert_equal(b.sq_at(Board::Coord.new(0,1)).colour, Board::Board.get_colour(Board::Coord.new(0,1)))
        assert_equal(b.sq_at(Board::Coord.new(1,0)).colour, Board::Board.get_colour(Board::Coord.new(1,0)))
        assert_equal(b.sq_at(Board::Coord.new(1,1)).colour, Board::Board.get_colour(Board::Coord.new(1,1)))                        
    end

end