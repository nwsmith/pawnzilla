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
    
        # Output a text representation of the current board state using the specified separator
        # If no separator is defined, the default separator is used.
        def to_txt(sep = DEFAULT_SEPARATOR)
            tr = Translator::PieceTranslator.new()
            txt, row = '', 8;

            # Because we store the board in a standard orientation, in order to make the board
            # look "right side up" in a textual representation, we have to do the y-axis in
            # reverse.            
            (7).downto(0) do |y|
                # Output the rank number (for alg coord)
                txt += "#{row}" + sep
                row -= 1
                
                # Output the pieces on the rank
                (0...8).each do |x|
                    sq = @board.sq_at(Coord.new(x, y))
                    txt += sq.piece.nil? ? "-" : tr.to_txt(sq.piece)
                    txt += sep
                end
                
                txt += "\n"
            end
    
            # Offset to compensate for rank numbers in layout
            (sep.length + 1).times do 
                txt += DEFAULT_SEPARATOR 
            end
    
            # Output the file letters
            (COLUMN_A...(COLUMN_A + 8)).each do |col|
                txt += col.chr + sep
            end 
    
            txt += "\n"
        end
    end
end

