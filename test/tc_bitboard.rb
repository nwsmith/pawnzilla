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
    
    def test_move_colour
        # Ensure that the peice remains the same colour on move
        board = Bitboard.new()
        src = Coord.new(4, 6);
        dest = Coord.new(4, 4);
        board.move_piece(src, dest);
        assert(board.sq_at(dest).piece.colour.black?);

        src = Coord.new(4, 1);
        dest = Coord.new(4, 3);
        board.move_piece(src, dest);
        assert(board.sq_at(dest).piece.colour.white?);
        
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
    
    def test_gen_pwn_attack()
        b = Bitboard.new()
        
        # Test the middle board attacks
        b.clear()
        
        b.place_piece(Coord.new(2, 3), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_white)

        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour.new_white, Coord.new(1, 4)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour.new_white, Coord.new(3, 4)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(4, 4)))

        b.clear()
        
        b.place_piece(Coord.new(2, 3), Chess::Piece.new(Chess::Colour.new_black, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_black)

        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(0, 2)))
        assert(b.attacked?(Chess::Colour.new_black, Coord.new(1, 2)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour.new_black, Coord.new(3, 2)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(4, 2)))

        # Test the left edge
        b.clear()
        
        b.place_piece(Coord.new(0, 3), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_white)

        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(7, 3)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour.new_white, Coord.new(1, 4)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(2, 4)))

        b.clear()
        
        b.place_piece(Coord.new(0, 3), Chess::Piece.new(Chess::Colour.new_black, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_black)

        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(7, 3)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(0, 2)))
        assert(b.attacked?(Chess::Colour.new_black, Coord.new(1, 2)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(2, 2)))

        # Test the right edge
        b.clear()
        
        b.place_piece(Coord.new(7, 3), Chess::Piece.new(Chess::Colour.new_white, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_white)

        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour.new_white, Coord.new(6, 4)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(7, 4)))
        assert(!b.attacked?(Chess::Colour.new_white, Coord.new(0, 5)))

        b.clear()
        
        b.place_piece(Coord.new(7, 3), Chess::Piece.new(Chess::Colour.new_black, "Pawn"))
        b.gen_pwn_attack(Chess::Colour.new_black)

        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(5, 2)))
        assert(b.attacked?(Chess::Colour.new_black, Coord.new(6, 2)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(7, 2)))
        assert(!b.attacked?(Chess::Colour.new_black, Coord.new(0, 1)))

    end      
    
    def test_on_file? 
        b = Bitboard.new;
        
        bv0_7 = 0x01 << Bitboard.get_sw(Coord.new(0, 7))
        bv0_4 = 0x01 << Bitboard.get_sw(Coord.new(0, 4))
        bv4_7 = 0x01 << Bitboard.get_sw(Coord.new(4, 7))
        
        assert(b.on_file?(bv0_7, bv0_4))
        assert(b.on_file?(bv0_4, bv0_7))
        
        assert(b.on_file?(bv0_7, bv0_7))
        
        assert(!b.on_file?(bv0_7, bv4_7))
        assert(!b.on_file?(bv4_7, bv0_7))        
    end
    
    def test_on_rank?
        b = Bitboard.new;

        bv0_0 = 0x01 << Bitboard.get_sw(Coord.new(0, 0))        
        bv0_4 = 0x01 << Bitboard.get_sw(Coord.new(0, 4))        
        bv0_7 = 0x01 << Bitboard.get_sw(Coord.new(0, 7))
        bv4_7 = 0x01 << Bitboard.get_sw(Coord.new(4, 7))
        bv7_0 = 0x01 << Bitboard.get_sw(Coord.new(7, 0))        
        
        assert(b.on_rank?(bv0_7, bv4_7))
        assert(b.on_rank?(bv4_7, bv0_7))
        
        assert(b.on_rank?(bv0_0, bv7_0))
        
        assert(b.on_rank?(bv0_7, bv0_7))
        
        assert(!b.on_rank?(bv0_7, bv0_4))
        assert(!b.on_rank?(bv0_4, bv0_7))
    end
    
    def test_on_diagonal_sw_ne
        b = Bitboard.new
        
        bv1_3 = 0x1 << Bitboard.get_sw(Coord.new(1, 3))
        bv2_4 = 0x1 << Bitboard.get_sw(Coord.new(2, 4))
        bv3_5 = 0x1 << Bitboard.get_sw(Coord.new(3, 5))
        
        assert(b.on_diagonal?(bv1_3, bv2_4))
        assert(b.on_diagonal?(bv1_3, bv3_5))
        assert(b.on_diagonal?(bv2_4, bv3_5))
        
        assert(b.on_diagonal?(bv2_4, bv1_3))
        assert(b.on_diagonal?(bv3_5, bv1_3))
        assert(b.on_diagonal?(bv3_5, bv2_4))        
    end
    
    def test_on_diagonal_nw_se
        b = Bitboard.new
        
        bv1_6 = 0x1 << Bitboard.get_sw(Coord.new(1, 6))
        bv2_5 = 0x1 << Bitboard.get_sw(Coord.new(2, 5))
        bv5_2 = 0x1 << Bitboard.get_sw(Coord.new(5, 2))
        
        assert(b.on_diagonal?(bv1_6, bv2_5))
        assert(b.on_diagonal?(bv2_5, bv5_2))
        assert(b.on_diagonal?(bv1_6, bv5_2))
        
        assert(b.on_diagonal?(bv2_5, bv1_6))
        assert(b.on_diagonal?(bv5_2, bv2_5))
        assert(b.on_diagonal?(bv5_2, bv1_6))        
    end
end
