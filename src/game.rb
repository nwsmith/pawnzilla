require "board.rb"
require "piece.rb"
require "tr.rb"

COLUMN_A = 97
DEFAULT_SEPARATOR = " "

class GameState
    attr_accessor :board

    def initialize(b_sz) 
        @board = Board::Board.new(b_sz)
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

        @board.squares.reverse.each do |y|
            # Output to rank number
            txt += "#{row}" + sep 
            row -= 1

            # Output the pieces on the rank
            y.each do |x|
                txt += x.piece.nil? ? "-" : tr.to_txt(x.piece)
                txt += sep
            end

            txt += "\n"
        end

        # Offset to compensate for rank numbers in layout
        (sep.length + 1).times do 
            txt += DEFAULT_SEPARATOR 
        end

        # Output the file letters
        COLUMN_A.upto(COLUMN_A + (@board.size - 1)) do |col|
            txt += col.chr + sep
        end 

        txt += "\n"
    end
end

gs = GameState.new(8)
gs.place_piece(Board::Coord.new(0, 1), ChessPiece::ChessPiece.new("black", 3.5, "Bishop"))
puts gs.to_txt()

puts
puts

gs.move_piece(Board::Coord.new(0, 1), Board::Coord::new(1,2))
puts gs.to_txt()
