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
#
require 'test/unit'

$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "geometry/coord"
require "colour"
require "piece_translator"

# Redtag: I did try extending this, but test case does some mojo
# on autorunning classes. Best not to mess it up and put a kludge in
# here.
#
#
# Defines methods to easily manipulate the board for testing.
# We use a custom format for our boards. They are represented by 
# strings with 64 non-whitespace characters. All whitespace characters
# are automatically removed of whitespace, so format them as you wish.
#
# There are 2 context for boards.
#
# The first one is used in place_peices. All non-whitespace characters
# must be a - for empty, or the fen character.
#
# The second one is used in assert_attack_state
# All non-whitespace characters must be - for a square not under attack,
# and a * for one that is.

# Useful constants
A1 = Coord.from_alg("a1")
A2 = Coord.from_alg("a2")
A3 = Coord.from_alg("a3")
A4 = Coord.from_alg("a4")
A5 = Coord.from_alg("a5")
A6 = Coord.from_alg("a6")
A7 = Coord.from_alg("a7")
A8 = Coord.from_alg("a8")
B1 = Coord.from_alg("b1")
B2 = Coord.from_alg("b2")
B3 = Coord.from_alg("b3")
B4 = Coord.from_alg("b4")
B5 = Coord.from_alg("b5")
B6 = Coord.from_alg("b6")
B7 = Coord.from_alg("b7")
B8 = Coord.from_alg("b8")
C1 = Coord.from_alg("c1")
C2 = Coord.from_alg("c2")
C3 = Coord.from_alg("c3")
C4 = Coord.from_alg("c4")
C5 = Coord.from_alg("c5")
C6 = Coord.from_alg("c6")
C7 = Coord.from_alg("c7")
C8 = Coord.from_alg("c8")
D1 = Coord.from_alg("d1")
D2 = Coord.from_alg("d2")
D3 = Coord.from_alg("d3")
D4 = Coord.from_alg("d4")
D5 = Coord.from_alg("d5")
D6 = Coord.from_alg("d6")
D7 = Coord.from_alg("d7")
D8 = Coord.from_alg("d8")
E1 = Coord.from_alg("e1")
E2 = Coord.from_alg("e2")
E3 = Coord.from_alg("e3")
E4 = Coord.from_alg("e4")
E5 = Coord.from_alg("e5")
E6 = Coord.from_alg("e6")
E7 = Coord.from_alg("e7")
E8 = Coord.from_alg("e8")
F1 = Coord.from_alg("f1")
F2 = Coord.from_alg("f2")
F3 = Coord.from_alg("f3")
F4 = Coord.from_alg("f4")
F5 = Coord.from_alg("f5")
F6 = Coord.from_alg("f6")
F7 = Coord.from_alg("f7")
F8 = Coord.from_alg("f8")
G1 = Coord.from_alg("g1")
G2 = Coord.from_alg("g2")
G3 = Coord.from_alg("g3")
G4 = Coord.from_alg("g4")
G5 = Coord.from_alg("g5")
G6 = Coord.from_alg("g6")
G7 = Coord.from_alg("g7")
G8 = Coord.from_alg("g8")
H1 = Coord.from_alg("h1")
H2 = Coord.from_alg("h2")
H3 = Coord.from_alg("h3")
H4 = Coord.from_alg("h4")
H5 = Coord.from_alg("h5")
H6 = Coord.from_alg("h6")
H7 = Coord.from_alg("h7")
H8 = Coord.from_alg("h8")

