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
require "geometry/line"

# A Vector is a line with an associated direction
class Vector < Line
  attr_accessor :direction
  
  def initialize(c0, c1)
    raise ArgumentError, "coords not on same line" unless Line.same_line?(c0, c1)
    @c0, @c1 = c0, c1
    @direction = Line.line_direction(c0, c1)
  end
  
  def each_coord
    start = c0
    
    yield c0
    
    return if c0 == c1
    
    loop do 
      start = start.go(@direction)
      yield start
      break if start == c1
    end
  end
end
