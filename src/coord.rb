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
end