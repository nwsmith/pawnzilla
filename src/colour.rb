#
#   $Id: src_tmpl.rb 160 2006-08-07 04:39:47Z nwsmith $
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
#
class Colour
  attr_reader :colour

  private
  STR_WHITE = "white"
  STR_BLACK = "black"
  
  # Initialize using the provided colour.
  # This method should not be used - use WHITE and BLACK instead.
  def initialize(color)
    @colour = color
  end

  WHITE = new(STR_WHITE)
  BLACK = new(STR_BLACK)

  public
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
    self != cmp
  end
  
  # Return a colour object with the opposite colour of this one
  def flip
    (@colour == STR_WHITE) ? BLACK : WHITE
  end
  
  def ==(cmp)
    cmp.class == String ? @colour == cmp : @colour == cmp.colour
  end

  def hash
    @colour == STR_WHITE ? 0 : 1
  end
end
