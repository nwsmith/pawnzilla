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
#
require "chess"
require "colour"
require "move"
require "tr"

class PieceInfo
  attr_reader :piece
  attr_accessor :coord, :bb_attack, :bb_move
  
  def initialize(piece, coord, bb_attack=0, bb_move=0)
    @piece = piece    
    @coord = coord
    @bb_attack = bb_attack
    @bb_move = bb_move
  end

  def colour
    piece.colour
  end

  def ==(pc) 
    @piece == pc.piece &&
    @coord == pc.coord &&
    @bb_attack == pc.bb_attack &&
    @bb_move == pc.bb_move
  end
end

class PieceInfoBag
  attr_accessor :pieces

  def initialize
    @pieces = {
      Colour::WHITE => [
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK),
          Coord.from_alg('a1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::KNIGHT),
          Coord.from_alg('b1'),
          0x00_00_A0_00_00_00_00_00,
          0x00_00_A0_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP),
          Coord.from_alg('c1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::QUEEN),
          Coord.from_alg('d1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::KING),
          Coord.from_alg('e1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::BISHOP),
          Coord.from_alg('f1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::KNIGHT),
          Coord.from_alg('g1'),
          0x00_00_05_00_00_00_00_00,
          0x00_00_05_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::ROOK),
          Coord.from_alg('h1')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('a2'),
          0x00_00_80_00_00_00_00_00,
          0x00_00_40_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('b2'),
          0x00_00_40_00_00_00_00_00,
          0x00_00_A0_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('c2'),
          0x00_00_20_00_00_00_00_00,
          0x00_00_50_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('d2'),
          0x00_00_10_00_00_00_00_00,
          0x00_00_28_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('e2'),
          0x00_00_08_00_00_00_00_00,
          0x00_00_14_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('f2'),
          0x00_00_04_00_00_00_00_00,
          0x00_00_0A_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('g2'),
          0x00_00_02_00_00_00_00_00,
          0x00_00_05_00_00_00_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::WHITE, Chess::Piece::PAWN),
          Coord.from_alg('h2'),
          0x00_00_01_00_00_00_00_00,
          0x00_00_01_00_00_00_00_00
        )
      ], 
      Colour::BLACK=> [
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK),
          Coord.from_alg('a8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::KNIGHT),
          Coord.from_alg('b8'),
          0x00_00_00_00_00_A0_00_00,
          0x00_00_00_00_00_A0_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP),
          Coord.from_alg('c8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::QUEEN),
          Coord.from_alg('d8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::KING),
          Coord.from_alg('e8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::BISHOP),
          Coord.from_alg('f8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::KNIGHT),
          Coord.from_alg('g8'),
          0x00_00_00_00_00_05_00_00,
          0x00_00_00_00_00_05_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::ROOK),
          Coord.from_alg('h8')
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('a7'),
          0x00_00_00_00_00_80_00_00,
          0x00_00_00_00_00_40_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('b7'),
          0x00_00_00_00_00_40_00_00,
          0x00_00_00_00_00_A0_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('c7'),
          0x00_00_00_00_00_20_00_00,
          0x00_00_00_00_00_50_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('d7'),
          0x00_00_00_00_00_10_00_00,
          0x00_00_00_00_00_28_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('e7'),
          0x00_00_00_00_00_08_00_00,
          0x00_00_00_00_00_14_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('f7'),
          0x00_00_00_00_00_04_00_00,
          0x00_00_00_00_00_0A_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('g7'),
          0x00_00_00_00_00_02_00_00,
          0x00_00_00_00_00_05_00_00
        ),
        PieceInfo.new(
          Chess::Piece.new(Colour::BLACK, Chess::Piece::PAWN),
          Coord.from_alg('h7'),
          0x00_00_00_00_00_01_00_00,
          0x00_00_00_00_00_01_00_00
        )
      ], 
    }
  end

  def pcfcoord(coord) 
    @pieces.values.flatten.detect {|info| info.coord == coord} 
  end
end

class GameState
  DEFAULT_SEPARATOR = ' '

  RANK_MASKS = [
    0xFF_00_00_00_00_00_00_00,
    0x00_FF_00_00_00_00_00_00,
    0x00_00_FF_00_00_00_00_00,
    0x00_00_00_FF_00_00_00_00,
    0x00_00_00_00_FF_00_00_00,
    0x00_00_00_00_00_FF_00_00,                      
    0x00_00_00_00_00_00_FF_00,    
    0x00_00_00_00_00_00_00_FF
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

  attr_accessor :moves
  attr_reader :piece_info_bag
      
  def initialize()     
    @white_can_castle_kingside = true;
    @white_can_castle_queenside = true;
    @black_can_castle_kingside = true;
    @black_can_castle_kingside = true;
    
    @chk_lookup = {
      Chess::Piece::BISHOP => method(:chk_mv_bishop),
      Chess::Piece::KING => method(:chk_mv_king),
      Chess::Piece::KNIGHT => method(:chk_mv_knight),
      Chess::Piece::PAWN => method(:chk_mv_pawn),
      Chess::Piece::QUEEN => method(:chk_mv_queen),
      Chess::Piece::ROOK => method(:chk_mv_rook)
    }
    
    @calc_mv_lookup = {
      Chess::Piece::PAWN => method(:calc_all_mv_pawn),
      Chess::Piece::KNIGHT => method(:calc_all_mv_knight),
      Chess::Piece::BISHOP => method(:calc_all_mv_bishop),
      Chess::Piece::ROOK => method(:calc_all_mv_rook),
      Chess::Piece::QUEEN => method(:calc_all_mv_queen)
    }

    @clr_pos = {
      Colour::BLACK => 0x00_00_00_00_00_00_FF_FF,
      Colour::WHITE => 0xFF_FF_00_00_00_00_00_00
    }

    @pos = {
      Chess::Piece::PAWN => 0x00_FF_00_00_00_00_FF_00,  
      Chess::Piece::ROOK => 0x81_00_00_00_00_00_00_81,
      Chess::Piece::KNIGHT => 0x42_00_00_00_00_00_00_42,
      Chess::Piece::BISHOP => 0x24_00_00_00_00_00_00_24,
      Chess::Piece::QUEEN => 0x10_00_00_00_00_00_00_10,
      Chess::Piece::KING => 0x08_00_00_00_00_00_00_08 
    }

    @attack = {
      Colour::BLACK => {
        Chess::Piece::PAWN => 0x00_00_00_00_00_FF_00_00,
        Chess::Piece::ROOK => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::KNIGHT => 0x00_00_00_00_00_A5_18_00,
        Chess::Piece::BISHOP => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::QUEEN => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::KING => 0x00_00_00_00_00_00_1C_14
      },
      Colour::WHITE => {
        Chess::Piece::PAWN => 0x00_00_FF_00_00_00_00_00,
        Chess::Piece::ROOK => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::KNIGHT => 0x00_18_A5_00_00_00_00_00,
        Chess::Piece::BISHOP => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::QUEEN => 0x00_00_00_00_00_00_00_00,
        Chess::Piece::KING => 0x14_1C_00_00_00_00_00_00
      }
    }

    @piece_info_bag = PieceInfoBag.new;
  end

  def clear()    
    @clr_pos.each_key {|key| @clr_pos[key] = 0}
    @pos.each_key {|key| @pos[key] = 0}
    @attack.each_key do |clr|
      @attack[clr].each_key do |pc|
        @attack[clr][pc] = 0
      end
    end    
  end
  # Output a text representation of the current board state using the specified separator
  # If no separator is defined, the default separator is used.
  
  def to_txt(sep = DEFAULT_SEPARATOR)
    tr = Translator::PieceTranslator.new()
    txt, row = '', 8;

    # Because we store the board in a standard orientation, in order to make the board
    # look "right side up" in a textual representation, we have to do the y-axis in
    # reverse.        
    (7).downto(0) do |y|
      # Output the rank number (for alg coord)
      txt += "#{row}" + sep
      row -= 1
      
      # Output the pieces on the rank
      (0...8).each do |x|
        sq = sq_at(Coord.new(x, y))
        txt += sq.piece.nil? ? "-" : tr.to_txt(sq.piece)
        txt += sep
      end
      
      txt += "\n"
    end

    # Offset to compensate for rank numbers in layout
    (sep.length + 1).times do 
      txt += DEFAULT_SEPARATOR 
    end

    # Output the file letters
    (97...(97 + 8)).each do |col|
      txt += col.chr + sep
    end 

    txt += "\n"
  end
  #----------------------------------------------------------------------------
  # Start bit-vector helpers
  # ---------------------------------------------------------------------------
  
  # get the shift width required to get the square specified by the provided 
  # coord
  #
  # This formula is derived from (8 * (7 - y)) + (7 - x), it shifts by bytes
  # to get to the proper rank, then by bits to get to the proper file  
  def self.get_sw(coord)
    63 - (8 * coord.y) - coord.x
  end

  def get_sw(coord) 
    GameState.get_sw(coord)
  end
  
  # get a bitvector with a single bit set, representing the square at the 
  # provided coord.  
  def self.get_bv(coord)
    0x1 << get_sw(coord)
  end

  def get_bv(coord) 
    GameState.get_bv(coord)
  end  

  def self.pp_bv
    out = ""
    63.downto(0) do |i|
      out += @bv[i].to_s
      out += " " if (i % 8 == 0)
    end
    out.chop
  end
  
  def pp_bv(bv)
    out = ""
    63.downto(0) do |i|
      out += bv[i].to_s
      out += " " if (i % 8 == 0)
    end
    out.chop
  end
  #----------------------------------------------------------------------------
  # End bit-vector helpers
  # ---------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Start board helpers
  #----------------------------------------------------------------------------

  # Determine the colour of the square at the given coord
  def self.clrfcoord(coord) 
    ((coord.x + coord.y) & 1 == 0) ? Colour::BLACK : Colour::WHITE
  end

  def self.find_east_edge(bv) 
    # formula is
    # x = board_size
    # y = rank of bit vector
    # z = right edge
    # 
    # z = 2^(x^2 - x - xy)
    # 
    # or: 
    # 
    # 2^(board_size*(board_size - 1 - rank))
    0x1 << ((7 - GameState.get_rank(bv)) << 3)
  end

  def self.find_west_edge(bv)
    # formula is
    # x = board_size
    # y = rank of bit vector
    # z = left edge
    # 
    # z = 2^(x^2 - xy - 1)
    # 
    # or:
    # 
    # 2^(board_size*(board_size - 1 - rank) + (board_size - 1))
    0x1 << (((7 - GameState.get_rank(bv)) << 3) + 7)
  end 

  def self.get_file(bv)
    file = 7
    while (bv & 0xFF) != bv
      bv >>= 8
    end
    while (bv & 0x01) != bv
      file -= 1
      bv >>= 1
    end
    file
  end
  
  def self.get_file_mask(bv) 
    return FILE_MASKS[get_file(bv)]    
  end  
  
  def self.get_rank(bv) 
    rank = 7
    while (bv & 0xFF) != bv
      rank -= 1
      bv >>= 8
    end
    rank
  end
  
  def self.get_rank_mask(bv) 
    return RANK_MASKS[get_rank(bv)]
  end
  
  def self.on_board?(bv)
    bv.between?(1, 0xFF_FF_FF_FF_FF_FF_FF_FF)
  end  

  # Is the given coord attacked by any piece of the given colour
  def attacked?(clr, coord)
    (1 << get_sw(coord)) & calculate_colour_attack(clr) != 0
  end    

  #
  # TODO: This is a placeholder implementation based on sq_at, 
  # so it's quite inefficient
  # 
  def blocked?(src, dest) 
    l = Line.new(src, dest)
      
    l.each_coord do |c|        
      return true unless sq_at(c).piece.nil? || c == src
    end
    
    false
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
  
  def sq_at(coord) 
    square = Chess::Square.new(coord, GameState.clrfcoord(coord))
    mask = GameState.get_bv(coord)
    
    # Look for a piece of either colour in that square
    piece = nil
    color = (@clr_pos[Colour::BLACK] & mask) == mask \
      ? Colour::BLACK \
      : (@clr_pos[Colour::WHITE] & mask) == mask \
        ? Colour::WHITE \
        : nil

    # Determine piece type
    if !color.nil?          
      @pos.each_key do |key|
        if (@pos[key] & mask) == mask
          square.piece = Chess::Piece.new(color, key)
        end
      end
    end
    
    square
  end  
  #----------------------------------------------------------------------------
  # End board helpers
  # ---------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
  # Start piece helpers
  #----------------------------------------------------------------------------
  def can_castle?(colour) 
    can_castle_kingside?(colour) or can_castle_queenside?(colour)
  end
  
  def can_castle_kingside?(colour) 
    colour.white? ? @white_can_castle_kingside : @black_can_castle_kingside
  end
  
  def can_castle_queenside?(colour) 
    colour.black ? @black_can_castle_queenside : @white_can_castle_queenside
  end
  
  def move?(src, dest)
    chk_mv(src, dest)
  end
  
  def move!(src, dest)
    require 'move'
    @moves.push(Move.execute(src, dest, self))
  end
   
  def move_piece(src, dest)
    @piece_info_bag.pcfcoord(src).coord = dest

    # bit vector representing the source square
    src_bv = 0x1 << get_sw(src)
    
    # bit vector representing the destination square
    dest_bv = 0x1 << get_sw(dest)
    
    # bit vector representing the change required for the move
    ch_bv = (src_bv | dest_bv)
     
    @clr_pos.each_key do |key|
      @clr_pos[key] ^= ch_bv if (@clr_pos[key] & src_bv) == src_bv
    end

    @pos.each_key do |key|
      if (@pos[key] & src_bv) == src_bv
        @pos[key] ^= ch_bv
        return
      end
    end
  end
    
  def place_piece(coord, piece) 
    pc_bv = 0x1 << get_sw(coord)
    
    #remove any existing piece at the coord
    remove_piece(coord)
        
    
    @clr_pos[piece.colour] |= pc_bv      
    @pos[piece.name] |= pc_bv
  end
  
  def remove_piece(coord)
    pc_bv = 0x1 << get_sw(coord)
    
    # Make sure there's a piece to remove
    piece = sq_at(coord).piece
    
    return unless !piece.nil?
    
    @clr_pos[piece.colour] ^= pc_bv
    @pos[piece.name] ^= pc_bv
  end
  #----------------------------------------------------------------------------
  # End piece helpers
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Start attack calculation
  #----------------------------------------------------------------------------
  def calculate_pawn_attack(coord)
    mask_left  = 0x7F_7F_7F_7F_7F_7F_7F_7F
    mask_right = 0xFE_FE_FE_FE_FE_FE_FE_FE

    bv_p = (0x01 << get_sw(coord))
    clr = sq_at(coord).piece.colour

    # right attack
    bv = mask_right & (clr.white? ? bv_p >> 7 : bv_p << 9)

    # left attack
    bv |= mask_left & (clr.white? ? bv_p >> 9 : bv_p << 7)
     
    bv
  end
  
  def calculate_rook_attack(coord)
    clr = sq_at(coord).piece.colour
    
    bv = 0x0
    
    bv |= calculate_file_attack(clr, coord)    
    bv |= calculate_rank_attack(clr, coord)
    
    bv
  end
  
  def calculate_knight_attack(coord)
    
    bv_piece = (1 << get_sw(coord))
    bv = 0
    
    # knight attack position legend for below (k == knight)
    #  B C
    # A   D
    # K
    # E   H
    #  F G
  
    # A
    bv_board_mask = 0x00_3F_3F_3F_3F_3F_3F_3F
    bv |= (bv_piece & bv_board_mask) << 10

    # B
    bv_board_mask = 0x00_00_7F_7F_7F_7F_7F_7F
    bv |= (bv_piece & bv_board_mask) << 17

    # C
    bv_board_mask = 0x00_00_FE_FE_FE_FE_FE_FE
    bv |= (bv_piece & bv_board_mask) << 15

    # D
    bv_board_mask = 0x00_FC_FC_FC_FC_FC_FC_FC
    bv |= (bv_piece & bv_board_mask) << 6

    # E
    bv_board_mask = 0x3F_3F_3F_3F_3F_3F_3F_00
    bv |= (bv_piece & bv_board_mask) >> 6

    # F
    bv_board_mask = 0x7F_7F_7F_7F_7F_7F_00_00
    bv |= (bv_piece & bv_board_mask) >> 15

    # G
    bv_board_mask = 0xFE_FE_FE_FE_FE_FE_00_00
    bv |= (bv_piece & bv_board_mask) >> 17

    # H
    bv_board_mask = 0xFC_FC_FC_FC_FC_FC_FC_00
    bv |= (bv_piece & bv_board_mask) >> 10

    bv
  end
  
  def calculate_bishop_attack(coord)
    bv = 0
    bv_piece = (1 << get_sw(coord))
    clr = sq_at(coord).piece.colour

    
    0.upto(63) do |i|
      if (1 << i & bv_piece != 0)
        bv |= calculate_diagonal_attack(clr, i)
      end
    end
    
    @attack[clr][Chess::Piece::BISHOP] = bv
  end
  
  def calculate_queen_attack(coord)
    bv = 0x0 
    clr = sq_at(coord).piece.colour

    bv |= calculate_bishop_attack(coord);
    bv |= calculate_rook_attack(coord);
    
    @attack[clr][Chess::Piece::QUEEN] = bv
    return bv
  end

  def calculate_king_attack(clr)
    bv = 0
    bv_piece = @clr_pos[clr] & @pos[Chess::Piece::KING]

    # Move list. k == king.
    # ABC
    # DkE
    # FGH

    # A
    bv_board_mask = 0x00_7F_7F_7F_7F_7F_7F_7F
    bv |= (bv_piece & bv_board_mask) << 9

    # B
    bv_board_mask = 0x00_FF_FF_FF_FF_FF_FF_FF
    bv |= (bv_piece & bv_board_mask) << 8

    # C
    bv_board_mask = 0x00_FE_FE_FE_FE_FE_FE_FE
    bv |= (bv_piece & bv_board_mask) << 7

    # D
    bv_board_mask = 0x7F_7F_7F_7F_7F_7F_7F_7F
    bv |= (bv_piece & bv_board_mask) << 1

    # E
    bv_board_mask = 0xFE_FE_FE_FE_FE_FE_FE_FE
    bv |= (bv_piece & bv_board_mask) >> 1

    # F
    bv_board_mask = 0x7F_7F_7F_7F_7F_7F_7F_00
    bv |= (bv_piece & bv_board_mask) >> 7

    # G
    bv_board_mask = 0xFF_FF_FF_FF_FF_FF_FF_00
    bv |= (bv_piece & bv_board_mask) >> 8

    # H
    bv_board_mask = 0xFE_FE_FE_FE_FE_FE_FE_00
    bv |= (bv_piece & bv_board_mask) >> 9
     
    @attack[clr][Chess::Piece::KING] = bv  
  end
  
  def calculate_colour_attack(clr)
    @attack[clr].values.inject(0) {|bv, val| bv | val}
  end
  
  def calculate_file_attack(clr, coord)
    bv = 0

    attacking_piece = get_sw(coord)
    all_pieces = @clr_pos.values.inject(0) {|mask,val| mask | val} 
    opp_pieces = @clr_pos[clr.flip]

    chk_cell = attacking_piece - 8
    while (chk_cell > 0)
      if ((1 << chk_cell) & all_pieces) == 0 
        bv |= 1 << chk_cell
      else
        if ((1 << chk_cell) & opp_pieces) > 0 
          bv |= 1 << chk_cell
        end
        break
      end
      chk_cell -= 8
    end

    chk_cell = attacking_piece + 8
    while (chk_cell <= 63)
      if ((1 << chk_cell) & all_pieces) == 0
        bv |= 1 << chk_cell
      else
        if ((1 << chk_cell) & opp_pieces) > 0
          bv |= 1 << chk_cell
        end
        break
      end
      chk_cell += 8
    end

    bv
  end
  
  def calculate_rank_attack(clr, coord)
    piece_bv = 0x1 << get_sw(coord)
    attacking_piece = piece_bv

    attack_bitbrd = 0
    opp_pieces = @clr_pos[clr.flip]
    all_pieces = @clr_pos.values.inject(0) {|mask, val| mask | val}

    if (attacking_piece == 0)
      # attacking piece is not on this file, abort
      return 0            
    end
    
    left_edge = GameState.find_west_edge(attacking_piece)
    right_edge = GameState.find_east_edge(attacking_piece)
    
    chk_cell = attacking_piece
    loop do
      chk_cell <<= 0x1
      break if chk_cell > left_edge
      if (all_pieces & chk_cell) == 0
        attack_bitbrd |= chk_cell
      else
        if (opp_pieces & chk_cell) > 0
        attack_bitbrd |= chk_cell
        end
        break
      end
    end   

    chk_cell = attacking_piece
    loop do
      chk_cell >>= 0x1
      break if chk_cell < right_edge
      if (chk_cell & all_pieces) == 0
        attack_bitbrd |= chk_cell
      else
        if (chk_cell & opp_pieces) > 0
        attack_bitbrd |= chk_cell
        end
        break;
      end
    end 
    
    attack_bitbrd
  end
  
  def calculate_diagonal_attack(clr, sq)
    mask_left  = 0x80_80_80_80_80_80_80_80
    mask_right = 0x01_01_01_01_01_01_01_01
    bv = 0
    all_pieces = @clr_pos.values.inject(0) {|mask, val| mask | val}
    opp_pieces = @clr_pos[clr.flip]

    operations = [
       [mask_left,  -9], # SW -> NE
       [mask_right, -7], # SE -> NW
       [mask_left,   7], # NW -> SE
       [mask_right,  9]  # NE -> SW
    ]
    
    operations.each do |params|
      edge_mask = params[0]
      shift_width = params[1]

      chk_sq = sq
      next_sq = chk_sq + shift_width

      next_sq_off_edge = ((1 << next_sq) & edge_mask != 0) || next_sq < 0 || next_sq >= 64
      blocked  = false

      until(next_sq_off_edge || blocked)
        chk_sq = next_sq
        next_sq = chk_sq + shift_width
        if ((1 << chk_sq) & all_pieces) == 0 || ((1 << chk_sq) & opp_pieces) > 0 
          bv |= (1 << chk_sq)
        end

        next_sq_off_edge = ((1 << next_sq) & edge_mask != 0) || next_sq < 0 || next_sq >= 64
        blocked  = (1 << chk_sq) & all_pieces != 0
      end
    end

    bv
  end
  #----------------------------------------------------------------------------
  # End attack calculation
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Start potential move calculation
  #---------------------------------------------------------------------------- 
  
  # Note: For now, calculating all possible moves is a just-in-time calculation,
  # so we will return the bit vector representing all possible moves.  You'd
  # think it's the same as all possible captures, but then you aren't thinking
  # about pawns or kings :-D
  def calculate_all_moves(src) 
    pc = sq_at(src).piece
    @calc_mv_lookup[pc.name].call(src)
  end
  
  def calc_all_mv_pawn(src)
    mv_bv = 0x0
    
    # This is a lazy way :-D
    # Note: We can't just bitwise OR the mv_bv with the result of 
    # calculate pawn attack, because that method calculates all squares 
    # attacked by pawns, regardless whether or not there is something to attack
    if sq_at(src).piece.colour == Colour::WHITE then
      mv_bv |= get_bv(src.north) if chk_mv(src, src.north)
      mv_bv |= get_bv(src.north.north) if chk_mv(src, src.north.north)
      mv_bv |= get_bv(src.northwest) if chk_mv(src, src.northwest)
      mv_bv |= get_bv(src.northeast) if chk_mv(src, src.northeast)
    else
      mv_bv |= get_bv(src.south) if chk_mv(src, src.south)
      mv_bv |= get_bv(src.south.south) if chk_mv(src, src.south.south)      
      mv_bv |= get_bv(src.southwest) if chk_mv(src, src.southwest)
      mv_bv |= get_bv(src.southeast) if chk_mv(src, src.southeast)
    end
    
    mv_bv
  end
  
  def calc_all_mv_knight(src) 
    mv_bv = 0x0
    
    mv_bv |= get_bv(src.north.west.west) if chk_mv(src, src.north.west.west)
    mv_bv |= get_bv(src.north.north.west) if chk_mv(src, src.north.north.west)
    mv_bv |= get_bv(src.north.north.east) if chk_mv(src, src.north.north.east)
    mv_bv |= get_bv(src.east.east.north) if chk_mv(src, src.east.east.north)
    mv_bv |= get_bv(src.east.east.south) if chk_mv(src, src.east.east.south)
    mv_bv |= get_bv(src.south.south.east) if chk_mv(src, src.south.south.east)
    mv_bv |= get_bv(src.south.south.west) if chk_mv(src, src.south.south.west)
    mv_bv |= get_bv(src.west.west.south) if chk_mv(src, src.west.west.south)
    mv_bv |= get_bv(src.west.west.north) if chk_mv(src, src.west.west.north)
    
    mv_bv
  end
  
  def calc_all_mv_bishop(src)
    return calculate_bishop_attack(src)
  end
  
  def calc_all_mv_rook(src)
    return calculate_rook_attack(src)
  end
  
  def calc_all_mv_queen(src)
    return calculate_queen_attack(src)
  end
  #----------------------------------------------------------------------------
  # End potential move calculation
  #---------------------------------------------------------------------------- 
  #----------------------------------------------------------------------------
  # Start legal move checks
  #---------------------------------------------------------------------------- 
  def chk_mv(src, dest) 
    return false if src.x < 0 || src.y < 0
    return false if dest.x < 0 || dest.y < 0
    pc = sq_at(src).piece
    pc.nil? ? false : @chk_lookup[pc.name].call(src, dest)
  end
  
  def chk_mv_pawn(src, dest)
    pc_src = sq_at(src).piece
    pc_dest = sq_at(dest).piece      
  
    # no matter what, the pawn has to move forward
    dst = dest.y - src.y
    
    # in the coordinate system, a forward move is a reduction in y for black
    dst = -dst if pc_src.colour.black?
     
    return false unless dst > 0       

    # no matter what, the pawn can only stay on the same rank or ONE either way        
    return false unless ((src.x - 1)..(src.x + 1)) === dest.x
    
    # pawns can move one square forward except for first move
    # I'm not a fan of this, but it works for now:
    at_strt = (pc_src.colour.white? ? src.y == 1 : src.y == 6)
    if at_strt && ![1,2].include?(dst) || !at_strt && dst != 1
      return false
    end
    
    if dst == 1 && [src.x + 1, src.x - 1].include?(dest.x)
      # it's a diagonal move, ensure it's a capture

      if (pc_dest.nil?)
        # en passant hack
        if (pc_src.colour.white? && src.y == 4) || src.y == 3
          [Coord.new(src.x - 1, src.y), Coord.new(src.x + 1, src.y)].each do |ep_coord|
            ep_pc = sq_at(ep_coord).piece
            unless ep_pc.nil? || ep_pc.name != Chess::Piece::PAWN
              last_mv = @moves.last
              return last_mv.dest == ep_coord && last_mv.src == Coord.new(ep_coord.x, ep_coord.y + (pc_src.colour.white? ? 2 : -2))
            end
          end
          return false
        else
          return false
        end
      else
        return pc_dest.colour.opposite?(pc_src.colour)
      end
    else 
      # it's a straight move, ensure it's not blocked                  
      return false if !pc_dest.nil? || blocked?(src, dest)
    end
    
    true
  end      
  
  def chk_mv_bishop(src, dest) 
    # Bishops can only move diagonally and cannot jump pieces
    return false unless src.on_diag?(dest) && !blocked?(src, dest)    
    
    # If a piece is on the dest square, make sure it's a capture.
    pc_dest = sq_at(dest).piece
    pc_src = sq_at(src).piece
    
    (!pc_dest.nil? && !pc_src.color.opposite?(pc_dest.color)) || true
  end
  
  def chk_mv_rook(src, dest) 
    return false unless (src.on_rank?(dest) || src.on_file?(dest)) && !blocked?(src, dest)
    
    # If a piece is on the dest square, make sure it's a capture.
    pc_dest = sq_at(dest).piece
    pc_src = sq_at(src).piece
    
    (!pc_dest.nil? && !pc_src.color.opposite?(pc_dest.color)) || true      
  end
  
  def chk_mv_queen(src, dest)
    chk_mv_bishop(src, dest) || chk_mv_rook(src, dest)
  end
  
  def chk_mv_king(src, dest) 
    l = Line.new(src, dest)
    
    king = sq_at(src).piece
    
    #TODO: this is probably better verified as part of game state
    in_start_position = king.colour.white? \
      ? src == Coord.from_alg("e1") \
      : src == Coord.from_alg("e8")
    
    # King can only move one square unless castling
    if (not in_start_position) or (not can_castle?(king.colour)) 
      return false unless l.len == 1
    else
      return false unless l.len == 3
    end

    if (l.len == 3) 
      # Castling is only left/right
      return false unless src.on_rank?(dest)
    end    
    
    # Can only capture opposite coloured pieces
    dest_pc = sq_at(dest).piece
    
    (!dest_pc.nil? && !king.color.opposite?(dest_pc.color)) || true
  end
  
  def chk_mv_knight(src, dest) 
    # Knights move in an "L" shape
    return false unless ((src.x - dest.x).abs + (src.y - dest.y).abs) == 3

    # Can only capture opposite coloured pieces
    knight = sq_at(src).piece
    dest_pc = sq_at(dest).piece
    
    (!dest_pc.nil? && !knight.colour.opposite?(dest_pc.colour)) || true
  end
  #----------------------------------------------------------------------------
  # Start legal move checks
  #---------------------------------------------------------------------------- 

end
