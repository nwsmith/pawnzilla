#
#   Copyright 2005-2009 Nathan Smith, Ron Thomas, Sheldon Fuchs
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
      return false if piece.nil?
      @colour == piece.colour && @name == piece.name
    end
    
    def to_s
      "#{@colour} #{@name}"
    end
    
    def king?
      @name == KING;
    end
    
    def queen?
      @name == QUEEN;
    end
    
    def rook?
      @name == ROOK;
    end
    
    def bishop?
      @name == BISHOP;
    end
    
    def knight?
      @name == KNIGHT;
    end

    def pawn?
      @name == PAWN;
    end
  end
end