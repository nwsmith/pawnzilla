#
# $Id: chess.rb 324 2008-06-13 04:35:32Z nwsmith $
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
require "colour"

module Chess
  class Square 
    attr_reader :coord
    attr_reader :colour
    attr_accessor :piece

    def initialize(coord, colour) 
      @coord = coord
      @colour = colour
    end
    
    def ==(square)
      @coord == square.coord && @piece == square.piece
    end
    
    def to_s
      "#{@coord.to_alg}" + (@piece.nil? ? "" : "(#{piece})")
    end
  end
end