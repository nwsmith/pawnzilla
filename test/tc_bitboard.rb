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
        coord = Coord.new(0,6)
        piece = Chess::Piece.new(Chess::Colour.new_black(), "Rook")
        board.place_piece(coord, piece)
        square = board.sq_at(coord)
        assert(!square.piece.nil?)
        assert(square.piece.colour.black?) 
        assert(square.piece.name == "Rook")
    end
    
end
