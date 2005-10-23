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
module Chess
    class Colour
        WHITE = "white"
        BLACK = "black"
        
        attr_reader :colour
        
        # Initialize using the provided colour.
        # This method should not be used - use new_white and new_black instead.
        def initialize(color)
            @colour = color
        end
        
        # Create a new white colour object
        def Colour.new_white
            new(WHITE)
        end
        
        # Create a new black colour object
        def Colour.new_black
            new(BLACK)
        end
        
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
            @colour != cmp.colour
        end
        
        # Change the colour of this object - black becomes white;white becomes black
        def flip!
            @colour = (@colour == WHITE) ? BLACK : WHITE
        end        
    end
    
    class Piece
        attr_reader :color
        attr_reader :name

        def initialize(color, name)
            @color = color
            @name = name
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
            ((coord.x + coord.y) & 1 == 0) ? Chess::Colour.new_black : Chess::Colour.new_white
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

    class Coord
        attr_reader :x
        attr_reader :y

        def initialize(x, y) 
            @x = x
            @y = y
        end

        # Two coordinates are equal iff both their x and y coordinates are equal        
        def ==(c) 
            (@x == c.x) && (@y == c.y)
        end
    end    
end