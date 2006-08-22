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
#
require "gamestate"
require "chess"
require "geometry"
require "tr"

COLUMN_A = 97
DEFAULT_SEPARATOR = " "
module Game
    class State
        attr_accessor :board
    
        def initialize(b_sz) 
            @board = GameState.new()
        end
     
        def place_piece(coord, piece) 
            @board.place_piece(coord, piece)
        end
    
        def remove_piece(coord)
            @board.remove_piece(coord)
        end
    
        def move_piece(from_coord, to_coord)
            @board.move_piece(from_coord, to_coord)
        end
        
        def blocked?(src, dest) 
            @board.blocked?(src, dest)
        end
    end
end