class Test::Unit::TestCase
  def assert_state(expected, gamestate, message = nil) 
    tr = PieceTranslator.new
    processed_expected = expected.gsub(/\s+/, "")
    
    gamestate_state = ""
    0.upto(63) do |i| 
      square = gamestate.sq_at(Coord.from_alg(get_alg_coord_notation(i)))
      gamestate_state += square.piece.nil? ? "-" : tr.to_txt(square.piece)
    end
    
    full_message = create_pretty_message(message, processed_expected, gamestate_state, gamestate)
    assert_block(full_message) {processed_expected == gamestate_state}
  end
  
  def assert_attack_state(expected, gamestate, coord, message = nil)
    processed_expected = expected.gsub(/\s+/, "")
 
    attk_bv = gamestate.calc_attk(coord)
    actual = ""
    
    0.upto(63) do |i|
      i_bv = RulesEngine.get_bv(Coord.from_alg(get_alg_coord_notation(i)))
      actual += i_bv & attk_bv == i_bv ? "*" : "-"
    end
    
    full_message = create_pretty_message(message, processed_expected, actual, gamestate)
    assert_block(full_message) { processed_expected == actual }
  end
  
  def assert_move_state(gamestate, expected, coord, message = nil) 
    processed_expected = expected.gsub(/\s+/, "")
    
    mv_bv = gamestate.calculate_all_moves(coord)
    actual = ""

    0.upto(63) do |i|
      i_bv = RulesEngine.get_bv(Coord.from_alg(get_alg_coord_notation(i)));
      actual += i_bv & mv_bv == i_bv ? "@" : "-"
    end
    
    full_message = create_pretty_message(message, processed_expected, actual)
    assert_block(full_message) {processed_expected == actual}
  end

  def assert_blocked_state(expected, gamestate, coord, message = nil)
    processed_expected = expected.gsub(/\s+/, "")
 
 
    # Generate the gamestates attack board into our format
    gamestate_block_board = ""
    0.upto(63) do |i|
      chk_coord = Coord.from_alg(get_alg_coord_notation(i))

      same_line = Coord.same_diag?(coord, chk_coord) || Coord.same_rank?(coord, chk_coord) ||
          Coord.same_file?(coord, chk_coord)

      gamestate_block_board += (same_line && gamestate.blocked?(coord, chk_coord)) ? "*" : "-"
    end

    # Create a nicely formatted message
    full_message = create_pretty_message(message, expected, gamestate_block_board, gamestate)

    assert_block(full_message) { processed_expected == gamestate_block_board }
  end

  def assert_bv_equals(expected, bv, message = nil)
    processed_expected = expected.gsub(/\s+/, "")
    processed_bv = create_formatted_board(bv);
 
    # Create a nicely formatted message
    full_message = create_pretty_message(message, processed_expected, processed_bv)
    assert_block(full_message) { processed_expected == processed_bv }
  end

  def place_pieces(gamestate, board_string)
    pt = PieceTranslator.new()
    board_string = process_board_string(board_string)
    puts "error: given board malformed!" if board_string.length != 64
    gamestate.clear()
 
    0.upto(63) do |i|
      next if board_string[i].chr == '-'
 
      coord_notation = get_alg_coord_notation(i)
      coord = Coord.from_alg(coord_notation)
      gamestate.place_piece(coord, pt.from_txt(board_string[i].chr))
    end
  end
 
 
  # creates a alg coord notation for an index in a bv
  def get_alg_coord_notation(i)
    x = i % 8
    y = 8 - ((i - x) / 8)
 
    (97 + x).chr + y.to_s
  end
 
  def process_board_string(board_string)
    board_string.gsub(/\s+/, "")
  end

  private
  # Takes a processed board and renders it in a more readable form
  def format_board(board_string)
    board_string[0..7]   + "\n" +
    board_string[8..15]  + "\n" +
    board_string[16..23] + "\n" +
    board_string[24..31] + "\n" +
    board_string[32..39] + "\n" +
    board_string[40..47] + "\n" +
    board_string[48..55] + "\n" +
    board_string[56..63] + "\n" +
    ""
  end
  
  def create_formatted_board(bv)
    bv_str = "";
    0.upto(63) do |i|
      coord = Coord.from_alg(get_alg_coord_notation(i))
      bv_str += ((0x1 << RulesEngine.get_sw(coord)) & bv != 0) ? "*" : "-"
    end

    bv_str
  end

  def format_board_message(message)
    # Create a nicely formatted message
    full_message = message == nil ? "" : message
    full_message += "Given board malformed!\n" if processed_expected.length != 64
    full_message += "Given board has illegal characters\n" if processed_expected.match(/[^-*@pPnNbBrRqQkK]/)
    full_message += "Board:\n#{gamestate.to_txt}\n"
    full_message += "Expected:\n#{format_board(processed_expected)}\n"
    full_message
  end

  def create_pretty_message(message, expected, actual, gamestate=nil)
    # Create a nicely formatted message
    full_message = message == nil ? "" : message
    full_message += "Given board malformed!\n" if expected.length != 64
    full_message += "Given board has illegal characters\n" if expected.match(/[^-*@pPnNbBrRqQkK]/)
    full_message += "Board:\n#{gamestate.to_txt}\n" if gamestate != nil
    full_message += "Expected:\n#{format_board(expected)}\n"
    full_message += "Actual:\n#{format_board(actual)}\n"
  end
end
