#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "chess"

class Bitboard
    # Each property it an individual bitboard 
    :blk_pc  # All black pieces
    :wht_pc  # All white pieces
    :p       # All pawns
    :r       # All rooks
    :n       # All knights
    :b       # All bishops
    :q       # All queens
    :k       # All kings
    
    def initialize()         
        @blk_pc = 0x00_00_00_00_00_00_FF_FF
        @wht_pc = 0xFF_FF_00_00_00_00_00_00
        
        @p = 0x00_FF_00_00_00_00_FF_00
        @r = 0x81_00_00_00_00_00_00_81
        @n = 0x42_00_00_00_00_00_00_42
        @b = 0x24_00_00_00_00_00_00_24
        @q = 0x10_00_00_00_00_00_00_10
        @k = 0x08_00_00_00_00_00_00_08
    end
    
    def sq_at(coord) 
        # First determine which bit in the vector this coord represents
        # derived from (8 * (7 - y)) + (7 - x)
        pos = 63 - (8 * coord.y) - coord.x
        
        # Look for a piece of either colour in that square
        piece = nil;
        color = @blk_pc[pos] == 1 ? Chess::Colour.new_black : @wht_pc[pos] ? Chess::Colour.new_white : nil;

        # Determine piece type
        if !color.nil?
            piece = Chess::Piece.new(color, "Pawn") if @p[pos] == 1
            piece = Chess::Piece.new(color, "Rook") if @r[pos] == 1
            piece = Chess::Piece.new(color, "Knight") if @n[pos] == 1
            piece = Chess::Piece.new(color, "Bishop") if @b[pos] == 1
            piece = Chess::Piece.new(color, "Queen") if @q[pos] == 1
            piece = Chess::Piece.new(color, "King") if @k[pos] == 1
        end

        square = Chess::Square.new(coord, Chess::Board.get_colour(coord));
        
        square.piece = piece if ! piece.nil?
        
        square
    end
    
    #
    # Modify the bitboards so that the piece on the src square is moved to the dest square
    #
    def move_piece(src, dest)
        # bit vector representing the source square
        src_bv = 0x1 << (63 - (8 * src.y) - src.x)
        
        # bit vector representing the destination square
        dest_bv = 0x1 << (63 - (8 * dest.y) - dest.x)
        
        # bit vector representing the change required for the move
        ch_bv = (src_bv | dest_bv)
        
        if (@wht_pc & src_bv) == src_bv
            @wht_pc ^= ch_bv
        end
        
        if (@wht_pc & src_bv) == src_bv
            @blk_pc ^= ch_bv
        end

        if (@p & src_bv) == src_bv
            @p ^= ch_bv  
            return
        end
        
        if (@r & src_bv) == src_bv
            @r ^= ch_bv
            return
        end
        
        if (@n & src_bv) == src_bv
            @n ^= ch_bv
            return
        end
        
        if (@b & src_bv) == src_bv
            @b ^= ch_bv
            return
        end
        
        if (@q & src_bv) == src_bv
            @q ^= ch_bv
            return
        end
        
        if (@k & src_bv) == src_bv
            @k ^= ch_bv
            return
        end
    end
    
    # return the provided 64 bit vector as a formatted binary string
    def pp_bv(bv) 
        out = ""
        63.downto(0) do |i|
            out += bv[i].to_s     
            out += " " if (i % 8 == 0)                       
        end
        out
    end
end