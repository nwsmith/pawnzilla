#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "bitboard"
require "chess"
require "geometry"
require "rule_std"

class TestBitboard < Test::Unit::TestCase
    def test_sq_at
        board = Bitboard.new();
        
        square = board.sq_at(Coord.new(0, 0))        
        assert(square.colour.black?)
        assert(square.piece.colour.white?)
        assert(square.piece.name == "Rook")
        
        square = board.sq_at(Coord.new(0, 2))
        assert(square.colour.black?)
        assert(square.piece.nil?)
        
        square = board.sq_at(Coord.new(2, 7))
        assert(square.colour.white?)
        assert(square.piece.colour.black?)
        assert(square.piece.name == "Bishop")
        
        square = board.sq_at(Coord.new(0, 5))
        assert(square.piece.nil?)
    end
    
    def test_move_piece
        board = Bitboard.new()
        src = Coord.new(0, 1)
        dest = Coord.new(0, 2)
        board.move_piece(src, dest)
        assert(board.sq_at(src).piece.nil?)
        assert(!board.sq_at(dest).piece.nil?)
        assert(board.sq_at(dest).piece.colour.white?)
        assert(board.sq_at(dest).piece.name == "Pawn")
    end
    
    def test_place_piece
        board = Bitboard.new()
        coord = Coord.new(0,5)
        piece = Chess::Piece.new(Chess::Colour.new_black(), "Rook")
        board.place_piece(coord, piece)
        square = board.sq_at(coord)
        assert(!square.piece.nil?)
        assert(square.piece.colour.black?) 
        assert(square.piece.name == "Rook")
    end
    
    def test_remove_piece
        board = Bitboard.new()
        coord = Coord.new(0,0)
        board.remove_piece(coord)
        square = board.sq_at(coord)
        assert(square.piece.nil?)
        
        # Make sure an empty square stays that way
        coord = Coord.new(0, 5)
        board.remove_piece(coord)
        square = board.sq_at(coord)
        assert(square.piece.nil?)
    end
    
    def test_blocked
        b = Bitboard.new()
        b.clear()

        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))        
        b.place_piece(Coord.new(3, 3), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 3)))
        
        b.place_piece(Coord.new(0, 3), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(0, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 3)))
        
        b.place_piece(Coord.new(3, 0), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 0)))
        
        # Make sure it works for squares other than the origin
        c0 = Coord.new(2, 3)
        c1 = Coord.new(5, 6)
        
        b.place_piece(c0, Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        b.place_piece(c1, Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        assert(b.blocked?(c0, Coord.new(6, 7)))
        assert(!b.blocked?(c0, Coord.new(4, 5)))
        assert(!b.blocked?(c0, c1))
        
        # Unit test for a bug condition -> Rook can hop a pawn
        e = Rule_Std::Engine.new()
        b = e.state.board
        assert(b.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
    end      
end