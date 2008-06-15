#
# $Id: tc_geometry.rb 323 2008-06-13 04:31:34Z nwsmith $
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
$:.unshift File.join(File.dirname(__FILE__), "..", "src")
$:.unshift File.join(File.dirname(__FILE__), "..", "test")

require "test/unit"
require "pz_unit"
require "geometry"

class TestVector < Test::Unit::TestCase
  def test_vector_should_throw_exception_if_coords_not_on_same_line
    assert_raise(ArgumentError) {Vector.new(A1, B3)}
  end
  
  def test_vector_should_initialize_with_correct_direction
    vector = Vector.new(A1, H1)
    assert_equal(Coord::EAST, vector.direction)
  end
  
  def test_each_coord_should_go_east_west_instead_of_normalize
    vector = Vector.new(E1, A1)
    coords = []
    vector.each_coord {|coord| coords.push(coord)}
    assert_equal(5, coords.length)
    assert_equal(E1, coords[0])
    assert_equal(D1, coords[1])
    assert_equal(C1, coords[2])
    assert_equal(B1, coords[3])
    assert_equal(A1, coords[4])
  end
  
  def test_each_coord_should_return_one_coord_and_not_crash_for_one_point
    vector = Vector.new(A1, A1)
    coords = []
    vector.each_coord {|coord| coords.push(coord)}
    assert_equal(1, coords.length)
    assert_equal(A1, coords[0])
  end
end