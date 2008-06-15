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
require "geometry/coord"

class Line
  attr_accessor :c0, :c1
  
  def initialize(c0, c1) 
    raise "Coordinates not on same line" unless Line.same_line?(c0, c1)
      
    @c0, @c1 = c0, c1
  end
  
  def each_coord
    c0, c1 = @c0, @c1
    
    # First, normalize the coords (i.e. make sure they go W-E)
    c0, c1 = c1, c0 if (c0.x > c1.x) 
      
    # Then make sure we know if we're going N->S or S->N
    y_inc = c0.y < c1.y ? 1 : -1
    y = c0.y + y_inc
          
    # Make sure the src is here
    yield c0
    
    # Now check where we're going
    if c0.on_diag?(c1) 
      ((c0.x + 1)..c1.x).each do |x|
        yield Coord.new(x, y)          
        y += y_inc
      end
    elsif c0.on_file?(c1)
      y.step(c1.y, y_inc) do |y|
        yield Coord.new(c0.x, y)
      end
    elsif c0.on_rank?(c1)
      ((c0.x + 1)..c1.x).each do |x|
        yield Coord.new(x, c0.y)
      end
    end
  end
    
  def len
    len = 0
    self.each_coord {|x| len += 1}
    len     
  end
  
  def Line.same_line?(c0, c1) 
    Coord.same_diag?(c0, c1) || Coord.same_rank?(c0, c1) || Coord.same_file?(c0, c1)
  end
  
  def self.line_direction(c0, c1)
    raise ArgumentError, "Points not on same line." unless self.same_line?(c0, c1)
    
    return Coord::NORTH if c1.due_north_of?(c0)
    return Coord::SOUTH if c1.due_south_of?(c0)
    return Coord::WEST if c1.due_west_of?(c0)
    return Coord::EAST if c1.due_east_of?(c0)
    return Coord::NORTHEAST if c1.northeast_of?(c0)
    return Coord::NORTHWEST if c1.northwest_of?(c0)
    return Coord::SOUTHEAST if c1.southeast_of?(c0)
    return Coord::SOUTHWEST if c1.southwest_of?(c0)
  end
end