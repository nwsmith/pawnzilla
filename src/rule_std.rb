require "game.rb"
require "board.rb"

module Rule_Std
    B_SZ = 8
    
    class Engine      
        attr_accessor :state 
          
        def initialize 
            @state = Game::State.new(B_SZ)
            
            y = 1
                        
            0.upto(B_SZ - 1) do |x|
                state.place_piece(Board::Coord.new(x, y), 
                    ChessPiece::ChessPiece.new("white", 1, "Pawn"))
                state.place_piece(Board::Coord.new(x, y + 5),
                    ChessPiece::ChessPiece.new("black", 1, "Pawn"))
            end
        end
        
        def Engine.coord_to_alg(coord)
            (97 + coord.x).chr + (coord.y + 1).to_s 
        end
    end
    
    e = Rule_Std::Engine.new
    puts e.state.to_txt
end