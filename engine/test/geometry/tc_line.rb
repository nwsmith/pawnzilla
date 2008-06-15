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

class TestLine < Test::Unit::TestCase
  def test_line_e1_to_c1_should_work_bugfix
    line = Line.new(E1, C1)
    coords = []
    line.each_coord {|coord| coords.push coord}
    assert_equal(C1, coords[0])
    assert_equal(D1, coords[1])
    assert_equal(E1, coords[2])
  end
end