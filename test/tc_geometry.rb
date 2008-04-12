#
# $Id$
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

class TestCoord < Test::Unit::TestCase
  def test_should_detect_SW_to_NE_diagonal
    assert(Coord.same_diag?(A1, B2))
    assert(Coord.same_diag?(A1, H8))
  end

  def test_should_detect_NW_to_SE_diagonal
    assert(Coord.same_diag?(A2, B1))
    assert(Coord.same_diag?(A8, H1))
  end

  def test_should_detect_SE_to_NW_diagonal
    assert(Coord.same_diag?(B1, A2))
    assert(Coord.same_diag?(H1, A8))
  end

  def test_should_detect_NE_to_SW_diagonal
    assert(Coord.same_diag?(B2, A1))
    assert(Coord.same_diag?(H8, A1))
  end

  def test_should_detect_N_to_S_rank
    assert(Coord.same_file?(A8, A1))
  end

  def test_should_detect_S_to_N_rank
    assert(Coord.same_file?(A1, A8))
  end
  
  def test_should_detect_W_to_E_file
    assert(Coord.same_rank?(A1, H1))
  end

  def test_should_detect_W_to_E_file
    assert(Coord.same_rank?(H1, A1))
  end

  def test_should_create_coord_from_algebraic_at_origin
    assert_equal(Coord.new(0, 0), Coord.from_alg('a1'))
  end
  
  def test_should_create_coord_from_algebraic_at_ne_corner
    assert_equal(Coord.new(7, 7), Coord.from_alg('h8'))
  end

  def test_should_create_coord_from_algebraic_at_nw_corner
    assert_equal(Coord.new(0, 7), Coord.from_alg('a8'))
  end

  def test_should_return_nil_coord_for_too_long_algebraic_string
    assert_nil(Coord.from_alg('a10'))
  end

  def test_should_return_nil_coord_for_rank_out_of_range
    assert_nil(Coord.from_alg('i8'))
  end

  def test_should_return_nil_unless_rank_is_alphabetic_character
    assert_nil(Coord.from_alg('!8'))
  end

  def test_should_return_nil_for_file_out_of_range
    assert_nil(Coord.from_alg('a9'))
  end

  def test_should_return_nil_unless_rank_is_numeric_character
    assert_nil(Coord.from_alg('aa'))
  end

  def test_should_create_algebraic_coord_at_origin
    assert_equal('a1', Coord.new(0, 0).to_alg)
  end

  def test_should_create_algebraic_coord_at_northeast_corner
    assert_equal('h8', Coord.new(7, 7).to_alg)
  end

  def test_should_create_algebraic_coord_at_northwest_corner
    assert_equal('a8', Coord.new(0, 7).to_alg)
  end

  def test_should_create_algebraic_coord_at_southwest_corner
    assert_equal('h1', Coord.new(7, 0).to_alg)
  end
  
  def test_should_return_north
    coord = A1
    assert_equal(A2, coord.north)
  end
  
  def test_should_change_state_north
    coord = Coord.from_alg("a1")
    coord.north!
    assert_equal(A2, coord)
  end
  
  def test_should_return_south
    assert_equal(A1, A2.south)
  end
  
  def test_should_change_state_south
    coord = Coord.from_alg("a2")
    coord.south!
    assert_equal(A1, coord)
  end
  
  def test_should_return_west
    assert_equal(A1, B1.west)
  end
  
  def test_should_change_state_west
    coord = Coord.from_alg("b1");
    coord.west!
    assert_equal(A1, coord)
  end
  
  def test_should_return_east
    assert_equal(B1, A1.east)
  end
  
  def test_should_change_state_east
    coord = Coord.from_alg("a1")
    coord.east!
    assert_equal(B1, coord)
  end
  
  def test_should_return_northwest
    assert_equal(A2, B1.northwest)
  end
  
  def test_should_change_state_northwest
    coord = Coord.from_alg("b1")
    coord.northwest!
    assert_equal(A2, coord)
  end
  
  def test_should_return_northeast
    assert_equal(B2, A1.northeast)
  end
  
  def test_should_change_state_northeast
    coord = Coord.from_alg("a1")
    coord.northeast!
    assert_equal(B2, coord)
  end
  
  def test_should_return_southwest
    assert_equal(B1, C2.southwest)
  end
  
  def test_should_change_state_southwest
    coord = Coord.from_alg("c2")
    coord.southwest!
    assert_equal(B1, coord)
  end
  
  def test_should_return_southeast
    assert_equal(B1, A2.southeast)
  end
  
  def test_should_change_state_southeast
    coord = Coord.from_alg("a2")
    coord.southeast!
    assert_equal(B1, coord)
  end
end
