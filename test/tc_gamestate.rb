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
require "gamestate"
require "chess"
require "geometry"
require "tr"

class TestPieceInfo < Test::Unit::TestCase
  def test_should_get_correct_colour
    pc_info = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    assert_equal(Colour::WHITE, pc_info.colour)
  end  

  def test_equal_piece_info_should_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    assert_equal(lhs, rhs)
  end

  def test_piece_info_with_different_colour_should_not_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP), A1)
    assert_not_equal(lhs, rhs)
  end

  def test_piece_info_with_different_piece_type_should_not_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN), A1)
    assert_not_equal(lhs, rhs)
  end

  def test_piece_info_with_different_coord_should_not_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A2)
    assert_not_equal(lhs, rhs)
  end

  def test_piece_info_with_different_attack_should_not_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1, 0x1)
    assert_not_equal(lhs, rhs)
  end

  def test_piece_info_with_different_move_should_not_be_equal
    lhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1, 0x1, 0x2)
    rhs = PieceInfo::new(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), A1, 0x1, 0x1)
    assert_not_equal(lhs, rhs)
  end
end

class TestPieceInfoBag < Test::Unit::TestCase
  def setup
    @piece_info_bag = PieceInfoBag.new
  end

  def test_should_return_white_rook_for_A1
    expected = PieceInfo.new(Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK), A1)
    assert_equal(expected, @piece_info_bag.pcfcoord(A1))
  end

  def test_should_return_black_rook_for_A8
    expected = PieceInfo.new(Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK), A8)
    assert_equal(expected, @piece_info_bag.pcfcoord(A8))
  end

  def test_should_return_nil_for_A3
    assert_nil(@piece_info_bag.pcfcoord(A3))
  end
end

