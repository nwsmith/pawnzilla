#
# $Id: geometry.rb 323 2008-06-13 04:31:34Z nwsmith $
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
#
class Coord
  NORTH = 0x01
  SOUTH = 0x02
  EAST = 0x04
  WEST = 0x08
  NORTHWEST = 0x10
  NORTHEAST = 0x20
  SOUTHWEST = 0x40
  SOUTHEAST = 0x80
  
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
  
  def to_s
    "(#{x}, #{y})"
  end
  
  def go(direction)
    return north if (Coord::NORTH == direction)
    return south if (Coord::SOUTH == direction)
    return east if (Coord::EAST == direction)
    return west if (Coord::WEST == direction)
    return northeast if (Coord::NORTHEAST == direction)
    return northwest if (Coord::NORTHWEST == direction)
    return southeast if (Coord::SOUTHEAST == direction)
    return southwest if (Coord::SOUTHWEST == direction)
  end
  
  # Returns the coordinate directly in north of this one
  def north
    return Coord.new(@x, @y+1)
  end
  
  # Modifies the current coordinate to be the one directly north
  def north!
    @y += 1
  end
  
  # Is the specified coord north of this coord, regardless of east/west
  def north_of?(coord)
    @y > coord.y
  end
  
  # Is the specified coord DUE north of this coord.
  # this means that a coordinate northeast or northwest will return false. 
  def due_north_of?(coord)
    @x == coord.x && @y > coord.y
  end
  
  #Returns the coordinate directly south of this one
  def south
    return Coord.new(@x, @y-1)
  end
  
  # Modifies the curent coordinate to be the one directly south
  def south!
    @y -= 1
  end
  
  def south_of?(coord)
    @y < coord.y
  end
  
  def due_south_of?(coord)
    @x == coord.x && @y < coord.y 
  end
  
  # Returns the coordinate west of this one
  def west
    return Coord.new(@x-1, @y)
  end
  
  # Modifies the current coordinate to be the one directly west
  def west!
    @x -= 1
  end
  
  def west_of?(coord)
    @x < coord.x
  end
  
  def due_west_of?(coord)
    @y == coord.y && @x < coord.x
  end
  
  # Returns the coordinate east of this one
  def east
    return Coord.new(@x+1, @y)
  end
  
  # Modifies the current coordinate to be the one directly east
  def east!
    @x += 1
  end
  
  def east_of?(coord)
    @x > coord.x
  end
  
  def due_east_of?(coord)
    @y == coord.y && @x > coord.x
  end
  
  # Returns the coordinate northwest of this one
  def northwest
    return Coord.new(@x-1, @y+1)
  end
  
  # Modifies the current coordinate to be the one directly nortwest
  def northwest!
    north!
    west!
  end
  
  def northwest_of?(coord)
    @x < coord.x && @y > coord.y
  end
  
  # Returns the coordinate northeast of this one
  def northeast
    return Coord.new(@x+1, @y+1)
  end
  
  # Modifies the current coordinate to be the one directly northeast
  def northeast!
    north!
    east!
  end
  
  def northeast_of?(coord) 
    @x > coord.x && @y > coord.y
  end
  
  # Returns the coordinate southwest from this one
  def southwest
    return Coord.new(@x-1, @y-1)
  end
  
  # Modifies this coordinate to its southwest neighbour
  def southwest!
    south!
    west!
  end
  
  def southwest_of?(coord) 
    @x < coord.x && @y < coord.y 
  end
  
  # Returns the coordinate southeast of this one
  def southeast
    return Coord.new(@x+1, @y-1)
  end
  
  # Modifies this coordinate to its souteast neighbour
  def southeast!
    south!
    east!
  end
  
  def southeast_of?(coord)
    @x > coord.x && @y < coord.y
  end
  
  # Checks if the specified coordinate is on the same diagonal as this object
  def on_diag?(c) 
    Coord.same_diag?(self, c)
  end
  
  # Checks if the specified coordinate is on the same rank as this object
  def on_rank?(c)
    Coord.same_rank?(self, c)
  end
  
  # Checks if the specified coordinate is on the same file as this object
  def on_file?(c) 
    Coord.same_file?(self, c)
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
  
  def Coord.from_alg(alg) 
    return nil unless alg[0].chr.between?('a', 'h')
    return nil unless alg[1].chr.to_i.between?(1, 8)
    alg.length == 2 ? Coord.new(alg[0] - 97, alg[1].chr.to_i - 1) : nil
  end

  def to_alg
    return (97 + @x).chr + (@y + 1).to_s
  end
end

