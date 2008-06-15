#
# $Id$
#
# Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "test/unit"
require "pz_unit"
require "colour"
require "chess/piece"
require "chess/square"
require "piece_translator"

class TestTranslator < Test::Unit::TestCase
  def setup
    @tr = PieceTranslator.new
  end

  def test_white_pawn_should_translate
    assert_equal('p', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN)))
  end
  
  def test_black_pawn_should_translate
    assert_equal('P', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN)))
  end

  def test_white_rook_should_translate
    assert_equal('r', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK)))
  end

  def test_black_rook_should_translate
    assert_equal('R', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK)))
  end

  def test_white_bishop_should_translate
    assert_equal('b', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP)))
  end

  def test_black_bishop_should_translate
    assert_equal('B', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP)))
  end

  def test_white_knight_should_translate
    assert_equal('n', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::KNIGHT)))
  end

  def test_black_knight_should_translate
    assert_equal('N', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::KNIGHT)))
  end

  def test_white_queen_should_translate
    assert_equal('q', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN)))
  end

  def test_black_queen_should_translate
    assert_equal('Q', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::QUEEN)))
  end

  def test_white_king_should_translate
    assert_equal('k', @tr.to_txt(Chess::Piece.new(Colour::WHITE, Chess::Piece::KING)))
  end

  def test_black_king_should_translate
    assert_equal('K', @tr.to_txt(Chess::Piece.new(Colour::BLACK, Chess::Piece::KING)))
  end

  def test_p_should_return_white_pawn
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN), @tr.from_txt('p'))
  end

  def test_P_should_return_black_pawn
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN), @tr.from_txt('P'))
  end

  def test_n_should_return_white_knight
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::KNIGHT), @tr.from_txt('n'))
  end

  def test_N_should_return_black_knight
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::KNIGHT), @tr.from_txt('N'))
  end

  def test_b_should_return_white_bishop
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP), @tr.from_txt('b'))
  end

  def test_B_should_return_black_bishop
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP), @tr.from_txt('B'))
  end

  def test_r_should_return_white_rook
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK), @tr.from_txt('r'))
  end

  def test_R_should_return_black_rook
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK), @tr.from_txt('R'))
  end

  def test_q_should_return_white_queen
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN), @tr.from_txt('q'))
  end

  def test_Q_should_return_black_queen
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::QUEEN), @tr.from_txt('Q'))
  end

  def test_k_should_return_white_king
    assert_equal(Chess::Piece.new(Colour::WHITE, Chess::Piece::KING), @tr.from_txt('k'))
  end

  def test_K_should_return_black_king
    assert_equal(Chess::Piece.new(Colour::BLACK, Chess::Piece::KING), @tr.from_txt('K'))
  end
end
