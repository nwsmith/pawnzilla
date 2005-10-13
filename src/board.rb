module Board
    class Board
        attr_reader :size
        attr_reader :squares

        def initialize(size) 
            @size = size
            @squares = Array.new(size)
            colour = "black";
     
            0.upto(size - 1) do |y|
                @squares[y] = Array.new(size)
                0.upto(size - 1) do |x|
                    @squares[y][x] = Square.new(Coord.new(x, y), colour)    
                    colour = colour == "black" ? "white" : "black"
                end
            end 
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
