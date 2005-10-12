module Translator
    class PieceTranslator
        def to_txt(piece) 
            case piece.name
               when "Pawn"     
                   parseFen(piece.color, "p", "P")
               when "Knight"
                   parseFen(piece.color, "n", "N")
               when "Bishop"
                   parseFen(piece.color, "b", "B")
               when "Rook"
                   parseFen(piece.color, "r", "R")
               when "Queen"
                   parseFen(piece.color, "q", "Q")
               when "King"
                   parseFen(piece.color, "k", "K")
               else
                   "N/A"
            end
        end

        private

        def parseFen(col, w, b) 
            col == "white" ? w : b;    
        end
    end
end


