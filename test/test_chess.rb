#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs
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

class TestColour < Test::Unit::TestCase
    def test_black?
        assert(Chess::Colour.new_black.black?)
        assert(!Chess::Colour.new_white.black?)
    end
    
    def test_white?
        assert(Chess::Colour.new_white.white?)
        assert(!Chess::Colour.new_white.black?)
    end
    
    def test_opposite?
        assert(Chess::Colour.new_white.opposite?(Chess::Colour.new_black))
        assert(!Chess::Colour.new_white.opposite?(Chess::Colour.new_white))
        assert(Chess::Colour.new_black.opposite?(Chess::Colour.new_white))
        assert(!Chess::Colour.new_black.opposite?(Chess::Colour.new_black))        
    end
    
    def test_flip!
        w = Chess::Colour.new_white
        
        w.flip!
        assert(w.black?)
        assert(!w.white?)
        
        w.flip!
        assert(w.white?)
        assert(!w.black?)
    end
end