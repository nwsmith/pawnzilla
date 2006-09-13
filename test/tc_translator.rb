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
require "colour"
require "chess"
require "tr"

class TestTranslator < Test::Unit::TestCase
    def test_to_txt
        tr = Translator::PieceTranslator.new()
        white = Colour::WHITE
        black = Colour::BLACK
        
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

    def test_p_should_return_white_pawn
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN), tr.from_txt('p'))
    end

    def test_P_should_return_black_pawn
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN), tr.from_txt('P'))
    end

    def test_n_should_return_white_knight
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::KNIGHT), tr.from_txt('n'))
    end

    def test_N_should_return_black_knight
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::KNIGHT), tr.from_txt('N'))
    end

    def test_b_should_return_white_bishop
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), tr.from_txt('b'))
    end

    def test_B_should_return_black_bishop
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP), tr.from_txt('B'))
    end

    def test_r_should_return_white_rook
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK), tr.from_txt('r'))
    end

    def test_R_should_return_black_rook
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK), tr.from_txt('R'))
    end

    def test_q_should_return_white_queen
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN), tr.from_txt('q'))
    end

    def test_Q_should_return_black_queen
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::QUEEN), tr.from_txt('Q'))
    end

    def test_k_should_return_white_king
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::KING), tr.from_txt('k'))
    end

    def test_K_should_return_black_king
        tr = Translator::PieceTranslator.new()
        assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::KING), tr.from_txt('K'))
    end
end
