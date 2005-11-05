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
#
class Coord
    attr_reader :x
    attr_reader :y
    
    def initialize(x, y) 
        @x = x
        @y = y
    end
    
    # Two coordinates are equal iff both their x and y coordinates are equal        
    def ==(c) 
     (@x == c.x) && (@y == c.y)
    end
    
    # Checks if the the two specified coordinates are on the same diagonal
    def Coord.same_diag?(c0, c1)
        (c1.x - c0.x).abs == (c1.y - c0.y).abs
    end
    
    # Checks if the two specified coordinates are on the same file
    def Coord.same_file?(c0, c1) 
        c0.x == c1.x
    end
    
    # Checks if the two specified coordinates are on the same rank
    def Coord.same_rank?(c0, c1) 
        c0.y == c1.y
    end
end