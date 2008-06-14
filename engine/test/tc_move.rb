# $Id: test_tmpl.rb 160 2006-08-07 04:39:47Z nwsmith $
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
require "move"
require "rules_engine"

class MoveTest < Test::Unit::TestCase
  def setup
    @state = RulesEngine.new
    @state.clear
    @w_p = Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)
  end

  def test_should_move_piece
    @state.place_piece(A1, @w_p)
    move = Move.execute(A1, A2, @state)
    assert_not_nil(move)
    assert_nil(@state.sq_at(A1).piece)
    assert_not_nil(@state.sq_at(A2).piece)
    assert_equal(@w_p, @state.sq_at(A2).piece)
  end

  def test_should_undo_move
    @state.place_piece(A1, @w_p)
    move = Move.execute(A1, A2, @state)
    move.undo(@state)
    assert_nil(@state.sq_at(A2).piece)
    assert_not_nil(@state.sq_at(A1).piece)
    assert_equal(@w_p, @state.sq_at(A1).piece)
  end

  def test_should_give_to_s
    @state.place_piece(A1, @w_p)
    move = Move.execute(A1, A2, @state)
    assert_equal('a1:a2', move.to_s)
  end
end
