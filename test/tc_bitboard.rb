#
#   $Id: test_tmpl.rb 160 2006-08-07 04:39:47Z nwsmith $
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
require "bitboard"

class BitboardTest < Test::Unit::TestCase
    def test_to_i
        bitboard = Bitboard.new(0x1)
        assert_equal(0x1, bitboard.to_i)
    end
    
    def test_right_shift
        bitboard = Bitboard.new(0x1) >> 8
        assert_equal(0x1 >> 8, bitboard.to_i)
    end        
    
    def test_right_shift_equals
        bitboard = Bitboard.new(0x1);
        bitboard >>= 8
        assert_equal(0x1 >> 8, bitboard.to_i)
    end
    
    def test_left_shift
        bitboard = Bitboard.new(0x1) << 8
        assert_equal(0x1 << 8, bitboard.to_i)
    end
    
    def test_left_shift_equals
        bitboard = Bitboard.new(0x1);
        bitboard <<= 8
        assert_equal(0x1 << 8, bitboard.to_i)
    end
end
