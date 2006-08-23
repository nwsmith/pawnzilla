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
require "geometry"

module Chess
    class Colour
        attr_reader :colour

        private
        STR_WHITE = "white"
        STR_BLACK = "black"
        
        # Initialize using the provided colour.
        # This method should not be used - use WHITE and BLACK instead.
        def initialize(color)
            @colour = color
        end

        WHITE = new(STR_WHITE)
        BLACK = new(STR_BLACK)

        public
        # Returns true if this colour is black
        def black?
            BLACK == @colour
        end
        
        # Returns true if this colour is white
        def white?
            WHITE == @colour
        end
        
        # Returns true if the specified colour is the opposite of the internal colour
        def opposite?(cmp) 
            self != cmp
        end
        
        # Return a colour object with the opposite colour of this one
        def flip
            (@colour == STR_WHITE) ? BLACK : WHITE
        end
        
        def ==(cmp)
            cmp.class == String ? @colour == cmp : @colour == cmp.colour
        end

        def hash
            @colour == STR_WHITE ? 0 : 1
        end
    end
    
    class Piece
        BISHOP = "Bishop";
        KING = "King";
        KNIGHT = "Knight";
        PAWN = "Pawn";
        QUEEN = "Queen";
        ROOK = "Rook";
        
        attr_reader :colour
        attr_reader :name

        def initialize(colour, name)
            @colour = colour
            @name = name
        end

        def ==(piece)
            @colour == piece.colour && @name == piece.name
        end

    end    
    
    class Board
        attr_reader :size
        attr_reader :squares

        def initialize(size) 
            @size = size
            @squares = Array.new(size)
     
            (0...size).each do |x|
                @squares[x] = Array.new(size)
                (0...size).each do |y|
                    coord = Coord.new(x, y)
                    @squares[x][y] = Square.new(coord, Board.get_colour(coord))    
                end
            end 
        end
        
        def sq_at(coord) 
            @squares[coord.x][coord.y]
        end
                  
        def Board.get_colour(coord) 
            ((coord.x + coord.y) & 1 == 0) ? Chess::Colour::BLACK : Chess::Colour::WHITE
        end
        
        def blocked?(src, dest) 
            l = Line.new(src, dest)
            
            l.each_coord do |c|
                # a piece on the destination square isn't a block
                break if c == dest
                
                return true unless @squares[c.x][c.y].piece.nil?
            end
            
            false
        end
    end

    class Square 
        attr_reader :coord
        attr_reader :colour
        attr_accessor :piece

        def initialize(coord, colour) 
            @coord = coord
            @colour = colour
        end
    end
            
end
