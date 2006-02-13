#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
        white = Chess::Colour::new_white
        black = Chess::Colour::new_black
        
        piece = Chess::Piece.new(white, "Pawn")   
        assert(tr.to_txt(piece) == "p")
        
        piece = Chess::Piece.new(black, "Pawn")
        assert(tr.to_txt(piece) == "P")
        
        piece = Chess::Piece.new(white, "Rook")
        assert(tr.to_txt(piece) == "r")
        
        piece = Chess::Piece.new(black, "Rook")
        assert(tr.to_txt(piece) == "R")
        
        piece = Chess::Piece.new(white, "Knight")
        assert(tr.to_txt(piece) == "n")
        
        piece = Chess::Piece.new(black, "Knight")
        assert(tr.to_txt(piece) == "N")
        
        piece = Chess::Piece.new(white, "Bishop")
        assert(tr.to_txt(piece) == "b")
        
        piece = Chess::Piece.new(black, "Bishop")
        assert(tr.to_txt(piece) == "B")
        
        piece = Chess::Piece.new(white, "Queen")
        assert(tr.to_txt(piece) == "q")
        
        piece = Chess::Piece.new(black, "Queen")
        assert(tr.to_txt(piece) == "Q")
        
        piece = Chess::Piece.new(white, "King")
        assert(tr.to_txt(piece) == "k")
        
        piece = Chess::Piece.new(black, "King")
        assert(tr.to_txt(piece) == "K")
    end
end