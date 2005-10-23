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
require "chess"

module Rule_Std
    B_SZ = 8
    MIN_FILE = 'a'
    MAX_FILE = 'h'
    MIN_RANK = 1
    MAX_RANK = 8
    
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
            
            clr = Chess::Colour.new_white

            # Pawn Rows
            [1, 6].each do |y|
                (0...B_SZ).each do |x|
                    state.place_piece(Chess::Coord.new(x, y),
                        Chess::Piece.new(clr, "Pawn"))
                end
                
                clr = clr.flip
            end
            
            # Back Rows                        
            bck_row = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]
            
            [0, 7].each do |y|
                bck_row.each_index do |x|
                    state.place_piece(Chess::Coord.new(x, y),
                        Chess::Piece.new(clr, bck_row[x]))
                end
                
                clr = clr.flip
            end
        end
        
        def move(src, dest)
            if chk_mv(src.to_coord, dest.to_coord)  
                @state.move_piece(src.to_coord, dest.to_coord)
            end
        end
                
        def Engine.coord_to_alg(coord)
            Rule_Std::AlgCoord.new((97 + coord.x).chr, (coord.y + 1))
        end
        
        def chk_mv(src, dest) 
            pc = @state.board.sq_at(src).piece
            v = true
            
            if pc.nil?
                return false
            end
            
            case pc.name 
                when "Pawn"
                    v = chk_mv_pawn(src, dest, @state)
                
            end
            
            v
        end
        
        def chk_mv_pawn(src, dest, state)
            pc_src = state.board.sq_at(src).piece
            pc_dest = state.board.sq_at(dest).piece        
        
           # no matter what, the pawn has to move forward
            if (dest.y <= src.y) 
                return false
            end

            # no matter what, the pawn can only stay on the same rank or ONE either way            
            unless ((src.x - 1)..(src.x + 1)) === dest.x
                return false
            end
            
            # TODO: the first move problem
            # pawns can move one square forward
            if (dest.y > (src.y + 1)) 
                return false
            end        
            
            # if diagonal, it must be a capture
            if dest.y == (src.y + 1) && [dest.y + 1, dest.y - 1].include?(src.y)
                if !pc_dest.nil?
                    # Can only capture opposite colored piece
                    v = pc_dest.color.opposite?(pc_src.color)
                else 
                    v = false
                end
            end
            
            # if straight, cannot be blocked
            if dest.y == (src.y + 1) && dest.x == src.x
                v = state.board.sq_at(dest).piece.nil?
            end
            
            v
        end        
    end
    
    class AlgCoord
        attr_accessor :file
        attr_accessor :rank
        
        def initialize(file, rank)
            unless (MIN_FILE..MAX_FILE) === file
                raise ArgumentException, "Illegal Alpha"
            end
            @file = file
 
            unless (MIN_RANK..MAX_RANK) === rank           
                raise ArgumentException, "Illegal Numeric"
            end            
            @rank = rank
        end
        
        def ==(c)
            (@file == c.file && @rank == c.rank)
        end
        
        def to_coord
            Chess::Coord.new(@file[0] - 97, @rank - 1)            
        end
    end
    
    e = Rule_Std::Engine.new
    e.move(Rule_Std::AlgCoord.new("e", 2), Rule_Std::AlgCoord.new("e", 3))
    e.move(Rule_Std::AlgCoord.new("e", 3), Rule_Std::AlgCoord.new("e", 4))    
    e.move(Rule_Std::AlgCoord.new("e", 7), Rule_Std::AlgCoord.new("e", 6))
    e.move(Rule_Std::AlgCoord.new("e", 6), Rule_Std::AlgCoord.new("e", 5))    
    e.move(Rule_Std::AlgCoord.new("g", 1), Rule_Std::AlgCoord.new("f", 3))
    e.move(Rule_Std::AlgCoord.new("b", 8), Rule_Std::AlgCoord.new("c", 6))
    e.move(Rule_Std::AlgCoord.new("f", 1), Rule_Std::AlgCoord.new("b", 5))
    puts e.state.to_txt
end