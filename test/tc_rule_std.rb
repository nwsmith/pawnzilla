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

require "rule_std"
require "test/unit"

class TestRule_Std < Test::Unit::TestCase    
    def test_chk_mv_pawn
        e = Rule_Std::Engine.new
        
        # cannot move a "pawn" from an empty square
        assert_equal(e.chk_mv(Coord.from_alg('e3'), Coord.from_alg('e4')), false)
        
        # can move one square forward
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), true)
                                
        # cannot move one square forward if blocked
        e.state.place_piece(Coord.from_alg('e3'), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e3')), false)
                                
        # cannot move two squares forward if blocked
        assert(!e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('e4')))
                                
        # cannot move diagonally if not a capture
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                                
        # can move diagonally if a capture
        e.state.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), true)
                                
        # cannot capture the same colored piece
        e.state.place_piece(Coord.from_alg('d3'), Chess::Piece.new(Chess::Colour::WHITE, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e2'), Coord.from_alg('d3')), false)
                                
        # make sure it works both ways
        e.state.place_piece(Coord.from_alg('d6'), Chess::Piece.new(Chess::Colour::BLACK, Chess::Piece::BISHOP))
        assert_equal(e.chk_mv(Coord.from_alg('e7'), Coord.from_alg('f6')), false)                       
                                
    end
    
    def test_check_mv_bishop
        e = Rule_Std::Engine.new()
        
        # cannot move a blocked bishop
        assert(!e.chk_mv(Coord.from_alg('c1'), 
                        Coord.from_alg('e3')))
        e.state.remove_piece(Coord.from_alg('d2'))
        assert(e.chk_mv(Coord.from_alg('c1'), 
                        Coord.from_alg('e3')))

    end
    
    def test_rook_cannot_hop_pawn
        # Unit test for a bug condition -> Rook can hop a pawn
        e = Rule_Std::Engine.new()
        b = e.state
        assert(b.blocked?(Coord.new(0, 7), Coord.new(0, 5)))
    end
end
