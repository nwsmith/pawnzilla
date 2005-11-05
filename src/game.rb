#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs
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
require "chess"
require "coord"
require "tr"

COLUMN_A = 97
DEFAULT_SEPARATOR = " "
module Game
    class State
        attr_accessor :board
    
        def initialize(b_sz) 
            @board = Chess::Board.new(b_sz)
        end
     
        def place_piece(coord, piece) 
        	@board.squares[coord.x][coord.y].piece = piece    
        end
    
        def remove_piece(coord)
    	    @board.squares[coord.x][coord.y].piece = nil 
        end
    
        def move_piece(from_coord, to_coord)
            piece = @board.squares[from_coord.x][from_coord.y].piece
            place_piece(to_coord, piece)
            remove_piece(from_coord)
        end
    
        # Output a text representation of the current board state using the specified separator
        # If no separator is defined, the default separator is used.
        def to_txt(sep = DEFAULT_SEPARATOR)
            tr = Translator::PieceTranslator.new()
            txt, row = '', @board.size;

            # Because we store the board in a standard orientation, in order to make the board
            # look "right side up" in a textual representation, we have to do the y-axis in
            # reverse.            
            (@board.size - 1).downto(0) do |y|
                # Output the rank number (for alg coord)
                txt += "#{row}" + sep
                row -= 1
                
                # Output the pieces on the rank
                (0...@board.size).each do |x|
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
            (COLUMN_A...(COLUMN_A + @board.size)).each do |col|
                txt += col.chr + sep
            end 
    
            txt += "\n"
        end
    end
end

