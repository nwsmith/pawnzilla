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
        
        def move(src, dest) 
            state.move_piece(Rule_Std::Engine.alg_to_coord(src), Rule_Std::Engine.alg_to_coord(dest))
        end
                
        # Convert a standard algebric coordinate into an internal coordinate
        def Engine.alg_to_coord(alg) 
            if (alg.length != 2) 
                raise ArgumentError, "algebraic coords must consist of one letter and one number (e.g. a1)"
            end
        
            try_x, try_y = alg[0], alg[1].chr.to_i

            if (try_x < 97 || try_x > (97 + B_SZ)) 
                raise ArgumentError, 
                    "illegal algebraic alpha [#{try_x}] valid: [#{try_x.chr} - #{(try_x + B_SZ).chr}"
            end
            
            if (try_y < 1 || try_y > (B_SZ + 1))
                raise ArgumentError, 
                    "illegal algebraic num [#{try_y}] valid: [1 - #{B_SZ}]"     
            end
            
            Board::Coord.new((try_x - 97), (try_y - 1))                
        end
        
        def Engine.coord_to_alg(coord)
            (97 + coord.x).chr + (coord.y + 1).to_s 
        end
    end
    
    e = Rule_Std::Engine.new
    e.move("e2", "e4")
    e.move("e7", "e5")
    e.move("g1", "f3")
    e.move("b8", "c6")
    e.move("f1", "b5")
    puts e.state.to_txt
end