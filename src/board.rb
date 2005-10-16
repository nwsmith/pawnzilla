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
module Board
    class Board
        attr_reader :size
        attr_reader :squares

        def initialize(size) 
            @size = size
            @squares = Array.new(size)
     
            0.upto(size - 1) do |x|
                @squares[x] = Array.new(size)
                0.upto(size - 1) do |y|
                    coord = Coord.new(x, y)
                    @squares[x][y] = Square.new(coord, Board.get_colour(coord))    
                end
            end 
        end 

        def sq_at(coord) 
            @squares[coord.x][coord.y]
        end
                  
        def Board.get_colour(coord) 
            ((coord.x + coord.y) & 1 == 0) ? "black" : "white"
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
    end
end
