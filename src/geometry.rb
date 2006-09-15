#
# $Id$
#
# Copyright 2005, 2006 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
end
