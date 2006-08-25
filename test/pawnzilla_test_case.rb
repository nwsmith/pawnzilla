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
#
require 'test/unit'

require "tr"

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

class Test::Unit::TestCase

    def assert_attack_state(expected, gamestate, clr, message = nil)
        processed_expected = expected.gsub(/\s+/, "")
 
        # Create a nicely formatted message
        full_message = message == nil ? "" : message
        full_message += "Given board malformed!\n" if processed_expected.length != 64
        full_message += "Given board has illegal characters\n" if processed_expected.match(/[^-*]/)
        full_message += "Board:\n#{gamestate.to_txt}\n"
        full_message += "Expected:\n#{format_board(processed_expected)}\n"
 
        # Generate the gamestates attack board into our format
        gamestate_attack_board = ""
        0.upto(63) do |i|
            coord = Coord.from_alg(get_alg_coord_notation(i))
            gamestate_attack_board += gamestate.attacked?(clr, coord) ? "*" : "-"
        end
        full_message += "Actual:\n#{format_board(gamestate_attack_board)}\n"
 
        assert_block(full_message) { processed_expected == gamestate_attack_board }
    end

    def place_pieces(gamestate, board_string)
        pt = Translator::PieceTranslator.new()
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

    # TAkes a processed board and renders it in a more readable form
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
end