class TestGameState < Test::Unit::TestCase
  def setup 
    @board = GameState.new
  end

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

  def test_move_should_not_change_peice_properties
    board = GameState.new()
    src = A2
    dest = A3
    board.move_piece(src, dest)
    assert(board.sq_at(src).piece.nil?)
    assert(!board.sq_at(dest).piece.nil?)
    assert(board.sq_at(dest).piece.colour.white?)
    assert(board.sq_at(dest).piece.name == Chess::Piece::PAWN)
  end
  
  def test_move_should_not_chance_peice_colour
    board = GameState.new()
    src = D7
    dest = D5
    board.move_piece(src, dest);
    assert(board.sq_at(dest).piece.colour.black?);
    
    src = D2
    dest = D3
    board.move_piece(src, dest);
    assert(board.sq_at(dest).piece.colour.white?);
  end

  def test_should_modify_piece_info_after_move
    board = GameState.new
    board.move_piece(E2, E4)
    #assert_nil(board.piece_info_bag.pcfcoord(E2))
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN), board.piece_info_bag.pcfcoord(E4).piece)
  end
  
  def test_place_piece_should_place_proper_peice_and_colour
    board = GameState.new()
    coord = A6
    piece = Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK)
    board.place_piece(coord, piece)
    square = board.sq_at(coord)
    assert(!square.piece.nil?)
    assert(square.piece.colour.black?) 
    assert(square.piece.name == Chess::Piece::ROOK)
  end

  def test_should_place_piece_over_existing_piece
    board = GameState.new()
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
    board = GameState.new()
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
  
  def test_blocked
    b = GameState.new()
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
    assert_blocked_state(expected, b, C4)

    # Unit test for a bug condition -> Rook can hop a pawn
    b = GameState.new()
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
  
  def test_white_pawn_in_centre_should_attack_upwards()
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::WHITE, C4)

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
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::BLACK, C4)

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
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::WHITE, A4)

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
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::BLACK, A4)

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
    b = GameState.new()
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

    bv = b.calculate_pawn_attack(Colour::WHITE, H4)

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
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::BLACK, H4)

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
    b = GameState.new()
    bv = b.calculate_pawn_attack(Colour::WHITE, D8)

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
    b = GameState.new()
    b.clear()
    bv = b.calculate_pawn_attack(Colour::BLACK, D1)

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
    b = GameState.new()
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
    bv = b.calculate_pawn_attack(Colour::BLACK, A4)

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

  def test_rook_attack_in_corner_should_attack_like_an_l
    b = GameState.new()
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
    bv = b.calculate_rook_attack(Colour::BLACK, A1)

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
    b = GameState.new()
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

    bv = b.calculate_rook_attack(Colour::BLACK, A1)

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
    b = GameState.new()
    place_pieces(b, "
      --------
      --------
      --------
      ---r----
      --------
      --------
      --------
      --------
    ")
    bv = b.calculate_rook_attack(Colour::WHITE, D5)

    expected = "
      ---*----
      ---*----
      ---*----
      ***-****
      ---*----
      ---*----
      ---*----
      ---*----
    "

    assert_bv_equals(expected, bv)
  end

  def test_pieces_should_block_rook_attack
    b = GameState.new()
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
    bv = b.calculate_rook_attack(Colour::WHITE, D5)

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

  def test_corner_knights_should_attack_middle()
    b = GameState.new()
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

    bv = b.calculate_knight_attack(Colour::WHITE, A1) \
       | b.calculate_knight_attack(Colour::WHITE, A8) \
       | b.calculate_knight_attack(Colour::WHITE, H1) \
       | b.calculate_knight_attack(Colour::WHITE, H8)

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
    b = GameState.new()

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
    bv = b.calculate_knight_attack(Colour::WHITE, D4)

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

  def test_lower_left_corner_bishop_should_attack_diagonally()
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      b-------
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      -------*
      ------*-
      -----*--
      ----*---
      ---*----
      --*-----
      -*------
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_lower_rightt_corner_bishop_should_attack_diagonally()
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      -------b
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      *-------
      -*------
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
    b = GameState.new()

    place_pieces(b, "
      b-------
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      --------
      -*------
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
    b = GameState.new()

    place_pieces(b, "
      -------b
      --------
      --------
      --------
      --------
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      --------
      ------*-
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
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      ---b----
      --------
      --------
      --------
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      -------*
      *-----*-
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
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      -Q---Q--
      --------
      ---b----
      --------
      -Q---Q--
      --------
    ")
    b.calculate_bishop_attack(Colour::WHITE)

    expected = "
      --------
      --------
      -*---*--
      --*-*---
      --------
      --*-*---
      -*---*--
      --------
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_corner_queen_should_attack()
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      --------
      --------
      --------
      q-------
    ")
    b.calculate_queen_attack(Colour::WHITE)

    expected = "
      *------*
      *-----*-
      *----*--
      *---*---
      *--*----
      *-*-----
      **------
      -*******
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_centre_queen_should_attack_outwards()
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      --------
      --------
      ---q----
      --------
      --------
      --------
    ")
    b.calculate_queen_attack(Colour::WHITE)

    expected = "
      ---*---*
      *--*--*-
      -*-*-*--
      --***---
      ***-****
      --***---
      -*-*-*--
      *--*--*-
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_centre_queen_attack_should_be_blockable()
    b = GameState.new()

    place_pieces(b, "
      --------
      --------
      ---P-P--
      --------
      ---q----
      --------
      --------
      --------
    ")
    b.calculate_queen_attack(Colour::WHITE)

    expected = "
      --------
      *-------
      -*-*-*--
      --***---
      ***-****
      --***---
      -*-*-*--
      *--*--*-
    "
    assert_attack_state(expected, b, Colour::WHITE)
  end

  def test_centre_king_should_attack_outwards()
    b = GameState.new()

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
    b = GameState.new()

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
    b = GameState.new()

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
    b = GameState.new()

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
    b = GameState.new()

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
    e = GameState.new

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
    e.moves = [Move.new(D7, D5)]
    assert(e.chk_mv(E5, D6)) 
  end

  def test_white_pawn_should_have_en_passant_available_NE
    e = GameState.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - - 
      - - - - p P - -
      - - - - - - - -
      - - - - - - - - 
      - - - - - - - -
      - - - - - - - -
    ")
    e.moves = [Move.new(F7, F5)]
    assert(e.chk_mv(E5, F6)) 
  end

  def test_white_pawn_should_not_have_en_passant_available_if_not_pawn
    e = GameState.new
    
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
    e.moves = [Move.new(D7, D5)]
    assert(!e.chk_mv(E5, D5))
  end

  def test_white_pawn_should_not_have_en_passant_available_if_one_square_moved
    e = GameState.new

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
    e.moves = [Move.new(D6, D5)]
    assert(!e.chk_mv(E5, D6)) 
  end

  def test_black_pawn_should_have_en_passant_available_SW
    e = GameState.new
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
    e.moves = [Move.new(E2, E4)]
    assert(e.chk_mv(F4, E3)) 
  end

  def test_black_pawn_should_have_en_passant_available_SE
    e = GameState.new
    place_pieces(e, "
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - - - -
      - - - - - P p - 
      - - - - - - - - 
      - - - - - - - -   
      - - - - - - - - 
    ")
    e.moves = [Move.new(G2, G4)]
    assert(e.chk_mv(F4, G3)) 
  end

  def test_black_pawn_should_not_have_en_passant_available_if_not_pawn
    e = GameState.new
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
    e.moves = [Move.new(E2, E4)]
    assert(!e.chk_mv(F4, E3)) 
  end

  def test_black_pawn_should_not_have_en_passant_available_if_one_square_moved 
    e = GameState.new
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
    e.moves = [Move.new(E3, E4)]
    assert(!e.chk_mv(F4, E3)) 
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
end
