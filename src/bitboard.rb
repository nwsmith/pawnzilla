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
    
    attr :blk_pwn_attk # Black Pawn Attacks
    
    attr :wht_pwn_attk # Black Pawn Attacks
    
    def initialize()         
        @blk_pc = 0x00_00_00_00_00_00_FF_FF
        @wht_pc = 0xFF_FF_00_00_00_00_00_00
        
        @p = 0x00_FF_00_00_00_00_FF_00
        @r = 0x81_00_00_00_00_00_00_81
        @n = 0x42_00_00_00_00_00_00_42
        @b = 0x24_00_00_00_00_00_00_24
        @q = 0x10_00_00_00_00_00_00_10
        @k = 0x08_00_00_00_00_00_00_08
        
        @blk_pwn_attk = 0x00_00_00_00_00_FF_00_00

        @wht_pwn_attk = 0x00_00_FF_00_00_00_00_00
    end
    
    def clear()
        @blk_pc = 0
        @wht_pc = 0
        
        @p = 0
        @r = 0
        @n = 0
        @b = 0
        @q = 0
        @k = 0
    end
    
    # get the shift width required to get the square specified by the provided coord
    #
    # This formula is derived from (8 * (7 - y)) + (7 - x), it shifts by bytes to 
    # get to the proper rank, then by bits to get to the proper file
    def get_sw(coord) 
        Bitboard.get_sw(coord)
    end
    
    def Bitboard.get_sw(coord)
        63 - (8 * coord.y) - coord.x
    end
    
    def sq_at(coord) 
        pos = get_sw(coord)
        
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
    
    def place_piece(coord, piece) 
        pc_bv = 0x1 << get_sw(coord)
        
        #remove any existing piece at the coord
        remove_piece(coord)
                
        if piece.colour.black?
            @blk_pc |= pc_bv
        else 
            @wht_pc |= pc_bv
        end
                
        case piece.name
            when "Pawn"
                @p |= pc_bv
            when "Rook"
                @r |= pc_bv
            when "Knight"
                @n |= pc_bv
            when "Bishop"
                @b |= pc_bv
            when "Queen"
                @q |= pc_bv
            when "King"
                @k |= pc_bv
            else
                throw "Unknown piece: " + piece.name
        end
    end
    
    def remove_piece(coord)
        pc_bv = 0x1 << get_sw(coord)
        
        # Make sure there's a piece to remove
        piece = sq_at(coord).piece
        
        return unless !piece.nil?
        
        if piece.colour.black?
            @blk_pc ^= pc_bv
        else
            @wht_pc ^= pc_bv
        end
        
        case piece.name
            when "Pawn"
                @p ^= pc_bv
            when "Rook"
                @r ^= pc_bv
            when "Knight"
                @n ^= pc_bv
            when "Bishop"
                @b ^= pc_bv
            when "Queen"
                @q ^= pc_bv
            when "King"
                @k ^= pc_bv
            else
                throw "Unknown piece: " + piece.name
        end            
    end
    
    #
    # Modify the bitboards so that the piece on the src square is moved to the dest square
    #
    def move_piece(src, dest)
        # bit vector representing the source square
        src_bv = 0x1 << get_sw(src)
        
        # bit vector representing the destination square
        dest_bv = 0x1 << get_sw(dest)
        
        # bit vector representing the change required for the move
        ch_bv = (src_bv | dest_bv)
        
        if (@wht_pc & src_bv) == src_bv
            @wht_pc ^= ch_bv
        end
        
        if (@blk_pc & src_bv) == src_bv
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
    
    #
    # TODO: This is a placeholder implementation based on sq_at, so it's quite inefficient
    # 
    def blocked?(src, dest) 
        l = Line.new(src, dest)
            
        l.each_coord do |c|
            # a piece on the destination square isn't a block
            break if c == dest
                
            return true unless sq_at(c).piece.nil?
        end
        
        false
    end
    
    def attacked?(clr, coord)
        (1 << get_sw(coord)) & gen_combined_attk(clr) != 0
    end    
    
    def gen_pwn_attack(clr)
        bv = clr.white? ? @wht_pwn_attk : @blk_pwn_attk
        bv = 0
        
        bv_piece = clr.white? ? @wht_pc : @blk_pc
        
        0.upto(63) do |i|
            pwn = bv_piece & @p & (1 << i) > 0
            
            if (clr.white? && i < 8)
                next
            elsif (clr.black? && i > 55)
                break
            end
            
            if (pwn)
                if (i % 8 != 7)
                    bv |= 1 << (i + (clr.white? ? -7 : 9))
                end

                if (i % 8 != 0)
                    bv |= 1 << (i + (clr.white? ? -9 : 7))
                end
            end
        end
        
        if (clr.white?)
            @wht_pwn_attk = bv
        else
            @blk_pwn_attk = bv
        end
        
        bv
    end
    
    def gen_combined_attk(clr)
        clr.white? \
            ? @wht_pwn_attk \
            : @blk_pwn_attk
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
    
    def on_file?(src, dest) 
        src, dest = dest, src if dest < src
        
        while dest > 0
            return true if src == dest
            dest >>= 8
        end
        
        false
    end
    
    def on_rank?(src, dest) 
        src, dest = dest, src if dest < src
        
        # shift source to the populated rank and ensure dest is shifted to same rank
        while !(src.between?(0x00, 0xFF))
            src >>= 8
            dest >>= 8 
        end
        
        return (dest - src).between?(0x00, 0xFF)
    end 
    
    def on_diagonal?(src, dest) 
        # Normalize coordinates to be west to east
        src, dest = dest, src if dest < src
        
        dest_orig = dest

        # Check south to north
        while dest > 0
            return true if (src & dest) == dest
            dest >>= 9
        end
        
        # Check north to South
        dest = dest_orig
        
        while dest > 0
            return true if (src & dest) == dest
            dest >>= 7
        end
        
        false
    end
end