#
#   $Id: src_tmpl.rb 228 2008-03-04 19:50:17Z nwsmith $
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
#
require "move_engine"
require "rules_engine"
require "game_runner"

class TestGameRunner < GameRunner
  @move_list = []
  
  def move_list(move_list)
    @move_list = move_list
  end
  
  def move
    move = @move_engine[@to_move].get_move(@to_move, @rules_engine)
    if (!move.nil?)
      @rules_engine.move!(move.src, move.dest)
      @to_move = @to_move.flip
    end
    move
  end
  
  def replay
    loop do
      break if move.nil?      
    end
  end
end