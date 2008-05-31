#
#   $Id: test_tmpl.rb 228 2008-03-04 19:50:17Z nwsmith $
#
#   Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "pz_unit"
require "move_engine"
require "game_runner"
require "rulesengine"
require "test_move_engine"

class GameRunnerTest < Test::Unit::TestCase
  def test_move_list_in_new_gamerunner_should_be_empty
    gamerunner = GameRunner.new(TestMoveEngine.new, TestMoveEngine.new)
    assert_equal(0, gamerunner.move_list.size)
  end
  
  def test_move_list_should_return_correct_move_after_first_move
    white_move_engine = TestMoveEngine.new
    white_move_engine.add_move(Move.new(E2, E4))
    gamerunner = GameRunner.new(white_move_engine, TestMoveEngine.new)
    gamerunner.move
    assert_equal(1, gamerunner.move_list.size)
    assert_equal(E2, gamerunner.move_list.first.src)
    assert_equal(E4, gamerunner.move_list.first.dest)
  end
end