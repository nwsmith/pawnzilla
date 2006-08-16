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
$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "test/unit"
require "chess"
require "tr"

class TestTranslator < Test::Unit::TestCase
    def test_to_txt
        tr = Translator::PieceTranslator.new()
        white = Chess::Colour::WHITE
        black = Chess::Colour::BLACK
        
        piece = Chess::Piece.new(white, Chess::Piece::PAWN)   
        assert(tr.to_txt(piece) == "p")
        
        piece = Chess::Piece.new(black, Chess::Piece::PAWN)
        assert(tr.to_txt(piece) == "P")
        
        piece = Chess::Piece.new(white, Chess::Piece::ROOK)
        assert(tr.to_txt(piece) == "r")
        
        piece = Chess::Piece.new(black, Chess::Piece::ROOK)
        assert(tr.to_txt(piece) == "R")
        
        piece = Chess::Piece.new(white, Chess::Piece::KNIGHT)
        assert(tr.to_txt(piece) == "n")
        
        piece = Chess::Piece.new(black, Chess::Piece::KNIGHT)
        assert(tr.to_txt(piece) == "N")
        
        piece = Chess::Piece.new(white, Chess::Piece::BISHOP)
        assert(tr.to_txt(piece) == "b")
        
        piece = Chess::Piece.new(black, Chess::Piece::BISHOP)
        assert(tr.to_txt(piece) == "B")
        
        piece = Chess::Piece.new(white, Chess::Piece::QUEEN)
        assert(tr.to_txt(piece) == "q")
        
        piece = Chess::Piece.new(black, Chess::Piece::QUEEN)
        assert(tr.to_txt(piece) == "Q")
        
        piece = Chess::Piece.new(white, Chess::Piece::KING)
        assert(tr.to_txt(piece) == "k")
        
        piece = Chess::Piece.new(black, Chess::Piece::KING)
        assert(tr.to_txt(piece) == "K")
    end
end
