#
#   $Id$
#
#   Copyright 2005, 2006 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "colour"
require "chess"

class TestBoard < Test::Unit::TestCase    
    def test_get_colour
        assert_equal(Chess::Board.get_colour(Coord.new(0,0)), Colour::BLACK)
        assert_equal(Chess::Board.get_colour(Coord.new(1,0)), Colour::WHITE)        
        assert_equal(Chess::Board.get_colour(Coord.new(0,1)), Colour::WHITE)
        assert_equal(Chess::Board.get_colour(Coord.new(1,1)), Colour::BLACK)                
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
        
        b.sq_at(Coord.new(0, 0)).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        b.sq_at(Coord.new(3, 3)).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 3)))
        
        b.sq_at(Coord.new(0, 3)).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        assert(b.blocked?(Coord.new(0, 0), Coord.new(0, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 3)))
        
        b.sq_at(Coord.new(3, 0)).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 0)))
        
        # Make sure it works for squares other than the origin
        c0 = Coord.new(2, 3)
        c1 = Coord.new(5, 6)
        
        b.sq_at(c0).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        b.sq_at(c1).piece = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        assert(b.blocked?(c0, Coord.new(6, 7)))
        assert(!b.blocked?(c0, Coord.new(4, 5)))
        assert(!b.blocked?(c0, c1))        
    end    

    def test_same_piece_same_colour_should_be_equal
        p1 = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        p2 = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        assert_equal(p1, p2)
    end

    def test_same_piece_diff_colour_should_not_be_equal
        p1 = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        p2 = Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN)
        assert_not_equal(p1, p2)
    end

    def test_diff_piece_same_colour_should_not_be_equal
        p1 = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        p2 = Chess::Piece.new(Colour::WHITE, Chess::Piece::KING)
        assert_not_equal(p1, p2)
    end

    def test_diff_piece_diff_colour_should_not_be_equal
        p1 = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
        p2 = Chess::Piece.new(Colour::BLACK, Chess::Piece::KING)
        assert_not_equal(p1, p2)
    end
end
