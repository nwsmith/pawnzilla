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
    RANK_MASKS = [
        0x00_00_00_00_00_00_00_FF,
        0x00_00_00_00_00_00_FF_00,
        0x00_00_00_00_00_FF_00_00,
        0x00_00_00_00_FF_00_00_00,
        0x00_00_00_FF_00_00_00_00,
        0x00_00_FF_00_00_00_00_00,
        0x00_FF_00_00_00_00_00_00,
        0xFF_00_00_00_00_00_00_00
    ]
    
    FILE_MASKS = [
        0x80_80_80_80_80_80_80_80,
        0x40_40_40_40_40_40_40_40,
        0x20_20_20_20_20_20_20_20,
        0x10_10_10_10_10_10_10_10,
        0x08_08_08_08_08_08_08_08,
        0x04_04_04_04_04_04_04_04,
        0x02_02_02_02_02_02_02_02,
        0x01_01_01_01_01_01_01_01        
    ]
            
    # Each property it an individual bitboard 
    :blk_pc  # All black pieces
    :wht_pc  # All white pieces
    :p       # All pawns
    :r       # All rooks
    :n       # All knights
    :b       # All bishops
    :q       # All queens
    :k       # All kings
    
    :blk_p_attk # Black Pawn Attacks
    :blk_r_attk # Black Roow Attacks
    :blk_n_attk # Black Knight Attacks
    :blk_b_attk # Black Bishop Attacks
    :blk_q_attk # Black Queen Attacks
    :blk_k_attk # Black King Attacks
    :blk_attk # All black attacks
    
    :wht_p_attk # White Pawn Attacks
    :wht_r_attk # White Rook Attacks
    :wht_n_attk # White Knight Attacks
    :wht_b_attk # White Bishop Attacks
    :wht_q_attk # White Queen Attacks
    :wht_k_attk # While King Attacks
    :wht_attk # All white attacks    
    
    def initialize()         
        @blk_pc = 0x00_00_00_00_00_00_FF_FF
        @wht_pc = 0xFF_FF_00_00_00_00_00_00
        
        @p = 0x00_FF_00_00_00_00_FF_00
        @r = 0x81_00_00_00_00_00_00_81
        @n = 0x42_00_00_00_00_00_00_42
        @b = 0x24_00_00_00_00_00_00_24
        @q = 0x10_00_00_00_00_00_00_10
        @k = 0x08_00_00_00_00_00_00_08
        
        @blk_p_attk = 0x00_00_00_00_00_FF_00_00
        @blk_r_attk = 0x00_00_00_00_00_00_00_00
        @blk_n_attk = 0x00_00_00_00_00_A5_18_00
        @blk_b_attk = 0x00_00_00_00_00_00_00_00
        @blk_q_attk = 0x00_00_00_00_00_00_00_00
        @blk_k_attk = 0x00_00_00_00_00_00_1C_14

        @wht_p_attk = 0x00_00_FF_00_00_00_00_00
        @wht_r_attk = 0x00_00_00_00_00_00_00_00
        @wht_n_attk = 0x00_18_A5_00_00_00_00_00
        @wht_b_attk = 0x00_00_00_00_00_00_00_00
        @wht_q_attk = 0x00_00_00_00_00_00_00_00
        @wht_k_attk = 0x14_1C_00_00_00_00_00_00
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

        @blk_p_attk = 0
        @blk_r_attk = 0
        @blk_n_attk = 0
        @blk_b_attk = 0
        @blk_q_attk = 0
        @blk_k_attk = 0

        @wht_p_attk = 0
        @wht_r_attk = 0
        @wht_n_attk = 0
        @wht_b_attk = 0
        @wht_q_attk = 0
        @wht_k_attk = 0
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
    
    def Bitboard.get_bv(coord)
        0x1 << get_sw(coord)
    end
    
    def sq_at(coord) 
        pos = get_sw(coord)
        
        # Look for a piece of either colour in that square
        piece = nil
        color = @blk_pc[pos] == 1 ? Chess::Colour.new_black : @wht_pc[pos] ? Chess::Colour.new_white : nil

        # Determine piece type
        if !color.nil?
            piece = Chess::Piece.new(color, Chess::Piece::PAWN) if @p[pos] == 1
            piece = Chess::Piece.new(color, Chess::Piece::ROOK) if @r[pos] == 1
            piece = Chess::Piece.new(color, Chess::Piece::KNIGHT) if @n[pos] == 1
            piece = Chess::Piece.new(color, Chess::Piece::BISHOP) if @b[pos] == 1
            piece = Chess::Piece.new(color, Chess::Piece::QUEEN) if @q[pos] == 1
            piece = Chess::Piece.new(color, Chess::Piece::KING) if @k[pos] == 1
        end

        square = Chess::Square.new(coord, Chess::Board.get_colour(coord))
        
        square.piece = piece if ! piece.nil?
        
        square
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
            when Chess::Piece::PAWN
                @p |= pc_bv
            when Chess::Piece::ROOK
                @r |= pc_bv
            when Chess::Piece::KNIGHT
                @n |= pc_bv
            when Chess::Piece::BISHOP
                @b |= pc_bv
            when Chess::Piece::QUEEN
                @q |= pc_bv
            when Chess::Piece::KING
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
            when Chess::Piece::PAWN
                @p ^= pc_bv
            when Chess::Piece::ROOK
                @r ^= pc_bv
            when Chess::Piece::KNIGHT
                @n ^= pc_bv
            when Chess::Piece::BISHOP
                @b ^= pc_bv
            when Chess::Piece::QUEEN
                @q ^= pc_bv
            when Chess::Piece::KING
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
        (1 << get_sw(coord)) & calculate_colour_attack(clr) != 0
    end    
    
    def calculate_pawn_attack(clr)
        mask_left  = 0x7F_7F_7F_7F_7F_7F_7F_7F
        mask_right = 0xFE_FE_FE_FE_FE_FE_FE_FE

        bv_piece = clr.white? ? @wht_pc : @blk_pc
        bv_p = bv_piece & @p

        # right attack
        bv = mask_right & (clr.white? ? bv_p >> 7 : bv_p << 9)

        # left attack
        bv |= mask_left & (clr.white? ? bv_p >> 9 : bv_p << 7)
        
        if (clr.white?)
            @wht_p_attk = bv
        else
            @blk_p_attk = bv
        end
    end
    
    def calculate_rook_attack(clr)
        bv = 0
        bv_piece = clr.white? ? @wht_pc : @blk_pc
        
        if (bv_piece & @r == 0)
            return
        end
        
        0.upto(7) do |i|
            bv = bv | calculate_file_attack(clr, Chess::Piece.new(clr, Chess::Piece::ROOK), i)
        end
        
        0.upto(7) do |i|
            bv = bv | calculate_rank_attack(clr, Chess::Piece.new(clr, Chess::Piece::ROOK), i)
        end
        
        
        if (clr.white?)
            @wht_r_attk = bv
        else
            @blk_r_attk = bv
        end
        
    end
    
    def calculate_knight_attack(clr)
        bv = 0
        bv_piece = clr.white? ? @wht_pc : @blk_pc
        
        # knight attack position legend for below (k == knight)
        #  B C
        # A   D
        #   K
        # E   H
        #  F G
        
        0.upto(63) do |i|
            kni_exist = bv_piece & @n & (1 << i) != 0

            if (!kni_exist)
                next
            end
            
            place_a = true
            place_b = true
            place_c = true
            place_d = true
            place_e = true
            place_f = true
            place_g = true
            place_h = true
            
            # disable marking of squares based off of rows
            if (i > 47)
                place_b = false
                place_c = false
                
                if (i > 55)
                    place_a = false
                    place_d = false
                end
            end
            
            if (i < 16)
                place_f = false
                place_g = false
                
                if (i < 8)
                    place_e = false
                    place_h = false
                end
            end

            # disable marking of squares based off of cols
            col_index = i % 8
            if (col_index <= 1)
                place_a = false
                place_e = false
                if (col_index == 0)
                    place_b = false
                    place_f = false
                end
            end

            if (col_index >= 6)
                place_d = false
                place_h = false
                if (col_index == 7)
                    place_c = false
                    place_g = false
                end
            end
            
            # A = K_pos + 6
            # B = K_pos + 15
            # C = K_pos + 17
            # D = K_pos + 10
            # E = K_pos - 10
            # F = K_pos - 17
            # G = K_pos - 15
            # H = K_pos - 6
            if (place_a)
                bv |= 1 << (i + 6)
            end                
            
            if (place_b)
                bv |= 1 << (i + 15)
            end                

            if (place_c)
                bv |= 1 << (i + 17)
            end                

            if (place_d)
                bv |= 1 << (i + 10)
            end                

            if (place_e)
                bv |= 1 << (i - 10)
            end                

            if (place_f)
                bv |= 1 << (i - 17)
            end                

            if (place_g)
                bv |= 1 << (i - 15)
            end                
 
            if (place_h)
                bv |= 1 << (i - 6)
            end                
        end
        
        if (clr.white?)
            @wht_n_attk = bv
        else
            @blk_n_attk = bv
        end
    end
    
    def calculate_bishop_attack(clr)
        bv = 0
        bv_piece = (clr.white? ? @wht_pc : @blk_pc) & @b
        
        0.upto(63) do |i|
            if (1 << i & bv_piece != 0)
              bv |= calculate_diagonal_attack(i)
            end
        end
        
        if (clr.white?)
            @wht_k_attk = bv
        else
            @blk_k_attk = bv
        end
        
    end
    
    def calculate_queen_attack(clr)
      bv = 0
      bv_piece = (clr.white? ? @wht_pc : @blk_pc) & @q

      0.upto(63) do |i|
          if (1 << i & bv_piece != 0)
            bv |= calculate_diagonal_attack(i)
          end
      end
      
      0.upto(7) do |i|
          bv = bv | calculate_file_attack(clr, Chess::Piece.new(clr, Chess::Piece::QUEEN), i)
      end
      
      0.upto(7) do |i|
          bv = bv | calculate_rank_attack(clr, Chess::Piece.new(clr, Chess::Piece::QUEEN), i)
      end
      

      if (clr.white?)
          @wht_q_attk = bv
      else
          @blk_q_attk = bv
      end
    end

    def calculate_king_attack(clr)
        bv = 0
        bv_piece = (clr.white? ? @wht_pc : @blk_pc) & @k
        
        index = -1
        0.upto(63) do |i|
            if (1 << i == bv_piece)
                index = i
                break
            end                        
        end
        
        col = index % 8
        
        # row below king
        if (index > 7)
            if (col != 7)
                bv |= bv_piece >> 7
            end
            bv |= bv_piece >> 8
            if (col != 0)
                bv |= bv_piece >> 9
            end
        end

        # same row as king        
        if (col != 7)
            bv |= bv_piece << 1
        end
        if (col != 0)
            bv |= bv_piece >> 1
        end
        
        # row above king
        if (index < 56)
            if (col != 7)
                bv |= bv_piece << 9
            end
            bv |= bv_piece << 8
            if (col != 0)
                bv |= bv_piece << 7
            end
        end
        
        if (clr.white?)
            @wht_k_attk = bv
        else
            @blk_k_attk = bv
        end
    end
    
    def calculate_colour_attack(clr)
        if (clr.white?)
            @wht_p_attk | @wht_r_attk | @wht_n_attk | @wht_b_attk | @wht_q_attk | @wht_k_attk
        else
            @blk_p_attk | @blk_r_attk | @blk_n_attk | @blk_b_attk | @blk_q_attk | @blk_k_attk
        end
    end
    
    # generate a bv for this piece on the given file
    def calculate_file_attack(clr, piece, file)
        piece_bv = piece.name == Chess::Piece::ROOK ? @r : @q 

        bv = 0
        attacking_piece = (clr.white? ? @wht_pc : @blk_pc) & piece_bv & FILE_MASKS[file]
        
        if (attacking_piece == 0)
            # attacking piece is not on this file, abort
            return 0
        end
        
        cell = 0x1 << (7 - file)
        0.upto(7) do |i|
            if (attacking_piece & cell != 0)
                (i-1).downto(0) do |j|
                  chk_cell = cell >> (8 * (i - j))
                  bv |= chk_cell
                  break if (chk_cell & (@blk_pc | @wht_pc)) != 0
                end

                (i+1).upto(7) do |j|
                  chk_cell = cell << (8 * (j - i))
                  bv |= chk_cell
                  break if (chk_cell & (@blk_pc | @wht_pc)) != 0
                end
            end
            cell <<= 8
        end
        bv
    end
    
    
    # generate a bv for this piece on the given rank
    def calculate_rank_attack(clr, piece, rank)
        piece_bv = piece.name == Chess::Piece::ROOK ? @r : @q 

        bv = 0
        attacking_piece = (clr.white? ? @wht_pc : @blk_pc) & piece_bv & RANK_MASKS[rank]
        
        if (attacking_piece == 0)
            # attacking piece is not on this rank, abort
            return 0
        end
        
        cell = 0x1 << (8 * rank)
        0.upto(7) do |i|
            if (attacking_piece & cell != 0)
                (i-1).downto(0) do |j|
                  chk_cell = cell >> (i - j)
                  bv |= chk_cell
                  break if (chk_cell & (@blk_pc | @wht_pc)) != 0
                end

                (i+1).upto(7) do |j|
                  chk_cell = cell << (j - i)
                  bv |= chk_cell
                  break if (chk_cell & (@blk_pc | @wht_pc)) != 0
                end
            end
            cell <<= 1
        end
        bv
    end
    
    # generates a bv for a diagonal attack given a square
    def calculate_diagonal_attack(sq)
        mask_left  = 0x80_80_80_80_80_80_80_80
        mask_right = 0x01_01_01_01_01_01_01_01
        bv = 0

        operations = [
            [mask_right, -9], # btm right
            [mask_left, -7],  # btm left
            [mask_right, 7],  # up right
            [mask_left, 9]    # up left
        ]
        
        operations.each do |params|
            chk_sq = sq + params[1]
            
            while (chk_sq >= 0 && chk_sq < 64)
                bv |= 1 << chk_sq

                # do not continue to the next peice if this square contains a peice or we're off the edge
                break if ((@blk_pc | @wht_pc) & (1 << chk_sq) != 0 || ((1 << chk_sq) & params[0]) != 0)
                chk_sq += params[1]
            end
        end

        bv
    end
    
    def Bitboard::get_file(bv) 
        file = 7;
        while (bv & 0xFF) != bv
            file -= 1
            bv >>= 8
        end
        file
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