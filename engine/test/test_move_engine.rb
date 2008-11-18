#
#   $Id: src_tmpl.rb 228 2008-03-04 19:50:17Z nwsmith $
#
#   Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require "move_engine"

class TestMoveEngine < MoveEngine
  def initialize
    @move_cache = []
  end
  
  def add_move(move) 
    @move_cache.push(move)
  end
  
  def get_move(clr, rules_engine)
    @move_cache.shift
  end 
  
end