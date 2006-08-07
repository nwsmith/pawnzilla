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
module Translator
    class PieceTranslator
        def to_txt(piece) 
            case piece.name
               when Chess::Piece::PAWN     
                   parseFen(piece.colour, "p", "P")
               when Chess::Piece::KNIGHT
                   parseFen(piece.colour, "n", "N")
               when Chess::Piece::BISHOP
                   parseFen(piece.colour, "b", "B")
               when Chess::Piece::ROOK
                   parseFen(piece.colour, "r", "R")
               when Chess::Piece::QUEEN
                   parseFen(piece.colour, "q", "Q")
               when Chess::Piece::KING
                   parseFen(piece.colour, "k", "K")
               else
                   "N/A"
            end
        end

        private

        def parseFen(col, w, b) 
            col.white? ? w : b;    
        end
    end
end


