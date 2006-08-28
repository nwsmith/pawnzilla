#
#   $Id: test_tmpl.rb 160 2006-08-07 04:39:47Z nwsmith $
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
require "move"
require "gamestate"

class MoveTest < Test::Unit::TestCase
    def setup
        @state = GameState.new
        @state.clear
        @w_p = Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::PAWN)
        @a1 = Coord.from_alg('a1')
        @a2 = Coord.from_alg('a2')
    end

    def test_should_move_piece
        @state.place_piece(@a1, @w_p)
        move = Move.execute(@a1, @a2, @state)
        assert_not_nil(move)
        assert_nil(@state.sq_at(@a1).piece)
        assert_not_nil(@state.sq_at(@a2).piece)
        assert_equal(@w_p, @state.sq_at(@a2).piece)
    end

    def test_should_undo_move
        @state.place_piece(@a1, @w_p)
        move = Move.execute(@a1, @a2, @state)
        move.undo(@state)
        assert_nil(@state.sq_at(@a2).piece)
        assert_not_nil(@state.sq_at(@a1).piece)
        assert_equal(@w_p, @state.sq_at(@a1).piece)
    end
end
