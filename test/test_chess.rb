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

require "test/unit"
require "chess"
require "rule_std"

class TestColour < Test::Unit::TestCase
    def test_black?
        assert(Chess::Colour.new_black.black?)
        assert(!Chess::Colour.new_white.black?)
    end
    
    def test_white?
        assert(Chess::Colour.new_white.white?)
        assert(!Chess::Colour.new_white.black?)
    end
    
    def test_opposite?
        assert(Chess::Colour.new_white.opposite?(Chess::Colour.new_black))
        assert(!Chess::Colour.new_white.opposite?(Chess::Colour.new_white))
        assert(Chess::Colour.new_black.opposite?(Chess::Colour.new_white))
        assert(!Chess::Colour.new_black.opposite?(Chess::Colour.new_black))        
    end
    
    def test_flip!
        w = Chess::Colour.new_white
        
        w.flip!
        assert(w.black?)
        assert(!w.white?)
        
        w.flip!
        assert(w.white?)
        assert(!w.black?)
    end
    
    def test_equalsequals
        assert(Chess::Colour.new_white == Chess::Colour.new_white)
    end
end

class TestBoard < Test::Unit::TestCase    
    def test_get_colour
        assert_equal(Chess::Board.get_colour(Coord.new(0,0)), Chess::Colour.new_black)
        assert_equal(Chess::Board.get_colour(Coord.new(1,0)), Chess::Colour.new_white)        
        assert_equal(Chess::Board.get_colour(Coord.new(0,1)), Chess::Colour.new_white)
        assert_equal(Chess::Board.get_colour(Coord.new(1,1)), Chess::Colour.new_black)                
    end
    
    def test_init
        b = Chess::Board.new(2)

        assert_equal(b.sq_at(Coord.new(0,0)).colour, Chess::Board.get_colour(Coord.new(0,0)))
        assert_equal(b.sq_at(Coord.new(0,1)).colour, Chess::Board.get_colour(Coord.new(0,1)))
        assert_equal(b.sq_at(Coord.new(1,0)).colour, Chess::Board.get_colour(Coord.new(1,0)))
        assert_equal(b.sq_at(Coord.new(1,1)).colour, Chess::Board.get_colour(Coord.new(1,1)))                        
    end
    
    def test_blocked
        b = Chess::Board.new(8)
        
        b.sq_at(Coord.new(0, 0)).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        b.sq_at(Coord.new(3, 3)).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 3)))
        
        b.sq_at(Coord.new(0, 3)).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        assert(b.blocked?(Coord.new(0, 0), Coord.new(0, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 3)))
        
        b.sq_at(Coord.new(3, 0)).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 0)))
        
        # Make sure it works for squares other than the origin
        c0 = Coord.new(2, 3)
        c1 = Coord.new(5, 6)
        
        b.sq_at(c0).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        b.sq_at(c1).piece = Chess::Piece.new(Chess::Colour.new_white, "Pawn")
        assert(b.blocked?(c0, Coord.new(6, 7)))
        assert(!b.blocked?(c0, Coord.new(4, 5)))
        assert(!b.blocked?(c0, c1))
        
        # Unit test for a bug condition -> Rook can hop a pawn
        e = Rule_Std::Engine.new()
        b = e.board
        assert(b.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
    end    
end