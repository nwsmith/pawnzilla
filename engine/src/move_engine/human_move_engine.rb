#
#   Copyright 2005-2009 Nathan Smith, Ron Thomas, Sheldon Fuchs
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

class HumanMoveEngine < MoveEngine
  def get_move(clr, gamestate) 
    print "Enter move: " 
    $stdout.flush
    mv = gets
    mv.chomp!
    mv.downcase!
    
    src = Coord.from_alg(mv[0].chr + mv[1].chr)
    dest = Coord.from_alg(mv[2].chr + mv[3].chr)
    
    return Move.new(src, dest)
  end
end
