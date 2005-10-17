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
require "game"
require "board"

module Rule_Std
    B_SZ = 8
    
    class Engine      
        attr_accessor :state 
        :pc_val
          
        def initialize 
            @pc_val = {
                "Bishop" => 3.5,
                "King" => 1_000_000,
                "Knight" => 3.5,
                "Pawn" => 1,
                "Queen" => 9,
                "Rook" => 5
            }
        
            @state = Game::State.new(B_SZ)
            
            clr = "white"

            # Pawn Rows
            [1, 6].each do |y|
                0.upto(B_SZ - 1) do |x|
                    state.place_piece(Board::Coord.new(x, y),
                        ChessPiece::ChessPiece.new(clr, @pc_val["Pawn"], "Pawn"))
                end
                
                clr = (clr == "white") ? "black" : "white"
            end
            
            # Back Rows                        
            bck_row = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]
            
            [0, 7].each do |y|
                bck_row.each_index do |x|
                    state.place_piece(Board::Coord.new(x, y),
                        ChessPiece::ChessPiece.new(clr, @pc_val[bck_row[x]], bck_row[x]))
                end
                
                clr = (clr == "white") ? "black" : "white"
            end
        end
        
        def Engine.coord_to_alg(coord)
            (97 + coord.x).chr + (coord.y + 1).to_s 
        end
    end
    
    e = Rule_Std::Engine.new
    puts e.state.to_txt
end