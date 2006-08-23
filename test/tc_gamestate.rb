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
require "gamestate"
require "chess"
require "geometry"
require "tr"

class TestGameState < Test::Unit::TestCase
    def setup 
        @board = GameState.new
    end

    def test_should_get_white_piece_on_black_square_from_initial_setup
        square = @board.sq_at(Coord.new(0, 0))
        assert_not_nil(square)
        assert(square.colour.black?)
        assert_not_nil(square.piece)
        assert(square.piece.colour.white?)
        assert_equal(Chess::Piece::ROOK, square.piece.name)
    end

    def test_should_get_empty_square_from_initial_setup
        square = @board.sq_at(Coord.new(0, 2))
        assert_not_nil(square)
        assert(square.colour.black?)
        assert_nil(square.piece)
    end

    def test_should_get_black_piece_on_white_square_from_initial_setup
        square = @board.sq_at(Coord.new(2, 7))
        assert_not_nil(square)
        assert(square.colour.white?)
        assert_not_nil(square.piece)
        assert(square.piece.colour.black?)
        assert_equal(Chess::Piece::BISHOP, square.piece.name)
    end

    def test_move_piece
        board = GameState.new()
        src = Coord.new(0, 1)
        dest = Coord.new(0, 2)
        board.move_piece(src, dest)
        assert(board.sq_at(src).piece.nil?)
        assert(!board.sq_at(dest).piece.nil?)
        assert(board.sq_at(dest).piece.colour.white?)
        assert(board.sq_at(dest).piece.name == Chess::Piece::PAWN)
    end
    
    def test_move_colour
        # Ensure that the peice remains the same colour on move
        board = GameState.new()
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
        board = GameState.new()
        coord = Coord.new(0,5)
        piece = Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK)
        board.place_piece(coord, piece)
        square = board.sq_at(coord)
        assert(!square.piece.nil?)
        assert(square.piece.colour.black?) 
        assert(square.piece.name == Chess::Piece::ROOK)
    end

    def test_should_place_piece_over_existing_piece
        board = GameState.new()
        coord = Coord.new(0, 5)
        piece = Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK)
        board.place_piece(coord, Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::QUEEN))
        board.place_piece(coord, piece)
        square = board.sq_at(coord)
        assert_not_nil(square.piece)
        assert(square.piece.colour.black?)
        assert_equal(piece.name, square.piece.name)
    end
    
    def test_remove_piece
        board = GameState.new()
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
        b = GameState.new()
        b.clear()
        
        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))        
        b.place_piece(Coord.new(3, 3), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 3)))
        
        b.place_piece(Coord.new(0, 3), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(0, 4)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 2)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(0, 3)))
        
        b.place_piece(Coord.new(3, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))
        assert(b.blocked?(Coord.new(0, 0), Coord.new(4, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(2, 0)))
        assert(!b.blocked?(Coord.new(0, 0), Coord.new(3, 0)))
        
        # Make sure it works for squares other than the origin
        c0 = Coord.new(2, 3)
        c1 = Coord.new(5, 6)
        
        b.place_piece(c0, Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))
        b.place_piece(c1, Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN))
        assert(b.blocked?(c0, Coord.new(6, 7)))
        assert(!b.blocked?(c0, Coord.new(4, 5)))
        assert(!b.blocked?(c0, c1))
        
        # Unit test for a bug condition -> Rook can hop a pawn
        b = GameState.new()
        assert(b.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
    end
    
    def test_white_pawn_in_centre_should_attack_upwards()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            --p-----
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::WHITE)

        expected = check_attack_bv(b, Chess::Colour::WHITE, "
            --------
            --------
            --------
            -*-*----
            --------
            --------
            --------
            --------
        ");
    end

    def test_black_pawn_in_centre_should_attack_downwards()
        b = GameState.new()
        b.clear()
        place_pieces(b, "
            --------
            --------
            --------
            --------
            --P-----
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::BLACK)

        expected = check_attack_bv(b, Chess::Colour::BLACK, "
            --------
            --------
            --------
            --------
            --------
            -*-*----
            --------
            --------
        ");
    end

    def test_white_pawn_on_left_edge_should_attack_upwards()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            p-------
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::WHITE)

        expected = check_attack_bv(b, Chess::Colour::WHITE, "
            --------
            --------
            --------
            -*------
            --------
            --------
            --------
            --------
        ");
    end

    def test_black_pawn_on_left_edge_should_attack_upwards()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            P-------
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::BLACK)

        expected = check_attack_bv(b, Chess::Colour::BLACK, "
            --------
            --------
            --------
            --------
            --------
            -*------
            --------
            --------
        ");
    end

    def test_white_pawn_on_right_edge_should_attack_upwards()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            -------p
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::WHITE)

        expected = check_attack_bv(b, Chess::Colour::WHITE, "
            --------
            --------
            --------
            ------*-
            --------
            --------
            --------
            --------
        ");
    end

    def test_black_pawn_on_left_edge_should_attack_upwards()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            -------P
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::BLACK)

        expected = check_attack_bv(b, Chess::Colour::BLACK, "
            --------
            --------
            --------
            --------
            --------
            ------*-
            --------
            --------
        ");
    end

    def test_white_pawn_on_top_edge_should_not_attack()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            ----p---
            --------
            --------
            --------
            --------
            --------
            --------
            --------
        ");
        b.calculate_pawn_attack(Chess::Colour::WHITE)

        expected = check_attack_bv(b, Chess::Colour::WHITE, "
            --------
            --------
            --------
            --------
            --------
            --------
            --------
            --------
        ");
    end

    def test_black_pawn_on_bottem_edge_should_not_attack()
        b = GameState.new()
        b.clear()

        place_pieces(b, "
            --------
            --------
            --------
            --------
            --------
            --------
            --------
            ---P----
        ");
        b.calculate_pawn_attack(Chess::Colour::BLACK)

        expected = check_attack_bv(b, Chess::Colour::BLACK, "
            --------
            --------
            --------
            --------
            --------
            --------
            --------
            --------
        ");
    end
        
    def test_calculate_rook_attack()
        b = GameState.new()
        
        # Test the corner
        b.clear()
        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::ROOK))
        b.calculate_rook_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 7)))
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 0)))

        # Test the middle
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::ROOK))
        b.calculate_rook_attack(Chess::Colour::WHITE)

        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 7)))
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 4)))

        # Test the blocked peice
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::ROOK))
        b.place_piece(Coord.new(2, 4), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(6, 4), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(4, 2), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(4, 6), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.calculate_rook_attack(Chess::Colour::WHITE)
      
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 7)))
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(1, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(7, 4)))
    end
    
    def test_calculate_knight_attack()
        b = GameState.new()
        
        # Test the middle board attacks
        b.clear()
        
        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KNIGHT))
        b.place_piece(Coord.new(0, 7), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KNIGHT))
        b.place_piece(Coord.new(7, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KNIGHT))
        b.place_piece(Coord.new(7, 7), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KNIGHT))
        b.calculate_knight_attack(Chess::Colour::WHITE)
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 1)))
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 6)))
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 1)))
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 6)))
        
        b.clear()
        
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KNIGHT))
        b.calculate_knight_attack(Chess::Colour::WHITE)
        
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 5)))
    end      

    def test_calculate_bishop_attack()
        b = GameState.new()
        
        # Test the corner
        b.clear()
        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        b.calculate_bishop_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 1)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(1, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
        
        
        # Test the middle
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        b.calculate_bishop_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
        
        # Test the blocked peice
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        b.place_piece(Coord.new(5, 5), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(3, 5), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.calculate_bishop_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(1, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
    end
    
    def test_calculate_queen_attack()
        b = GameState.new()
        
        # Test the corner
        b.clear()
        b.place_piece(Coord.new(0, 0), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::QUEEN))
        b.calculate_queen_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(1, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 0)))
        
        
        # Test the middle
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::QUEEN))
        b.calculate_queen_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 4)))
        
        # Test the blocked peice
        b.clear()
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::QUEEN))
        b.place_piece(Coord.new(5, 5), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(3, 5), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.place_piece(Coord.new(4, 2), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::ROOK))
        b.calculate_queen_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 0)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 6)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(7, 7)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(1, 7)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 1)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 0)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 1)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 2)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 6)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 7)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(1, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(6, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(7, 4)))
    end
    
    def test_calculate_king_attack()
        b = GameState.new()
        
        # Test the middle board attacks
        b.clear()
        
        b.place_piece(Coord.new(4, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KING))
        b.calculate_king_attack(Chess::Colour::WHITE)
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(3, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(4, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(5, 2)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 2)))
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 3)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 3)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 3)))
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 4)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 4)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 4)))
        
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(2, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(3, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(4, 5)))
        assert(b.attacked?(Chess::Colour::WHITE, Coord.new(5, 5)))
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(6, 5)))
        
        # Left side
        b.clear()
        b.place_piece(Coord.new(0, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KING))
        b.calculate_king_attack(Chess::Colour::WHITE)
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(7, 4)))
        
        #Right side
        b.clear()
        b.place_piece(Coord.new(7, 4), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::KING))
        b.calculate_king_attack(Chess::Colour::WHITE)
        assert(!b.attacked?(Chess::Colour::WHITE, Coord.new(0, 4)))
    end      
    
    def test_on_file? 
        b = GameState.new;
        
        bv0_7 = 0x01 << GameState.get_sw(Coord.new(0, 7))
        bv0_4 = 0x01 << GameState.get_sw(Coord.new(0, 4))
        bv4_7 = 0x01 << GameState.get_sw(Coord.new(4, 7))
        
        assert(b.on_file?(bv0_7, bv0_4))
        assert(b.on_file?(bv0_4, bv0_7))
        
        assert(b.on_file?(bv0_7, bv0_7))
        
        assert(!b.on_file?(bv0_7, bv4_7))
        assert(!b.on_file?(bv4_7, bv0_7))        
    end
    
    def test_on_rank?
        b = GameState.new;
        
        bv0_0 = 0x01 << GameState.get_sw(Coord.new(0, 0))        
        bv0_4 = 0x01 << GameState.get_sw(Coord.new(0, 4))        
        bv0_7 = 0x01 << GameState.get_sw(Coord.new(0, 7))
        bv4_7 = 0x01 << GameState.get_sw(Coord.new(4, 7))
        bv7_0 = 0x01 << GameState.get_sw(Coord.new(7, 0))        
        
        assert(b.on_rank?(bv0_7, bv4_7))
        assert(b.on_rank?(bv4_7, bv0_7))
        
        assert(b.on_rank?(bv0_0, bv7_0))
        
        assert(b.on_rank?(bv0_7, bv0_7))
        
        assert(!b.on_rank?(bv0_7, bv0_4))
        assert(!b.on_rank?(bv0_4, bv0_7))
    end
    
    def test_on_diagonal_sw_ne
        b = GameState.new
        
        bv1_3 = 0x1 << GameState.get_sw(Coord.new(1, 3))
        bv2_4 = 0x1 << GameState.get_sw(Coord.new(2, 4))
        bv3_5 = 0x1 << GameState.get_sw(Coord.new(3, 5))
        
        assert(b.on_diagonal?(bv1_3, bv2_4))
        assert(b.on_diagonal?(bv1_3, bv3_5))
        assert(b.on_diagonal?(bv2_4, bv3_5))
        
        assert(b.on_diagonal?(bv2_4, bv1_3))
        assert(b.on_diagonal?(bv3_5, bv1_3))
        assert(b.on_diagonal?(bv3_5, bv2_4))        
    end
    
    def test_on_diagonal_nw_se
        b = GameState.new
        
        bv1_6 = 0x1 << GameState.get_sw(Coord.new(1, 6))
        bv2_5 = 0x1 << GameState.get_sw(Coord.new(2, 5))
        bv5_2 = 0x1 << GameState.get_sw(Coord.new(5, 2))
        
        assert(b.on_diagonal?(bv1_6, bv2_5))
        assert(b.on_diagonal?(bv2_5, bv5_2))
        assert(b.on_diagonal?(bv1_6, bv5_2))
        
        assert(b.on_diagonal?(bv2_5, bv1_6))
        assert(b.on_diagonal?(bv5_2, bv2_5))
        assert(b.on_diagonal?(bv5_2, bv1_6))        
    end

    def test_get_bv
        assert_equal(GameState.get_bv(Coord.new(7, 7)), (0x1 << GameState.get_sw(Coord.new(7, 7))))
    end        
    
    def test_get_rank
        assert_equal(7, GameState.get_rank(GameState.get_bv(Coord.new(7, 7))))
        assert_equal(4, GameState.get_rank(GameState.get_bv(Coord.new(3, 4))))
    end
    
    def test_get_rank_mask
        assert_equal(GameState::RANK_MASKS[7], GameState.get_rank_mask(GameState.get_bv(Coord.new(7, 7))))
        assert_equal(GameState::RANK_MASKS[4], GameState.get_rank_mask(GameState.get_bv(Coord.new(3, 4))))
    end    
    
    def test_get_file
        assert_equal(7, GameState.get_file(GameState.get_bv(Coord.new(7, 7))))
        assert_equal(3, GameState.get_file(GameState.get_bv(Coord.new(3, 4))))
    end
    
    def test_get_file_mask
        assert_equal(GameState::FILE_MASKS[7], GameState.get_file_mask(GameState.get_bv(Coord.new(7, 7))))
        assert_equal(GameState::FILE_MASKS[3], GameState.get_file_mask(GameState.get_bv(Coord.new(3, 4))))
    end
    
    def test_on_board
        assert(GameState.on_board?(GameState.get_bv(Coord.new(7, 7))))
        assert(GameState.on_board?(GameState.get_bv(Coord.new(0, 0))))
        assert(!GameState.on_board?(GameState.get_bv(Coord.new(7, 8))))
        assert(!GameState.on_board?(GameState.get_bv(Coord.new(8, 7))))
    end
    
    def test_find_east_edge
        assert_equal(GameState.get_bv(Coord.new(7, 7)), 
                     GameState.find_east_edge(GameState.get_bv(Coord.new(3, 7))))
        assert_equal(GameState.get_bv(Coord.new(7, 0)),
                     GameState.find_east_edge(GameState.get_bv(Coord.new(4, 0))))                     
    end    
    
    def test_find_west_edge
        assert_equal(GameState.get_bv(Coord.new(0, 7)),
                     GameState.find_west_edge(GameState.get_bv(Coord.new(3, 7))))
        assert_equal(GameState.get_bv(Coord.new(0, 0)),
                     GameState.find_west_edge(GameState.get_bv(Coord.new(4, 0))))                     
    end                     

    def test_chk_mv_pawn
        e = GameState.new
        
        # cannot move a "pawn" from an empty square
        assert_equal(e.chk_mv(Coord.from_alg('e3'), Coord.from_alg('e4')), false)
        
        # can move one square forward
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), true)
                                
        # cannot move one square forward if blocked
        e.place_piece(Coord.from_alg('e3'), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), false)
                                
        # cannot move two squares forward if blocked
        assert(!e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e4')))
                                
        # cannot move diagonally if not a capture
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                                
        # can move diagonally if a capture
        e.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), true)
                                
        # cannot capture the same colored piece
        e.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                                
        # make sure it works both ways
        e.place_piece(Coord.from_alg('d6'), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e7'), Coord.from_alg('f6')), false)                       
    end
    
    def test_check_mv_bishop
        e = GameState.new
        
        # cannot move a blocked bishop
        assert(!e.chk_mv(Coord.from_alg('c1'), Coord.from_alg('e3')))
        e.remove_piece(Coord.from_alg('d2'))
        assert(e.chk_mv(Coord.from_alg('c1'), Coord.from_alg('e3')))

    end
    
    def test_rook_cannot_hop_pawn
        # Unit test for a bug condition -> Rook can hop a pawn
        e = GameState.new
        assert(e.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
    end

    private

    # A string representation of a board will look like this:
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    #
    # Replace a dash with the fen character you wish to place
    def place_pieces(gamestate, string_board)
        pt = Translator::PieceTranslator.new()
        string_board.gsub!(/\s+/, "")
        puts "Error: given board malformed!" if string_board.length != 64;

        0.upto(63) do |i|
            next if string_board[i].chr == '-';

            coord_notation = get_alg_coord_notation(i)
            coord = Coord.from_alg(coord_notation)
            gamestate.place_piece(coord, pt.from_txt(string_board[i].chr))
        end
    end

    # A string representation of a board will look like this:
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    # --------
    #
    # A - represents a square not under attack.
    # A * represents a square under attack
    # All whitespace is ignored.
    def check_attack_bv(gamestate, clr, raw_string_board)
        string_board = raw_string_board.gsub(/\s+/, "")
        puts "Error: given board malformed!" if string_board.length != 64;

        bv = 0
        0.upto(63) do |i|
            coord_notation = get_alg_coord_notation(i)
            coord = Coord.from_alg(coord_notation)

            expected = string_board[i].chr == '*'
            actual = gamestate.attacked?(clr, coord);

            
            assert_equal(expected, actual, 
                "Checking coord #{coord_notation}\n" +
                "Board: \n#{gamestate.to_txt}\n" +
                "Attack Board: #{raw_string_board}")
        end
        bv
    end

    # Creates a alg coord notation for an index in a bv
    def get_alg_coord_notation(i)
        x = i % 8;
        y = 8 - ((i - x) / 8)

        (97 + x).chr + y.to_s
    end
end
