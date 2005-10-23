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
module Chess
    class Colour
        WHITE = "white"
        BLACK = "black"
        
        attr_reader :colour
        
        # Initialize using the provided colour.
        # This method should not be used - use new_white and new_black instead.
        def initialize(color)
            @colour = color
        end
        
        # Create a new white colour object
        def Colour.new_white
            new(WHITE)
        end
        
        # Create a new black colour object
        def Colour.new_black
            new(BLACK)
        end
        
        # Returns true if this colour is black
        def black?
            BLACK == @colour
        end
        
        # Returns true if this colour is white
        def white?
            WHITE == @colour
        end
        
        # Returns true if the specified colour is the opposite of the internal colour
        def opposite?(cmp) 
            @colour != cmp.colour
        end
        
        # Change the colour of this object - black becomes white;white becomes black
        def flip!
            @colour = (@colour == WHITE) ? BLACK : WHITE
        end        
    end
end