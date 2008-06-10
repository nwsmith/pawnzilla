#
# $Id$
#
# Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
$:.unshift File.join(File.dirname(__FILE__), "..", "src")
$:.unshift File.join(File.dirname(__FILE__), "..", "test")

require "test/unit"
require "pz_unit"
require "colour"
require "rulesengine"
require "chess"
require "geometry"
require "tr"
require "test_game_runner"
require "test_move_engine"

class RulesEngineTest < Test::Unit::TestCase
  def setup 
    @board = RulesEngine.new
  end
  #----------------------------------------------------------------------------
  # Start bit-vector helper tests
  #----------------------------------------------------------------------------
  def test_get_coord_from_bv_should_fail_when_more_than_one_bit_set
    assert_raises(ArgumentError) {RulesEngine.get_coord_for_bv(0x03)}    
  end
  
  def test_get_coord_from_bv_should_not_faile_when_one_bit_set
    assert_nothing_raised {RulesEngine.get_coord_for_bv(0x02)} 
  end
  
  def test_get_coord_from_bv_should_return_H8
    assert_equal H8, RulesEngine.get_coord_for_bv(0x00_00_00_00_00_00_00_01) 
  end
  
  def test_get_coord_from_bv_should_return_A1
    assert_equal A1, RulesEngine.get_coord_for_bv(0x80_00_00_00_00_00_00_00)
  end
  
  def test_get_sw_should_get_correct_value_for_H8
    assert_equal RulesEngine.get_sw(H8), 0
  end
  #----------------------------------------------------------------------------
  # End bit-vector helper tests
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Start board helper tests
  #----------------------------------------------------------------------------  
  def test_should_get_white_piece_on_black_square_from_initial_setup
    square = @board.sq_at(A1)
    assert_not_nil(square)
    assert(square.colour.black?)
    assert_not_nil(square.piece)
    assert(square.piece.colour.white?)
    assert_equal(Chess::Piece::ROOK, square.piece.name)
  end

  def test_should_get_empty_square_from_initial_setup
    square = @board.sq_at(A3)
    assert_not_nil(square)
    assert(square.colour.black?)
    assert_nil(square.piece)
  end

  def test_should_get_black_piece_on_white_square_from_initial_setup
    square = @board.sq_at(C8)
    assert_not_nil(square)
    assert(square.colour.white?)
    assert_not_nil(square.piece)
    assert(square.piece.colour.black?)
    assert_equal(Chess::Piece::BISHOP, square.piece.name)
  end
  
  def test_attacked_should_work_for_simple_file_attack
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - R - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")  
    assert(e.attacked?(Colour::BLACK, F1))
  end
  
  def test_attacked_should_work_for_simple_file_attack_on_C1_bug
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - R - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")  
    assert(e.attacked?(Colour::BLACK, C1))
  end
 
  # TODO: Fix assert_blocked_state
  def test_blocked
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      ---p----
      --------
      --------
      p-------
    ")

    expected = "
      -------*
      ------*-
      -----*--
      ----*---
      --------
      --------
      --------
      --------
    "
    #assert_blocked_state(expected, b, A1)

    place_pieces(b, "
      --------
      --------
      --------
      --------
      p--p----
      --------
      --------
      p-------
    ")

    expected = "
      *------*
      *-----*-
      *----*--
      *---*---
      --------
      --------
      --------
      --------
    "
    #assert_blocked_state(expected, b, A1)

    place_pieces(b, "
      --------
      --------
      --------
      --------
      p--p----
      --------
      --------
      p--p----
    ")

    expected = "
      *------*
      *-----*-
      *----*--
      *---*---
      --------
      --------
      --------
      ----****
    "
    #assert_blocked_state(expected, b, A1)

    place_pieces(b, "
      --------
      -----p--
      --------
      --------
      p-pp----
      --------
      --------
      p--p----
    ")

    expected = "
      ------*-
      --------
      --------
      --------
      ----****
      --------
      --------
      --------
    "
    #assert_blocked_state(expected, b, C4)

    # Unit test for a bug condition -> Rook can hop a pawn
    b = RulesEngine.new()
    expected = "
      ******--
      --------
      -------*
      -------*
      -------*
      -------*
      -------*
      -------*
    "
    
    #assert_blocked_state(expected, b, H8)
  end
 
  def test_bishop_should_not_be_blocked_by_capturable_pawn
    e = RulesEngine.new
    place_pieces(e, "      
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - P - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - b - k - - -
    ")
    assert(!e.blocked?(C1, G5))
    assert(e.chk_mv(C1, G5))
  end
  
  def test_on_diagonal_nw_se
    b = RulesEngine.new
    
    bv1_6 = 0x1 << RulesEngine.get_sw(Coord.new(1, 6))
    bv2_5 = 0x1 << RulesEngine.get_sw(Coord.new(2, 5))
    bv5_2 = 0x1 << RulesEngine.get_sw(Coord.new(5, 2))
    
    assert(b.on_diagonal?(bv1_6, bv2_5))
    assert(b.on_diagonal?(bv2_5, bv5_2))
    assert(b.on_diagonal?(bv1_6, bv5_2))
    
    assert(b.on_diagonal?(bv2_5, bv1_6))
    assert(b.on_diagonal?(bv5_2, bv2_5))
    assert(b.on_diagonal?(bv5_2, bv1_6))    
  end
  
  def test_on_diagonal_sw_ne
    b = RulesEngine.new
    
    bv1_3 = 0x1 << RulesEngine.get_sw(Coord.new(1, 3))
    bv2_4 = 0x1 << RulesEngine.get_sw(Coord.new(2, 4))
    bv3_5 = 0x1 << RulesEngine.get_sw(Coord.new(3, 5))
    
    assert(b.on_diagonal?(bv1_3, bv2_4))
    assert(b.on_diagonal?(bv1_3, bv3_5))
    assert(b.on_diagonal?(bv2_4, bv3_5))
    
    assert(b.on_diagonal?(bv2_4, bv1_3))
    assert(b.on_diagonal?(bv3_5, bv1_3))
    assert(b.on_diagonal?(bv3_5, bv2_4))    
  end

  def test_on_file? 
    b = RulesEngine.new;
    
    bv0_7 = 0x01 << RulesEngine.get_sw(Coord.new(0, 7))
    bv0_4 = 0x01 << RulesEngine.get_sw(Coord.new(0, 4))
    bv4_7 = 0x01 << RulesEngine.get_sw(Coord.new(4, 7))
    
    assert(b.on_file?(bv0_7, bv0_4))
    assert(b.on_file?(bv0_4, bv0_7))
    
    assert(b.on_file?(bv0_7, bv0_7))
    
    assert(!b.on_file?(bv0_7, bv4_7))
    assert(!b.on_file?(bv4_7, bv0_7))    
  end
  
  def test_on_rank_on_bottom_should_be_true_both_directions
    b = RulesEngine.new
    a1_bv = 0x01 << RulesEngine.get_sw(A1)
    h1_bv = 0x01 << RulesEngine.get_sw(H1)
    
    assert(b.on_rank?(a1_bv, h1_bv))
    assert(b.on_rank?(h1_bv, a1_bv))
  end  
  
  def test_on_rank_on_top_should_be_true_both_directions
    b = RulesEngine.new
    a8_bv = 0x01 << RulesEngine.get_sw(A8)
    h8_bv = 0x01 << RulesEngine.get_sw(H8)
    
    assert(b.on_rank?(a8_bv, h8_bv))
    assert(b.on_rank?(h8_bv, a8_bv))
  end
  
  def test_on_rank_in_centre_should_be_true_both_directions
    b = RulesEngine.new
    a4_bv = 0x01 << RulesEngine.get_sw(A4)
    h4_bv = 0x01 << RulesEngine.get_sw(H4)
    
    assert(b.on_rank?(a4_bv, h4_bv))
    assert(b.on_rank?(h4_bv, a4_bv))
  end
  
  def test_on_rank_should_not_be_true_for_same_file
    b = RulesEngine.new
    a1_bv = 0x01 << RulesEngine.get_sw(A1)
    a8_bv = 0x01 << RulesEngine.get_sw(A8)
    
    assert(!b.on_rank?(a1_bv, a8_bv))
    assert(!b.on_rank?(a8_bv, a1_bv))
  end
  
  def test_on_rank_shold_not_be_true_for_same_diagonal
    b = RulesEngine.new
    a1_bv = 0x01 << RulesEngine.get_sw(A1)
    h8_bv = 0x01 << RulesEngine.get_sw(H8)
    
    assert(!b.on_rank?(a1_bv, h8_bv))
    assert(!b.on_rank?(h8_bv, a1_bv))
  end
  
  def test_find_east_edge
    assert_equal(RulesEngine.get_bv(Coord.new(7, 7)), 
           RulesEngine.find_east_edge(RulesEngine.get_bv(Coord.new(3, 7))))
    assert_equal(RulesEngine.get_bv(Coord.new(7, 0)),
           RulesEngine.find_east_edge(RulesEngine.get_bv(Coord.new(4, 0))))           
  end    
  
  def test_find_west_edge
    assert_equal(RulesEngine.get_bv(Coord.new(0, 7)),
           RulesEngine.find_west_edge(RulesEngine.get_bv(Coord.new(3, 7))))
    assert_equal(RulesEngine.get_bv(Coord.new(0, 0)),
           RulesEngine.find_west_edge(RulesEngine.get_bv(Coord.new(4, 0))))           
  end           
  
  def test_get_file
    assert_equal(7, RulesEngine.get_file(RulesEngine.get_bv(Coord.new(7, 7))))
    assert_equal(3, RulesEngine.get_file(RulesEngine.get_bv(Coord.new(3, 4))))
  end
  
  def test_get_file_mask
    assert_equal(RulesEngine::FILE_MASKS[7], RulesEngine.get_file_mask(RulesEngine.get_bv(Coord.new(7, 7))))
    assert_equal(RulesEngine::FILE_MASKS[3], RulesEngine.get_file_mask(RulesEngine.get_bv(Coord.new(3, 4))))
  end

  def test_get_bv
    assert_equal(RulesEngine.get_bv(Coord.new(7, 7)), (0x1 << RulesEngine.get_sw(Coord.new(7, 7))))
  end      
  
  def test_get_rank
    assert_equal(7, RulesEngine.get_rank(RulesEngine.get_bv(Coord.new(7, 7))))
    assert_equal(4, RulesEngine.get_rank(RulesEngine.get_bv(Coord.new(3, 4))))
  end
  
  def test_get_rank_mask
    assert_equal(RulesEngine::RANK_MASKS[7], RulesEngine.get_rank_mask(RulesEngine.get_bv(Coord.new(7, 7))))
    assert_equal(RulesEngine::RANK_MASKS[4], RulesEngine.get_rank_mask(RulesEngine.get_bv(Coord.new(3, 4))))
  end    
  
  def test_on_board
    assert(RulesEngine.on_board?(RulesEngine.get_bv(Coord.new(7, 7))))
    assert(RulesEngine.on_board?(RulesEngine.get_bv(Coord.new(0, 0))))
    assert(!RulesEngine.on_board?(RulesEngine.get_bv(Coord.new(7, 8))))
    assert(!RulesEngine.on_board?(RulesEngine.get_bv(Coord.new(8, 7))))
  end  
  
  def test_calc_board_vector_should_do_full_board_north
    line = RulesEngine.calc_board_vector(Coord.from_alg("a1"), Coord::NORTH)
    assert_equal(A1, line.c0)
    assert_equal(A8, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_south
    line = RulesEngine.calc_board_vector(Coord.from_alg("a8"), Coord::SOUTH)
    assert_equal(A8, line.c0)
    assert_equal(A1, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_east
    line = RulesEngine.calc_board_vector(Coord.from_alg("a1"), Coord::EAST)
    assert_equal(A1, line.c0)
    assert_equal(H1, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_west
    line = RulesEngine.calc_board_vector(Coord.from_alg("h1"), Coord::WEST)
    assert_equal(H1, line.c0)
    assert_equal(A1, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_north_east
    line = RulesEngine.calc_board_vector(Coord.from_alg("a1"), Coord::NORTHEAST)
    assert_equal(A1, line.c0)
    assert_equal(H8, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_north_west
    line = RulesEngine.calc_board_vector(Coord.from_alg("h1"), Coord::NORTHWEST)
    assert_equal(H1, line.c0)
    assert_equal(A8, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_south_east
    line = RulesEngine.calc_board_vector(Coord.from_alg("a8"), Coord::SOUTHEAST)
    assert_equal(A8, line.c0)
    assert_equal(H1, line.c1)
  end
  
  def test_calc_board_vector_should_do_full_board_south_west
    line = RulesEngine.calc_board_vector(Coord.from_alg("h8"), Coord::SOUTHWEST)
    assert_equal(H8, line.c0)
    assert_equal(A1, line.c1)
  end
  
  #----------------------------------------------------------------------------
  # End board helper tests
  #----------------------------------------------------------------------------  
  
  #----------------------------------------------------------------------------
  # Start piece helper tests
  #----------------------------------------------------------------------------
  def test_move_should_not_change_peice_properties
    board = RulesEngine.new()
    src = A2
    dest = A3
    board.move_piece(src, dest)
    assert(board.sq_at(src).piece.nil?)
    assert(!board.sq_at(dest).piece.nil?)
    assert(board.sq_at(dest).piece.colour.white?)
    assert(board.sq_at(dest).piece.name == Chess::Piece::PAWN)
  end
  
  def test_move_should_not_chance_peice_colour
    board = RulesEngine.new()
    src = D7
    dest = D5
    board.move_piece(src, dest);
    assert(board.sq_at(dest).piece.colour.black?);
    
    src = D2
    dest = D3
    board.move_piece(src, dest);
    assert(board.sq_at(dest).piece.colour.white?);
  end
  
  def test_piece_should_move
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - k -
      - - - - - - - - 
      - - - - - - - - 
      - - - - p - - -   
      - - - - - - - - 
    ")
    e.move!(E2, E4)
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - k -
      - - - - p - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    "
    assert_state(expected, e)     
  end
  
  def test_pawn_should_not_disappear_when_capturing
    white_move_engine = TestMoveEngine.new
    black_move_engine = TestMoveEngine.new
    white_move_engine.add_move(Move.new(Coord.from_alg("e2"), Coord.from_alg("e3")))
    black_move_engine.add_move(Move.new(Coord.from_alg("g7"), Coord.from_alg("g5")))
    white_move_engine.add_move(Move.new(Coord.from_alg("c2"), Coord.from_alg("c3")))
    black_move_engine.add_move(Move.new(Coord.from_alg("a7"), Coord.from_alg("a5")))
    white_move_engine.add_move(Move.new(Coord.from_alg("g2"), Coord.from_alg("g3")))
    black_move_engine.add_move(Move.new(Coord.from_alg("f7"), Coord.from_alg("f6")))
    white_move_engine.add_move(Move.new(Coord.from_alg("a2"), Coord.from_alg("a4")))
    black_move_engine.add_move(Move.new(Coord.from_alg("g5"), Coord.from_alg("g4")))
    white_move_engine.add_move(Move.new(Coord.from_alg("b1"), Coord.from_alg("a3")))
    black_move_engine.add_move(Move.new(Coord.from_alg("a8"), Coord.from_alg("a7")))
    white_move_engine.add_move(Move.new(Coord.from_alg("e1"), Coord.from_alg("e2")))
    black_move_engine.add_move(Move.new(Coord.from_alg("e8"), Coord.from_alg("f7")))
    white_move_engine.add_move(Move.new(Coord.from_alg("c3"), Coord.from_alg("c4")))
    black_move_engine.add_move(Move.new(Coord.from_alg("a7"), Coord.from_alg("a8")))
    white_move_engine.add_move(Move.new(Coord.from_alg("g1"), Coord.from_alg("h3")))
    black_move_engine.add_move(Move.new(Coord.from_alg("f8"), Coord.from_alg("h6")))
    white_move_engine.add_move(Move.new(Coord.from_alg("f1"), Coord.from_alg("g2")))
    black_move_engine.add_move(Move.new(Coord.from_alg("f6"), Coord.from_alg("f5")))
    white_move_engine.add_move(Move.new(Coord.from_alg("e3"), Coord.from_alg("e4")))
    black_move_engine.add_move(Move.new(Coord.from_alg("a8"), Coord.from_alg("a7")))
    white_move_engine.add_move(Move.new(Coord.from_alg("h1"), Coord.from_alg("g1")))
    runner = TestGameRunner.new(white_move_engine, black_move_engine)
    runner.replay
    e = runner.rules_engine
    e.move!(F5, E4)
    expected = "
      - N B Q - - N R
      R P P P P K - P
      - - - - - - - B
      P - - - - - - -
      p - p - P - P -
      n - - - - - p n
      - p - p k p b p
      r - b q - - r -
    "
    assert_state(expected, e)     
  end
  
  def test_knight_cannot_capture_own_piece
    e = RulesEngine.new
    place_pieces(e, "
      R N B Q K B N R 
      P P P P - - - P 
      - - - - - - - - 
      - - - - P P P - 
      - - - - - - - - 
      - - n - - p - p 
      p p p p p k p -   
      r - b q - b n r 
    ")
    assert(e.move?(B8, D7) == false)
  end

  def test_white_should_be_able_to_castle_kingside
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - r 
    ")
    e.move!(E1, G1)
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - r k - 
    "
    assert_state(expected, e) 
  end

  def test_white_should_be_able_to_castle_queenside
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      r - - - k - - -
    ")
    e.move!(E1, C1)
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - k r - - - - 
    "
    assert_state(expected, e) 
  end

  def test_black_should_be_able_to_castle_kingside
    e = RulesEngine.new
    place_pieces(e, "
      - - - - K - - R
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    e.move!(E8, G8)
    expected = "
      - - - - - R K -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    "
    assert_state(expected, e) 
  end
  
  def test_black_should_be_able_to_castle_queenside
    e = RulesEngine.new
    place_pieces(e, "
      R - - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - -
    ")
    e.move!(E8, C8)
    expected = "
      - - K R - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    "
    assert_state(expected, e) 
  end
  
  def test_place_piece_should_place_proper_peice_and_colour
    board = RulesEngine.new()
    coord = A6
    piece = Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK)
    board.place_piece(coord, piece)
    square = board.sq_at(coord)
    assert(!square.piece.nil?)
    assert(square.piece.colour.black?) 
    assert(square.piece.name == Chess::Piece::ROOK)
  end

  def test_should_place_piece_over_existing_piece
    board = RulesEngine.new()
    coord = A6
    piece = Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK)
    board.place_piece(coord, Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN))
    board.place_piece(coord, piece)
    square = board.sq_at(coord)
    assert_not_nil(square.piece)
    assert(square.piece.colour.black?)
    assert_equal(piece.name, square.piece.name)
  end
  
  def test_remove_piece
    board = RulesEngine.new()
    coord = A1
    board.remove_piece(coord)
    square = board.sq_at(coord)
    assert(square.piece.nil?)
    
    # Make sure an empty square stays that way
    coord = A6
    board.remove_piece(coord)
    square = board.sq_at(coord)
    assert(square.piece.nil?)
  end
  #----------------------------------------------------------------------------
  # End piece helper tests
  #----------------------------------------------------------------------------  
  
  #----------------------------------------------------------------------------
  # Start attack calculation testing
  #----------------------------------------------------------------------------
  #------
  # Pawn
  #------
  def test_white_pawn_in_centre_should_attack_upwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      -B-B----
      --p-----
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(C4)

    expected = "
      --------
      --------
      --------
      -*-*----
      --------
      --------
      --------
      --------
    "
    assert_bv_equals(expected, bv)
  end

  def test_black_pawn_in_centre_should_attack_downwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      --P-----
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(C4)

    expected = "
      --------
      --------
      --------
      --------
      --------
      -*-*----
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_white_pawn_on_left_edge_should_attack_upwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      p-------
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(A4)

    expected = "
      --------
      --------
      --------
      -*------
      --------
      --------
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_black_pawn_on_left_edge_should_attack_downwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      P-------
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(A4)

    expected = "
      --------
      --------
      --------
      --------
      --------
      -*------
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_white_pawn_on_right_edge_should_attack_upwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      -------p
      --------
      --------
      --------
    ")

    bv = b.calculate_pawn_attack(H4)

    expected = "
      --------
      --------
      --------
      ------*-
      --------
      --------
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_black_pawn_on_right_edge_should_attack_downwards()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      -------P
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(H4)

    expected = "
      --------
      --------
      --------
      --------
      --------
      ------*-
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_white_pawn_on_top_edge_should_not_attack()
    b = RulesEngine.new()
    place_pieces(b, "
      ---p----
      --------
      --------
      --------
      P-------
      --------
      --------
      --------
    ")
    bv = b.calculate_pawn_attack(D8)

    expected = "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    "
    assert_bv_equals(expected, bv)
  end

  def test_black_pawn_on_bottem_edge_should_not_attack()
    b = RulesEngine.new()
    b.clear()
    bv = b.calculate_pawn_attack(D1)

    expected = "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_black_pawn_on_bottem_edge_should_not_attack()
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      ---P----
    ")
    bv = b.calculate_pawn_attack(D1)

    expected = "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    "
    assert_bv_equals(expected, bv)
  end
  
  def test_pawn_should_attack_king
    e = RulesEngine.new
    place_pieces(e, "
      R - - - - - - -
      P B P P - P B -
      - - - Q K N - P
      - - p - - p - -
      r - - - P - - p
      n - - p p - R -
      - b N - - k r -
      - - - q - - - -
    ")
    bv = e.calculate_pawn_attack(F5)
    e.calculate_colour_attack(Colour::WHITE)
    assert(e.check?(Colour::BLACK))
  end
  
  #--------
  # Knight 
  #--------
  def test_corner_knights_should_attack_middle()
    b = RulesEngine.new()
    place_pieces(b, "
      n------n
      --------
      --------
      --------
      --------
      --------
      --------
      n------n
    ")

    bv = b.calculate_knight_attack(A1) \
       | b.calculate_knight_attack(A8) \
       | b.calculate_knight_attack(H1) \
       | b.calculate_knight_attack(H8)

    expected = "
      --------
      --*--*--
      -*----*-
      --------
      --------
      -*----*-
      --*--*--
      --------
    "

    assert_bv_equals(expected, bv)
  end

  def test_centre_knight_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      ---n----
      --------
      --------
      --------
    ")
    bv = b.calculate_knight_attack(D4)

    expected = "
      --------
      --------
      --*-*---
      -*---*--
      --------
      -*---*--
      --*-*---
      --------
    "
    assert_bv_equals(expected, bv)
  end
  
  #--------
  # Bishop 
  #--------
  def test_lower_left_corner_bishop_should_attack_diagonally()
    b = RulesEngine.new()

    place_pieces(b, "
      k-K-----
      --------
      --------
      --------
      --------
      --------
      --------
      b-------
    ")
    b.calculate_bishop_attack(A1)

    expected = "
      -*-----*
      **----*-
      -----*--
      ----*---
      ---*----
      --*-----
      -*------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_lower_right_corner_bishop_should_attack_diagonally()
    b = RulesEngine.new()

    place_pieces(b, "
      -------k
      --------
      -------K
      --------
      --------
      --------
      --------
      -------b
    ")
    b.calculate_bishop_attack(H1)

    expected = "
      *-----*-
      -*----**
      --*-----
      ---*----
      ----*---
      -----*--
      ------*-
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_upper_left_corner_bishop_should_attack_diagonally()
    b = RulesEngine.new()

    place_pieces(b, "
      b---K--k
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(A8)

    expected = "
      ------*-
      -*----**
      --*-----
      ---*----
      ----*---
      -----*--
      ------*-
      -------*
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_upper_right_corner_bishop_should_attack_diagonally()
    b = RulesEngine.new()

    place_pieces(b, "
      --k-K--b
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(H8)

    expected = "
      -*-*----
      -***--*-
      -----*--
      ----*---
      ---*----
      --*-----
      -*------
      *-------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_centre_bishop_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      k-K-----
      --------
      --------
      --------
      ---b----
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(D4)

    expected = "
      -*-----*
      **----*-
      -*---*--
      --*-*---
      --------
      --*-*---
      -*---*--
      *-----*-
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end
  
  def test_centre_bishop_attacks_should_be_blockable()
    b = RulesEngine.new()

    place_pieces(b, "
      -------K
      ---k----
      -Q---Q--
      --------
      ---b----
      --------
      -Q---Q--
      --------
    ")
    b.calculate_bishop_attack(D4)

    expected = "
      --***---
      --*-*---
      -*****--
      --*-*---
      --------
      --*-*---
      -*---*--
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end
  
  def test_bottom_bishop_should_attack_diagonally_adjacent_opposing_piece()
    b = RulesEngine.new()

    place_pieces(b, "
      k------K
      --------
      --------
      --------
      --------
      --------
      -P-P----
      --b-----
    ")
    b.calculate_bishop_attack(C1)

    expected = "
      -*------
      **------
      --------
      --------
      --------
      --------
      -*-*----
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end  

  def test_bishop_should_be_attacking_king
    e = RulesEngine.new
    place_pieces(e, "
      R - N - - K R -
      N Q - - - - - -
      P - p - B P p b
      - n - P - - - p
      - - - P - - - n
      - r p - - - - -
      q - - - p p - -
      P - - k - b - r
    ")
    e.calculate_colour_attack(Colour::WHITE)
    assert(e.check?(Colour::BLACK))
  end
  
  #------
  # Rook
  #------
  def test_rook_attack_in_corner_should_attack_like_an_l
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      R-------
    ")
    bv = b.calculate_rook_attack(A1)

    expected = "
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      -*******
    "

    assert_bv_equals(expected, bv)
  end

  def test_only_one_rook_attack_should_be_generated
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      ----R---
      --------
      --------
      R-------
    ")

    bv = b.calculate_rook_attack(A1)

    expected = "
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      -*******
    "

    assert_bv_equals(expected, bv)
  end
  
  def test_rook_should_not_attack_diagonally_bugfix
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      ----R---
      --------
      --------
      R-------
    ")

    bv = b.calculate_rook_attack(A1)

    expected = "
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      *-------
      -*******
    "

    assert_bv_equals(expected, bv)    
  end

  def test_center_rook_should_attack_file_and_rank
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      --------
      --------
      --------
      R-------
      --------
      --------
      r----r--
    ")
    bv = b.calculate_rook_attack(A1)

    expected = "
      --------
      --------
      --------
      --------
      *-------
      *-------
      *-------
      -****---
    "

    assert_bv_equals(expected, bv)
  end

  def test_pieces_should_block_rook_attack
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      ---P----
      --------
      --Pr--P-
      --------
      --------
      ---P----
      --------
    ")
    bv = b.calculate_rook_attack(D5)

    expected = "
      --------
      ---*----
      ---*----
      --*-***-
      ---*----
      ---*----
      ---*----
      --------
    "

    assert_bv_equals(expected, bv)
  end
  
  def test_own_pieces_should_block_rook_attack
    b = RulesEngine.new()
    place_pieces(b, "
      --------
      ---P----
      --------
      --Pr--r-
      --------
      --------
      ---P----
      --------
    ")
    bv = b.calculate_rook_attack(D5)

    expected = "
      --------
      ---*----
      ---*----
      --*-**--
      ---*----
      ---*----
      ---*----
      --------
    "

    assert_bv_equals(expected, bv)
  end
  
  def test_rook_of_own_colour_should_block_on_rank_and_file()
    b = RulesEngine.new()

    place_pieces(b, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      r - - - - - - - 
      - - - - - - - - 
      r - r - - - - - 
    ")
    bv = b.calculate_rook_attack(A1)

    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -  
      - - - - - - - - 
      * - - - - - - - 
      - * - - - - - - 
    "
    assert_bv_equals(expected, bv)
  end
  
  #-------
  # Queen 
  #-------
  def test_corner_queen_should_attack()
    b = RulesEngine.new()

    place_pieces(b, "
      ---K----
      --------
      --------
      --------
      --------
      -------k
      --------
      q-------
    ")
    b.calculate_queen_attack(A1)

    expected = "
      *------*
      *-----*-
      *----*--
      *---*---
      *--*--**
      *-*---*-
      **----**
      -*******
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_bottom_queen_should_attack()
    b = RulesEngine.new()

    place_pieces(b, "
      k------K
      --------
      --------
      --------
      --------
      --------
      --------
      ---q----
    ")
    b.calculate_queen_attack(D1)

    expected = "
      -*-*----
      **-*----
      ---*----
      ---*---*
      *--*--*-
      -*-*-*--
      --***---
      ***-****
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end
  
  def test_centre_queen_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      -------k
      ---q----
      --------
      --------
      -------K
    ")
    b.calculate_queen_attack(D4)

    expected = "
      ---*---*
      *--*--*-
      -*-*-***
      --***-*-
      ***-****
      --***---
      -*-*-*--
      *--*--*-
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_centre_queen_attack_should_be_blockable()
    b = RulesEngine.new()

    place_pieces(b, "
      -----K-k
      --------
      ---P-P--
      --------
      ---q----
      --------
      --------
      --------
    ")
    b.calculate_queen_attack(D4)

    expected = "
      ------*-
      *-----**
      -*-*-*--
      --***---
      ***-****
      --***---
      -*-*-*--
      *--*--*-
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end
  
  #------
  # King 
  #------
  def test_centre_king_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      ---k----
      --------
      --------
      --------
    ")
    b.calculate_king_attack(Colour::WHITE)

    expected = "
      --------
      --------
      --------
      --***---
      --*-*---
      --***---
      --------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_left_king_should_attack()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      k-------
      --------
      --------
      --------
    ")
    b.calculate_king_attack(Colour::WHITE)

    expected = "
      --------
      --------
      --------
      **------
      -*------
      **------
      --------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_right_king_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      -------k
      --------
      --------
      --------
    ")
    b.calculate_king_attack(Colour::WHITE)

    expected = "
      --------
      --------
      --------
      ------**
      ------*-
      ------**
      --------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_top_king_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      ---k----
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    ")
    b.calculate_king_attack(Colour::WHITE)

    expected = "
      --*-*---
      --***---
      --------
      --------
      --------
      --------
      --------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_bottom_king_should_attack_outwards()
    b = RulesEngine.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      ---k----
    ")
    b.calculate_king_attack(Colour::WHITE)

    expected = "
      --------
      --------
      --------
      --------
      --------
      --------
      --***---
      --*-*---
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end
  #----------------------------------------------------------------------------
  # End attack calculation testing
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Start potential move calculation testing
  #----------------------------------------------------------------------------
  #--------
  # Pawn
  #--------  
  def test_check_calculate_white_pawn_move
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - - 
      - - - - - k - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - p - - - - 
      - - - - - - - - 
      - - - - - - - -
    ")
    expected = "
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
      - - - @ - - - -   
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
    "
    assert_move_state(e, expected, D3);
  end

  def test_check_calculate_black_pawn_move
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - K - 
      - - - - - - - - 
      - - - P - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
    ")
    expected = "
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - @ - - - -
      - - - - - - - -   
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
    "
    assert_move_state(e, expected, D6);
  end
  
  def test_check_calculate_blocked_white_pawn_move
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - b - - - - - 
      - - p - - - - - 
      - - - - - - - - 
    ")
    expected = "
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    "
    assert_move_state(e, expected, C2)
  end
  
  def test_calculate_white_pawn_move_should_work_for_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - p - - - - 
      - - - - - - k - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - @ - - - - 
      - - - @ - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, D2)
  end

  def test_calculate_black_pawn_move_should_work_for_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - K - -
      - - - P - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - @ - - - - 
      - - - @ - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, D7)
  end
  
  def test_calculate_white_pawn_move_should_include_captures
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - B - - - - K 
      - - - p - - - - 
      - - - - - - k - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - @ - - - - 
      - - @ @ - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, D2)    
  end
  
  def test_calculate_black_pawn_move_should_include_captures
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - K - -
      - - - P - - - -
      - - b - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - k - - - - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - @ @ - - - - 
      - - - @ - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, D7)    
  end
  
  #--------
  # Knight
  #--------
  def test_calculate_white_knight_moves_should_work_for_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - k - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - n - - - - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - - 
      @ - @ - - - - - 
      - - - @ - - - -
      - - - - - - - -"
    assert_move_state(e, expected, B1)    
  end
 
  def test_calculate_white_knight_moves_should_work_from_mid_board
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - n - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - k - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - @ - @ - - - 
      - @ - - - @ - -
      - - - - - - - - 
      - @ - - - @ - - 
      - - @ - @ - - -
      - - - - - - - -"
    assert_move_state(e, expected, D4)        
  end
 
  def test_calculate_white_knight_moves_should_work_from_board_edge
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - k - -
      n - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - @ - - - - - -
      - - @ - - - - - 
      - - - - - - - -
      - - @ - - - - - 
      - @ - - - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, A5)    
  end
  
  def test_calculate_black_knight_moves_should_work_for_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - N - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - - - @ - - - -
      @ - @ - - - - - 
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, B8)    
  end
 
  def test_calculate_black_knight_moves_should_work_from_mid_board
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - K -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - N - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - @ - @ - - - 
      - @ - - - @ - -
      - - - - - - - - 
      - @ - - - @ - - 
      - - @ - @ - - -
      - - - - - - - -"
    assert_move_state(e, expected, D4)        
  end
 
  def test_calculate_black_knight_moves_should_work_from_board_edge
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - K -
      - - - - - - - -
      - - - - - - - -
      N - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - @ - - - - - -
      - - @ - - - - - 
      - - - - - - - -
      - - @ - - - - - 
      - @ - - - - - - 
      - - - - - - - -
      - - - - - - - -"
    assert_move_state(e, expected, A5)    
  end
  
  #--------
  # Bishop
  #--------
  def test_calculate_bishop_move_should_work_from_start_square
    e = RulesEngine.new
    place_pieces(e, "
      k - K - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - b - - - - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - @
    - - - - - - @ -
    - - - - - @ - -
    @ - - - @ - - - 
    - @ - @ - - - - 
    - - - - - - - -"
    assert_move_state(e, expected, C1)        
  end
  
  def test_calculate_bishop_move_should_stop_with_opposing_pieces
    e = RulesEngine.new
    place_pieces(e, "
      k - K - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - N - -
      P - - - - - - - 
      - P - - - - - - 
      - - b - - - - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - @ - -
    - - - - @ - - - 
    - @ - @ - - - - 
    - - - - - - - -"
    assert_move_state(e, expected, C1)        
  end

  def test_calculate_bishop_move_should_stop_with_same_colour_pieces
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - K - - -
      - - k - - - - -
      - - - - - - - -
      - - - - - n - -
      P - - - - - - - 
      - p - - - - - - 
      - - b - - - - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - @ - - - 
    - - - @ - - - - 
    - - - - - - - -"
    assert_move_state(e, expected, C1)        
  end

  def test_calculate_bishop_move_should_stop_with_same_colour_bishops
    e = RulesEngine.new
    place_pieces(e, "
      - k - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      K - - - - b - -
      P - - - - - - - 
      - b - - - - - - 
      - - b - - - - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - @ - - - 
    - - - @ - - - - 
    - - - - - - - -"
    assert_move_state(e, expected, C1)        
  end
   
  #------
  # Rook
  #------
  def test_calculate_rook_move_should_work_from_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      r - - - - - - - ")
    expected = "
      @ - - - - - - -
      @ - - - - - - -
      @ - - - - - - - 
      @ - - - - - - -
      @ - - - - - - - 
      @ - - - - - - - 
      @ - - - - - - -
      - @ @ @ @ @ @ @"
    assert_move_state(e, expected, A1)        
  end
  
  def test_calculate_rook_move_should_work_with_other_piece_around
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      R - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      r - - - - r - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      @ - - - - - - -
      @ - - - - - - - 
      @ - - - - - - - 
      @ - - - - - - -
      - @ @ @ @ - - -"
    assert_move_state(e, expected, A1)        
  end 

  #-------
  # Queen
  #-------
  def test_calculate_queen_move_should_work_from_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - k - - - K - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - q - - - - ")
    expected = "
      - - - @ - - - -
      - - - @ - - - -
      - - - @ - - - -
      - - - @ - - - @
      @ - - @ - - @ -
      - @ - @ - @ - - 
      - - @ @ @ - - - 
      @ @ @ - @ @ @ @"
    assert_move_state(e, expected, D1)    
  end

  def test_calculate_queen_move_should_be_stopped_by_opposing_pieces
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - k - K - - - -
      - - - - - - - -
      - - - - - - - -
      - P - P - P - - 
      - - - - - - - - 
      - P - q - P - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - @ - @ - @ - - 
    - - @ @ @ - - - 
    - @ @ - @ @ - -"
    assert_move_state(e, expected, D1)    
  end
  
  def test_calculate_queen_move_should_be_stopped_by_friendly_pieces
    e = RulesEngine.new
    place_pieces(e, "
      - - k - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - p - p - p - - 
      - - - - - - - - 
      - p - q - p - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - - 
    - - @ @ @ - - - 
    - - @ - @ - - -"
    assert_move_state(e, expected, D1)    
  end
  
  def test_calculate_queen_move_should_be_stopped_by_friendly_queens
    e = RulesEngine.new
    place_pieces(e, "
      - - K - k - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - q - q - q - - 
      - - - - - - - - 
      - q - q - q - - ")
    expected = "
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - -
    - - - - - - - - 
    - - @ @ @ - - - 
    - - @ - @ - - -"
    assert_move_state(e, expected, D1)    
  end
    
  #------
  # King
  # ------
  def test_calculate_king_move_should_work_from_start_square
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - k - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - @ @ @ - - 
      - - - @ - @ - -"
    assert_move_state(e, expected, E1)    
  end 

  def test_calculate_king_move_should_work_for_center_king
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - k - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - @ @ @ - - -
      - - @ - @ - - -
      - - @ @ @ - - - 
      - - - - - - - - 
      - - - - - - - -"
    assert_move_state(e, expected, D4)    
  end
  
  def test_calculate_king_move_should_not_allow_moving_into_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - R - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - k - - - ")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - @ @ - - 
      - - - - - @ - -"
    assert_move_state(e, expected, E1)    
  end
  
  def test_calculate_king_move_should_allow_no_moves_for_checkmate
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - p p p 
      - - - - R - - k")
    expected = "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -"
    assert_move_state(e, expected, H1)    
  end
  #----------------------------------------------------------------------------
  # End potential move calculation testing
  #----------------------------------------------------------------------------  

  #----------------------------------------------------------------------------
  # Start legal move check testing
  #----------------------------------------------------------------------------
  
  #------
  # Pawn
  #------
  def test_chk_mv_pawn
    e = RulesEngine.new
    
    # cannot move a "pawn" from an empty square
    assert_equal(e.chk_mv(Coord.from_alg('e3'), Coord.from_alg('e4')), false)
    
    # can move one square forward
    assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), true)
                
    # cannot move one square forward if blocked
    e.place_piece(Coord.from_alg('e3'), Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP))
    assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), false)
                
    # cannot move two squares forward if blocked
    assert(!e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e4')))
                
    # cannot move diagonally if not a capture
    assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                
    # can move diagonally if a capture
    e.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP))
    assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), true)
                
    # cannot capture the same colored piece
    e.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP))
    assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                
    # make sure it works both ways
    e.place_piece(Coord.from_alg('d6'), Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP))
    assert_equal(e.chk_mv(Coord.from_alg('e7'), Coord.from_alg('f6')), false)           
  end

  def test_white_pawn_should_have_en_passant_available_NW
    e = RulesEngine.new

    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - P p - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - - - - k -
    ")
    e.move_list = [Move.new(D7, D5)]
    assert(e.chk_mv(E5, D6)) 
  end

  def test_white_pawn_should_have_en_passant_available_NE
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - p P - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - - - - k -
    ")
    e.move_list = [Move.new(F7, F5)]
    assert(e.chk_mv(E5, F6)) 
  end

  def test_white_pawn_should_not_have_en_passant_available_if_not_pawn
    e = RulesEngine.new
    
    place_pieces(e, "
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - -
      - - - R p - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - - 
    ")
    e.move_list = [Move.new(D7, D5)]
    assert(!e.chk_mv(E5, D5))
  end

  def test_white_pawn_should_not_have_en_passant_available_if_one_square_moved
    e = RulesEngine.new

    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - P p - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - -
    ")
    e.move_list = [Move.new(D6, D5)]
    assert(!e.chk_mv(E5, D6)) 
  end

  def test_black_pawn_should_have_en_passant_available_SW
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - K - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - p P - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    e.move_list = [Move.new(E2, E4)]
    assert(e.chk_mv(F4, E3)) 
  end

  def test_black_pawn_should_have_en_passant_available_SE
    e = RulesEngine.new
    place_pieces(e, "
      - - - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - P p - 
      - - - - - - - - 
      - - - - - - - -   
      - - - k - - - - 
    ")
    e.move_list = [Move.new(G2, G4)]
    assert(e.chk_mv(F4, G3)) 
  end

  def test_black_pawn_should_not_have_en_passant_available_if_not_pawn
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - r P - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    e.move_list = [Move.new(E2, E4)]
    assert(!e.chk_mv(F4, E3)) 
  end

  def test_black_pawn_should_not_have_en_passant_available_if_one_square_moved 
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - p P - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    e.move_list = [Move.new(E3, E4)]
    assert(!e.chk_mv(F4, E3)) 
  end
  
  def test_pawn_blocks_pawn
    # Unit test for a bug condition -> Pawns don't seem to be blocked
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - - 
      - - P - - - - - 
      - - p - - - - - 
      - - - - - - - - 
    ")
    assert(e.blocked?(C2, C3))
  end
  
  #--------
  # Knight
  #--------
  def test_bug_chk_knight_move_allows_moving_to_h1_from_b1
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - n - - - - - - 
    ")
    assert(!e.chk_mv(B1, Coord.new(-1, 1))) 
  end
  
  def test_bug_knight_should_not_be_able_leave_king_in_check
    e = RulesEngine.new
    place_pieces(e, "
      - R B Q K - N R
      P P P N - - B P
      - - - P P - - -
      - b - - - p P -
      - p - - - - - -
      p - n - - n - -
      - b p p - p p p
      r - - q k - - r
    ")
    assert(!e.chk_mv(D7, C5))
  end
  
  #--------
  # Bishop
  #--------
  def test_check_mv_bishop
    e = RulesEngine.new
    
    # cannot move a blocked bishop
    assert(!e.chk_mv(Coord.from_alg('c1'), Coord.from_alg('e3')))
    e.remove_piece(Coord.from_alg('d2'))
    assert(e.chk_mv(Coord.from_alg('c1'), Coord.from_alg('e3')))

  end
  
  def test_bug_bishop_should_be_able_to_do_simple_diagonal_move
    e = RulesEngine.new
    place_pieces(e, "
      R N - Q - K N R
      P - - P B - - P
      B P - - - P - -
      - n P - P p - -
      - p - - p - P -
      - - p k - - - -
      p b - p - - p p
      - - - r q b n r
    ")
    assert(e.chk_mv(B2, C1))
  end
  
  #------
  # Rook
  #------
  def test_rook_cannot_hop_pawn
    # Unit test for a bug condition -> Rook can hop a pawn
    e = RulesEngine.new
    assert(e.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
  end
  
  #------
  # King
  #------
  def test_white_king_should_not_be_able_to_wrap_around_board_bugfix
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - k 
      ")
    assert(!e.chk_mv(H1, Coord.new(8, 1)))
  end
  
  def test_white_king_should_have_kingside_castling_available
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - r 
    ")
    assert(e.chk_mv(E1, G1)) 
  end
  
  def test_white_king_should_be_able_to_move_west
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - - 
      ")
    assert(e.chk_mv(E1, D1))
  end
  
  def test_white_king_should_not_be_able_to_move_into_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - R - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - - 
      ")
    assert(!e.chk_mv(E1, D1))
  end
  
  def test_white_king_should_have_queenside_castling_available
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      r - - - k - - - 
    ")
    assert(e.chk_mv(E1, C1)) 
  end

  def test_black_king_should_have_kingside_castling_available
    e = RulesEngine.new
    place_pieces(e, "
      - - - - K - - R
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    assert(e.chk_mv(E8, G8)) 
  end
  
  def test_white_king_should_have_queenside_castling_available
    e = RulesEngine.new
    place_pieces(e, "
      R - - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    assert(e.chk_mv(E8, C8)) 
  end
   
  def test_white_king_cannot_castle_kingside_through_file_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - K - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - R - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - r 
    ")
    assert(!e.chk_mv(E1, G1))
  end
  
  def test_white_king_cannot_castle_kingside_when_destination_is_attacked
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - R -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - r 
    ")
    assert(!e.chk_mv(E1, G1))    
  end
  
  def test_white_king_cannot_castle_kingside_through_diagaonal_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - K - -
      - - - - - - - -
      - - - - - - - -
      - - B - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - k - - r 
    ")
    assert(!e.chk_mv(E1, G1))
  end
  
  def test_white_king_cannot_castle_queenside_through_file_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - R - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      r - - - k - - - 
    ")
    assert(!e.chk_mv(E1, C1))
  end  
  
  def test_white_king_cannot_castle_queenside_when_destination_attacked
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - R - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      r - - - k - - - 
    ")
    assert(!e.chk_mv(E1, C1))
  end  
  
  def test_white_king_cannot_castle_queenside_through_diagonal_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - K - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - Q - - 
      - - - - - - - - 
      - - - - - - - -   
      r - - - k - - - 
    ")
    assert(!e.chk_mv(E1, C1))
  end
  
  def test_black_king_cannot_castle_kingside_through_file_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - K - - R
      - - - - - - - -
      - - - - - - - -
      - - - - - r - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    assert(!e.chk_mv(E8, G8))
  end
  
  def test_black_king_cannot_castle_kingside_through_diagonal_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - K - - R
      - - - - - - - -
      - - - - - - - -
      - - b - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - k - 
    ")
    assert(!e.chk_mv(E8, G8))
  end  
  
  def test_black_king_cannot_castle_queenside_through_file_check
    e = RulesEngine.new
    place_pieces(e, "
      R - - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - r - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    assert(!e.chk_mv(E8, C8))
  end
  
  def test_black_king_canot_castle_queenside_through_diagonal_check
    e = RulesEngine.new
    place_pieces(e, "
      R - - - K - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - b - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - k - - - - - - 
    ")
    assert(!e.chk_mv(E8, C8))    
  end

  #----------------------------------------------------------------------------
  # End legal move check testing
  #---------------------------------------------------------------------------- 
  
  #----------------------------------------------------------------------------
  # Start checkmate detection testing
  #----------------------------------------------------------------------------  
  def test_should_detect_white_kingside_back_rank_mate
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - p p p   
      - - - R - - k - 
      ")
    assert(e.checkmate?(Colour::WHITE))
  end 

  def test_should_detect_white_queenside_back_rank_mate
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - - 
      p p p - - - - -   
      - k - - R - - - 
      ")
    assert(e.checkmate?(Colour::WHITE))
  end 
  
  def test_should_detect_scholars_mate
    e = RulesEngine.new
    place_pieces(e, "
      R N B - K B N R
      P P P P - P P P
      - - - - P - - -
      - - - - - - - -
      - - - - - - p Q 
      - - - - - p - - 
      p p p p p - - p   
      r n b q k b n r 
      ")
    assert(e.checkmate?(Colour::WHITE))    
  end  
  
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
    assert(e.checkmate?(Colour::BLACK))
  end
  #----------------------------------------------------------------------------
  # End checkmate detection testing
  #---------------------------------------------------------------------------- 
  #----------------------------------------------------------------------------
  # Start check detection testing
  #----------------------------------------------------------------------------
  def test_should_detect_simple_check
    e = RulesEngine.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - R - - - -
      - - - - - - - - 
      - - - - - - - - 
      - - - - - - - -   
      - - - k - - - - 
    ")
    e.calculate_colour_attack(Colour::BLACK)
    assert(e.check?(Colour::WHITE))
  end
  
  def test_pawn_should_give_check
    e = RulesEngine.new
    place_pieces(e, "
      R - - - - - - -
      P B P P - P B -
      - - - Q K N - P
      - - p - - p - -
      r - - - P - - p
      n - - p p - R -
      - b N - - k r -
      - - - q - - - -
    ")
    assert(e.check?(Colour::BLACK))
  end
  
  def test_pawn_should_give_check
    e = RulesEngine.new
    place_pieces(e, "
      R - N - - K R -
      N Q - - - - p -
      P - p - B P - b
      - n - P - - - p
      - - - P - - - n
      - r p - - - - -
      q - - - p p - -
      P - - k - b - r
    ")
    e.calculate_colour_attack(Colour::WHITE)
    assert(e.check?(Colour::BLACK))
  end
  
  #----------------------------------------------------------------------------
  # Start check detection testing
  #----------------------------------------------------------------------------
end
