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
require "geometry"
require "colour"

module Chess
  class Piece
    BISHOP = "Bishop";
    KING = "King";
    KNIGHT = "Knight";
    PAWN = "Pawn";
    QUEEN = "Queen";
    ROOK = "Rook";
    
    attr_reader :colour
    attr_reader :name

    def initialize(colour, name)
      @colour = colour
      @name = name
    end

    def ==(piece)
      @colour == piece.colour && @name == piece.name
    end

  end    
  
  class Square 
    attr_reader :coord
    attr_reader :colour
    attr_accessor :piece

    def initialize(coord, colour) 
      @coord = coord
      @colour = colour
    end
  end
end
