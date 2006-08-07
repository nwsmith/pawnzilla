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
require "geometry"

class TestCoord < Test::Unit::TestCase
    def test_same_diag?
        # SW to NE
        assert(Coord.same_diag?(Coord.new(0, 0), Coord.new(1, 1)))
        assert(Coord.same_diag?(Coord.new(0, 0), Coord.new(7, 7)))
        assert(! Coord.same_diag?(Coord.new(0, 0), Coord.new(1, 0)))
        
        # NW to SE
        assert(Coord.same_diag?(Coord.new(0, 1), Coord.new(1, 0)))
        assert(Coord.same_diag?(Coord.new(0, 7), Coord.new(7, 0)))
        
        # SE to NW
        assert(Coord.same_diag?(Coord.new(1, 0), Coord.new(0, 1)))
        assert(Coord.same_diag?(Coord.new(7, 0), Coord.new(0, 7)))
        
        # NE to SW
        assert(Coord.same_diag?(Coord.new(1, 1), Coord.new(0, 0)))
        assert(Coord.same_diag?(Coord.new(7, 7), Coord.new(1, 1)))
    end
    
    def test_same_file?
        # N to S
        assert(Coord.same_file?(Coord.new(0, 0), Coord.new(0, 4)))
        assert(!Coord.same_file?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!Coord.same_file?(Coord.new(0, 0), Coord.new(4, 0)))
        
        # S to N
        assert(Coord.same_file?(Coord.new(0, 4), Coord.new(0, 0)))
    end
    
    def test_same_rank?
        # W to E
        assert(Coord.same_rank?(Coord.new(0, 0), Coord.new(4, 0)))
        assert(!Coord.same_rank?(Coord.new(0, 0), Coord.new(4, 4)))
        assert(!Coord.same_rank?(Coord.new(0, 0), Coord.new(0, 4)))
        
        # E to W
        assert(Coord.same_rank?(Coord.new(4, 0), Coord.new(0, 0)))        
    end
    
    def test_on_rank?
        # W to E
        assert(Coord.new(0, 0).on_rank?(Coord.new(4, 0)))
        assert(!Coord.new(0, 0).on_rank?(Coord.new(4, 4)))
        assert(!Coord.new(0, 0).on_rank?(Coord.new(0, 4)))
        
        # E to W
        assert(Coord.new(4, 0).on_rank?(Coord.new(0, 0)))            
    end
    
    def test_on_file?
        # W to E
        assert(Coord.new(0, 0).on_file?(Coord.new(0, 4)))
        assert(!Coord.new(0, 0).on_file?(Coord.new(4, 4)))
        assert(!Coord.new(0, 0).on_file?(Coord.new(4, 0)))
        
        # E to W
        assert(Coord.new(0, 4).on_file?(Coord.new(0, 0)))            
    end
    
end