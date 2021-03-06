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
require "chess/piece"
require "chess/square"
require "geometry/coord"
require "geometry/line"
require "geometry/vector"
require "colour"
require "move"
require "piece_translator"

class RulesEngine
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

  attr_accessor :move_list

  def initialize()
    @move_list = []
    @fifty_mv_rule = 0
    @three_fold_cache = {}

    @white_can_castle_kingside = true
    @white_can_castle_queenside = true
    @black_can_castle_kingside = true
    @black_can_castle_queenside = true

    @chk_mv = {
      Chess::Piece::BISHOP => method(:chk_mv_bishop),
      Chess::Piece::KING => method(:chk_mv_king),
      Chess::Piece::KNIGHT => method(:chk_mv_knight),
      Chess::Piece::PAWN => method(:chk_mv_pawn),
      Chess::Piece::QUEEN => method(:chk_mv_queen),
      Chess::Piece::ROOK => method(:chk_mv_rook)
    }

    @calc_mv = {
      Chess::Piece::PAWN => method(:calc_all_mv_pawn),
      Chess::Piece::KNIGHT => method(:calc_all_mv_knight),
      Chess::Piece::BISHOP => method(:calc_all_mv_bishop),
      Chess::Piece::ROOK => method(:calc_all_mv_rook),
      Chess::Piece::QUEEN => method(:calc_all_mv_queen),
      Chess::Piece::KING => method(:calc_all_mv_king)
    }

    @calc_attk = {
      Chess::Piece::PAWN => method(:calc_attk_pawn),
      Chess::Piece::KNIGHT => method(:calc_attk_knight),
      Chess::Piece::BISHOP => method(:calc_attk_bishop),
      Chess::Piece::ROOK => method(:calc_attk_rook),
      Chess::Piece::QUEEN => method(:calc_attk_queen),
      Chess::Piece::KING => method(:calc_attk_king)
    }

    @clr_pos = {
      Colour::BLACK => 0x00_00_00_00_00_00_FF_FF,
      Colour::WHITE => 0xFF_FF_00_00_00_00_00_00
    }

    @pc_pos = {
      Chess::Piece::PAWN => 0x00_FF_00_00_00_00_FF_00,
      Chess::Piece::ROOK => 0x81_00_00_00_00_00_00_81,
      Chess::Piece::KNIGHT => 0x42_00_00_00_00_00_00_42,
      Chess::Piece::BISHOP => 0x24_00_00_00_00_00_00_24,
      Chess::Piece::QUEEN => 0x10_00_00_00_00_00_00_10,
      Chess::Piece::KING => 0x08_00_00_00_00_00_00_08
    }
  end

  def clear()
    @clr_pos.each_key {|key| @clr_pos[key] = 0}
    @pc_pos.each_key {|key| @pc_pos[key] = 0}
  end

  # Output a text representation of the current board state using the specified separator
  # If no separator is defined, the default separator is used.

  def to_txt(sep = DEFAULT_SEPARATOR)
    tr = PieceTranslator.new()
    txt, row = '', 8

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

  def self.get_coord_for_bv(bv)
    # only one bit can be set for this to be a legal square bv
    raise ArgumentError, "Illegal bv for square #{pp_bv(bv)}" unless bv > 0 && bv & -bv == bv

    # TODO: This is so inefficient it hurts, but will do for now
    0.upto(7) do |x|
      0.upto(7) do |y|
        coord = Coord.new(x, y)
        if 0x01 << get_sw(coord) == bv
          return coord
        end
      end
    end

    raise ArgumentError, "Could not find bv for square #{pp_bv(bv)}."
  end

  def get_coord_for_bv(bv)
    RulesEngine.get_coord_for_bv(bv)
  end

  # get the shift width required to get the square specified by the provided 
  # coord
  #
  # This formula is derived from (8 * (7 - y)) + (7 - x), it shifts by bytes
  # to get to the proper rank, then by bits to get to the proper file  
  def self.get_sw(coord)
    63 - (8 * coord.y) - coord.x
  end

  def get_sw(coord)
    RulesEngine.get_sw(coord)
  end

  # get a bitvector with a single bit set, representing the square at the 
  # provided coord.  
  def self.get_bv(coord)
    0x1 << get_sw(coord)
  end

  def get_bv(coord)
    RulesEngine.get_bv(coord)
  end

  def self.pp_bv(bv)
    out = ""
    63.downto(0) do |i|
      out += bv[i].to_s
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
    0x1 << ((7 - RulesEngine.get_rank(bv)) << 3)
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
    0x1 << (((7 - RulesEngine.get_rank(bv)) << 3) + 7)
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

  def self.calc_board_vector(coord, direction)
    end_point = Coord.new(coord.x, coord.y)
    loop do
      if (direction == Coord::NORTH && coord_on_board?(end_point.north))
        end_point.north!
      elsif (direction == Coord::SOUTH && coord_on_board?(end_point.south))
        end_point.south!
      elsif (direction == Coord::EAST && coord_on_board?(end_point.east))
        end_point.east!
      elsif (direction == Coord::WEST && coord_on_board?(end_point.west))
        end_point.west!
      elsif (direction == Coord::NORTHEAST && coord_on_board?(end_point.northeast))
        end_point.northeast!
      elsif (direction == Coord::NORTHWEST && coord_on_board?(end_point.northwest))
        end_point.northwest!
      elsif (direction == Coord::SOUTHEAST && coord_on_board?(end_point.southeast))
        end_point.southeast!
      elsif (direction == Coord::SOUTHWEST && coord_on_board?(end_point.southwest))
        end_point.southwest!
      else
        break
      end
    end
    Vector.new(coord, end_point)
  end

  def self.coord_on_board?(coord)
    coord.x.between?(0, 7) && coord.y.between?(0, 7)
  end

  # Is the given coord attacked by any piece of the given colour
  # Make sure that calculate_colour_attack is called before this method

  def attacked?(clr, coord)
    attacked_calc?(coord, calculate_colour_attack(clr))
  end

  def attacked_calc?(coord, attk_bv)
    sq_bv = (0x01 << get_sw(coord))
    (sq_bv & attk_bv) == sq_bv
  end

  def blocked?(src, dest)
    src_bv = get_bv(src)
    dest_bv = get_bv(dest)

    src_clr = @clr_pos[Colour::WHITE] &  src_bv == src_bv ? Colour::WHITE : Colour::BLACK

    # short cut - own colour always blocks
    if (dest_bv & @clr_pos[src_clr]) == dest_bv
      return true
    end

    # pawns can't capture straight ahead
    if (src_bv & @pc_pos[Chess::Piece::PAWN]) == src_bv &&
        (RulesEngine.get_file(src_bv) == RulesEngine.get_file(dest_bv)) && 
        (dest_bv & @clr_pos[src_clr.flip]) == dest_bv
      return true
    end

    # TODO: From here, this is a placeholder implementation based on sq_at, 
    # so it's quite inefficient
    src_pc = sq_at(src).piece
    dest_pc = sq_at(dest).piece

    # Only knights won't be on the same line, and they are handled in the check above
    return false unless Line.same_line?(src, dest) 

    l = Line.new(src, dest)

    l.each_coord do |c|
      break if c == dest
      return true unless sq_at(c).piece.nil? || c == src
    end

    !(dest_pc.nil? || src_pc.colour.opposite?(dest_pc.colour))
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
    return nil unless coord.x.between?(0, 7)
    return nil unless coord.y.between?(0, 7)

    square = Chess::Square.new(coord, RulesEngine.clrfcoord(coord))
    mask = RulesEngine.get_bv(coord)

    # Look for a piece of either colour in that square
    piece = nil
    color = (@clr_pos[Colour::BLACK] & mask) == mask \
      ? Colour::BLACK \
      : (@clr_pos[Colour::WHITE] & mask) == mask \
        ? Colour::WHITE \
        : nil

    # Determine piece type
    if !color.nil?
      @pc_pos.each_key do |key|
        if (@pc_pos[key] & mask) == mask
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
    colour.black? ? @black_can_castle_queenside : @white_can_castle_queenside
  end

  def move?(src, dest)
    chk_mv(src, dest)
  end

  def move!(src, dest)
    unless chk_mv(src, dest)
      raise ArgumentError, "Illegal move: #{src.to_alg},#{dest.to_alg}"
    end

    src_sq = sq_at(src)
    dest_sq = sq_at(dest)
    piece = src_sq.piece

    if !piece.nil? && piece.name == Chess::Piece::KING and Line.new(src, dest).len == 3
      # Castling
      # Move the king
      move_piece(src, dest)

      if src.west_of?(dest)
        # Kingside
        # Jump the rook over the king
        move_piece(Coord.from_alg(piece.colour.white? ? "h1" : "h8"), \
                   dest.west)
      else
        # Queenside
        # Jump the rook over the king
        move_piece(Coord.from_alg(piece.colour.white? ? "a1" : "a8"), \
                   dest.east)
      end
    else
      move_piece(src, dest)
    end

    if piece.king?
      # set castle state to false
      if (piece.colour == Colour::WHITE)
        @white_can_castle_kingside = false
        @white_can_castle_queenside = false
      else
        @black_can_castle_kingside = false
        @black_can_castle_queenside = false
      end
    end

    if piece.rook?
      if src == Coord.new(0, 0)
        @white_can_castle_kingside = false
      elsif src == Coord.new(7, 0)
        @white_can_castle_queenside = false
      elsif src == Coord.new(0, 7)
        @black_can_castle_kingside = false
      elsif src == Coord.new(7, 7)
        @black_can_castle_queenside = false
      end
    end

    if piece.pawn? || dest_sq.piece.nil?
      @fifty_mv_rule += 1
    else 
      @fifty_mv_rule = 0
    end

    if (dest_sq.piece.nil?)
      cached_state = three_fold_hash;
      @three_fold_cache.has_key?(cached_state) ?
          @three_fold_cache[cached_state] += 1 :
          @three_fold_cache[cached_state] = 1
    else
      @three_fold_cache.clear
    end

    @move_list.push(Move.new(src, dest))
  end

  # Note that this just assumes that the move is valid, so make sure it's 
  # called through something like move! that does verification.

  def move_piece(src, dest)
    # bit vector representing the source square
    src_bv = 0x1 << get_sw(src)

    # bit vector representing the destination square
    dest_bv = 0x1 << get_sw(dest)

    # bit vector representing the change required for the move
    ch_bv = (src_bv | dest_bv)

    # remove captured piece
    @clr_pos.each_key do |key|
      if ((@clr_pos[key] & dest_bv) == dest_bv)
        @clr_pos[key] ^= dest_bv
      end
    end
    @pc_pos.each_key do |key|
      if ((@pc_pos[key] & dest_bv) == dest_bv)
        @pc_pos[key] ^= dest_bv
      end
    end


    @clr_pos.each_key do |key|
      if ((@clr_pos[key] & src_bv) == src_bv)
        @clr_pos[key] ^= ch_bv
      end
    end

    @pc_pos.each_key do |key|
      if (@pc_pos[key] & src_bv) == src_bv
        @pc_pos[key] ^= ch_bv
      end
    end
  end

  def place_piece(coord, piece)
    pc_bv = 0x1 << get_sw(coord)

    #remove any existing piece at the coord
    remove_piece(coord)


    @clr_pos[piece.colour] |= pc_bv
    @pc_pos[piece.name] |= pc_bv
  end

  def remove_piece(coord)
    pc_bv = 0x1 << get_sw(coord)

    # Make sure there's a piece to remove
    piece = sq_at(coord).piece

    return unless !piece.nil?

    @clr_pos[piece.colour] ^= pc_bv
    @pc_pos[piece.name] ^= pc_bv
  end

  def promote!(coord, new_piece_name)
    old_piece = sq_at(coord).piece

    if (coord.y != 0 && coord.y != 7)
      raise ArgumentError, "Can only promote from first or eighth rank."
    end
    if (new_piece_name == Chess::Piece::PAWN || new_piece_name == Chess::Piece::KING)
      raise ArgumentError, "Cannot promote to pawn or king."
    end
    raise ArgumentError, "No piece to promote." if old_piece.nil?
    raise ArgumentError, "Only pawns can be promoted." unless old_piece.pawn?
    if (coord.y == 7 && old_piece.colour.black?)
      raise ArgumentError, "Black pawn at 8th rank cannot promote."
    end
    if (coord.y == 0 && old_piece.colour.white?)
      raise ArgumentError, "While pawn at 1st rank cannot promote."
    end

    new_piece = Chess::Piece.new(old_piece.colour, new_piece_name)
    place_piece(coord, new_piece)
  end

  def can_promote?(colour)
    y = colour.white? ? 7 : 0

    0.upto(7) do |x|
      piece = sq_at(Coord.new(x, y)).piece
      if (!piece.nil? && piece.pawn? && piece.colour == colour)
        return true
      end
    end

    false
  end

  #----------------------------------------------------------------------------
  # End piece helpers
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Start attack calculation
  #----------------------------------------------------------------------------

  def calc_attk(src)
    pc = sq_at(src).piece
    return 0 if pc.nil?
    @calc_attk[pc.name].call(src)
  end

  def calc_attk_pawn(src)
    mask_left  = 0x7F_7F_7F_7F_7F_7F_7F_7F
    mask_right = 0xFE_FE_FE_FE_FE_FE_FE_FE

    bv_p = (0x01 << get_sw(src))
    clr = sq_at(src).piece.colour

    # right attack
    bv = mask_right & (clr.white? ? bv_p >> 7 : bv_p << 9)

    # left attack
    bv |= mask_left & (clr.white? ? bv_p >> 9 : bv_p << 7)

    bv
  end

  def calc_attk_rook(src)
    clr = sq_at(src).piece.colour

    bv = 0x0

    bv |= calculate_file_attack(clr, src)
    bv |= calculate_rank_attack(clr, src)

    bv
  end

  def calc_attk_knight(src)

    bv_piece = (1 << get_sw(src))
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

  def calc_attk_bishop(src)
    bv = 0
    bv_piece = (1 << get_sw(src))
    clr = sq_at(src).piece.colour

    cnt = 0
    0.upto(63) do |i|
      cnt += 1
      if ((0x01 << i & bv_piece) > 0)
        bv |= calculate_diagonal_attack(clr, i)
      end
    end

    bv
  end

  def calc_attk_queen(src)
    bv = 0x0
    bv_piece = (1 << get_sw(src))
    clr = sq_at(src).piece.colour

    0.upto(63) do |i|
      if (0x01 << i & bv_piece != 0)
        bv |= calculate_diagonal_attack(clr, i)
      end
    end

    bv |= calc_attk_rook(src)

    bv
  end

  def calc_attk_king(src)
    bv = 0
    bv_piece = (1 << get_sw(src))

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

    bv
  end

  def calculate_colour_attack(clr)
    attk_bv = 0

    0.upto(7) do |x|
      0.upto(7) do |y|
        coord = Coord.new(x, y)
        piece = sq_at(coord).piece

        if (!piece.nil? && (piece.colour == clr))
          attk_bv |= calc_attk(coord)
        end
      end
    end

    attk_bv
  end

  def calculate_file_attack(clr, coord)
    bv = 0

    attacking_piece = get_sw(coord)
    all_pieces = @clr_pos.values.inject(0) {|mask, val| mask | val}
    opp_pieces = @clr_pos[clr.flip]

    chk_cell = attacking_piece - 8
    while (chk_cell > 0)
      chk_bv = 0x0
      if ((1 << chk_cell) & all_pieces) == 0
        chk_bv = 1 << chk_cell
      else
        if ((1 << chk_cell) & opp_pieces) > 0
          chk_bv = 1 << chk_cell
        end
        chk_cell = 0
      end

      if chk_bv > 0 && chk_mv(coord, get_coord_for_bv(chk_bv))
        bv |= chk_bv
      end

      chk_cell -= 8
    end

    chk_cell = attacking_piece + 8
    while (chk_cell <= 63)
      chk_bv = 0x0
      if ((1 << chk_cell) & all_pieces) == 0
        chk_bv = 1 << chk_cell
      else
        if ((1 << chk_cell) & opp_pieces) > 0
          chk_bv = 1 << chk_cell
        end
        chk_cell = 64
      end
      if chk_bv > 0 && chk_mv(coord, get_coord_for_bv(chk_bv))
        bv |= chk_bv
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

    left_edge = RulesEngine.find_west_edge(attacking_piece)
    right_edge = RulesEngine.find_east_edge(attacking_piece)

    chk_cell = attacking_piece
    loop do
      chk_cell <<= 0x1
      break if chk_cell > left_edge
      if (all_pieces & chk_cell) == 0 && chk_mv(coord, get_coord_for_bv(chk_cell))
        attack_bitbrd |= chk_cell
      else
        if (opp_pieces & chk_cell) > 0 && chk_mv(coord, get_coord_for_bv(chk_cell))
          attack_bitbrd |= chk_cell
        end
        break
      end
    end

    chk_cell = attacking_piece
    loop do
      chk_cell >>= 0x1
      break if chk_cell < right_edge
      if (chk_cell & all_pieces) == 0 && chk_mv(coord, get_coord_for_bv(chk_cell))
        attack_bitbrd |= chk_cell
      else
        if (chk_cell & opp_pieces) > 0 && chk_mv(coord, get_coord_for_bv(chk_cell))
          attack_bitbrd |= chk_cell
        end
        break
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

      src = get_coord_for_bv(1 << sq)
      chk_sq = sq
      next_sq = chk_sq + shift_width

      next_sq_off_edge = ((1 << next_sq) & edge_mask != 0) || next_sq < 0 || next_sq >= 64
      blocked  = false

      until (next_sq_off_edge || blocked)
        chk_sq = next_sq
        next_sq = chk_sq + shift_width
        dest = get_coord_for_bv(1 << chk_sq)
        if (((1 << chk_sq) & all_pieces) == 0 || ((1 << chk_sq) & opp_pieces) > 0) && chk_mv(src, dest)
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

  def calculate_all_moves_by_colour(colour)
    mv_bv = 0
    0.upto(63) {|i|
      coord = get_coord_for_bv(0x01 << i)
      pc = sq_at(coord).piece
      if (!pc.nil? && pc.colour == colour)
        mv_bv |= calculate_all_moves(get_coord_for_bv(0x01 << i))
      end
    }
    mv_bv
  end

  # quicker calculation to see if a colour has any available moves will quit fast on success

  def has_move?(colour)
    bv = 0x01
    0.upto(63) {|i|
      coord = get_coord_for_bv(bv)
      pc = sq_at(coord).piece
      if (!pc.nil? && pc.colour == colour && calculate_all_moves(coord) > 0)
        return true
      end
      bv <<= 1
    }
    false
  end

  # Note: For now, calculating all possible moves is a just-in-time calculation,
  # so we will return the bit vector representing all possible moves.  You'd
  # think it's the same as all possible captures, but then you aren't thinking
  # about pawns or kings :-D

  def calculate_all_moves(src)
    pc = sq_at(src).piece
    @calc_mv[pc.name].call(src)
  end

  def calc_all_mv_pawn(src)
    mv_bv = 0x0

    # This is a lazy way :-D
    # Note: We can't just bitwise OR the mv_bv with the result of 
    # calculate pawn attack, because that method calculates all squares 
    # attacked by pawns, regardless whether or not there is something to attack
    if sq_at(src).piece.colour.white? then
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
    return calc_attk_bishop(src)
  end

  def calc_all_mv_rook(src)
    return calc_attk_rook(src)
  end

  def calc_all_mv_queen(src)
    return calc_attk_queen(src)
  end

  def calc_all_mv_king(src)
    mv_bv = 0x0

    mv_bv |= get_bv src.west if chk_mv(src, src.west)
    mv_bv |= get_bv src.northwest if chk_mv(src, src.northwest)
    mv_bv |= get_bv src.north if chk_mv(src, src.north)
    mv_bv |= get_bv src.northeast if chk_mv(src, src.northeast)
    mv_bv |= get_bv src.east if chk_mv(src, src.east)
    mv_bv |= get_bv src.southeast if chk_mv(src, src.southeast)
    mv_bv |= get_bv src.south if chk_mv(src, src.south)
    mv_bv |= get_bv src.southwest if chk_mv(src, src.southwest)

    mv_bv
  end

  #----------------------------------------------------------------------------
  # End potential move calculation
  #---------------------------------------------------------------------------- 
  #----------------------------------------------------------------------------
  # Start legal move checks
  #---------------------------------------------------------------------------- 

  def chk_mv(src, dest)
    piece = sq_at(src).piece
    return false if piece.nil?
    chk_mv_calc(src, dest)
  end

  def chk_mv_calc(src, dest)
    return false unless src.x.between?(0, 7)
    return false unless src.y.between?(0, 7)
    return false unless dest.x.between?(0, 7)
    return false unless dest.y.between?(0, 7)

    intermediate_directions = Coord::NORTHWEST | Coord::NORTHEAST | Coord::SOUTHEAST | Coord::SOUTHWEST
    cardinal_directions = Coord::NORTH | Coord::SOUTH | Coord::EAST | Coord::WEST

    pc = sq_at(src).piece

    can_move = !pc.nil?

    if (can_move) 
        can_move = !blocked?(src, dest)
    end

    if (can_move)
      if (in_check?(pc.colour))
        # Have to move out of check (or block check or capture checking piece)
        dest_pc = sq_at(dest).piece
        move_piece(src, dest)
        if (in_check?(pc.colour))
          can_move = false
        end
        move_piece(dest, src)
        place_piece(dest, dest_pc) unless dest_pc.nil?
      end
    end
    if (can_move)
      can_move = @chk_mv[pc.name].call(src, dest)
      if (can_move)
        king_bv = @clr_pos[pc.colour] & @pc_pos[Chess::Piece::KING]
        king_coord = get_coord_for_bv(king_bv)

        if (Line.same_line?(king_coord, src) || king_coord == src)
          direction = (king_coord == src) ? Line.line_direction(dest, src) : Line.line_direction(king_coord, src)

          dest_pc = sq_at(dest).piece

          # In order to see if the king is in check, easier to just simulate the move
          if (!Line.same_line?(src, dest) || !blocked?(src, dest))
            move_piece(src, dest)

            # perhaps hopelessly naive
            if (in_check?(pc.colour))
              can_move = false
            end

            # correct the simulated move
            move_piece(dest, src)
            place_piece(dest, dest_pc) unless dest_pc.nil?
          end
        end
      end
    end

    can_move
  end

  def chk_mv_pawn(src, dest)
    sq_src = sq_at(src)
    sq_dest = sq_at(dest)
    pc_src = sq_src.piece
    pc_dest = sq_dest.piece

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
    if at_strt && ![1, 2].include?(dst) || !at_strt && dst != 1
      return false
    end

    if dst == 1 && [src.x + 1, src.x - 1].include?(dest.x)
      # it's a diagonal move, ensure it's a capture

      if (pc_dest.nil?)
        # en passant hack
        if (pc_src.colour.white? && src.y == 4) || src.y == 3
          [Coord.new(src.x - 1, src.y), Coord.new(src.x + 1, src.y)].each do |ep_coord|
            ep_sq = sq_at(ep_coord)
            ep_pc = ep_sq.nil? ? nil : ep_sq.piece
            unless ep_pc.nil? || ep_pc.name != Chess::Piece::PAWN
              last_mv = @move_list.last
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

    pc_dest.nil? || pc_src.colour.flip == pc_dest.colour
  end

  def chk_mv_rook(src, dest)
    return false unless (src.on_rank?(dest) || src.on_file?(dest)) && !blocked?(src, dest)

    # If a piece is on the dest square, make sure it's a capture.
    pc_dest = sq_at(dest).piece
    pc_src = sq_at(src).piece

    (!pc_dest.nil? && !pc_src.colour.opposite?(pc_dest.colour)) || true
  end

  def chk_mv_queen(src, dest)
    chk_mv_bishop(src, dest) || chk_mv_rook(src, dest)
  end

  def chk_mv_king(src, dest)
    l = Vector.new(src, dest)

    king = sq_at(src).piece

    attk_bv = calculate_colour_attack(king.colour.flip)

    # King can only move one square unless castling
    if (l.len == 3)
      return false unless can_castle? king.colour

      # Castling is only left/right
      return false unless src.on_rank?(dest)

      l.each_coord do |coord|
        return false if attacked_calc?(coord, attk_bv)
      end

      return true
    end

    return false unless l.len == 2 and not attacked_calc?(dest, attk_bv)

    # Can only capture opposite coloured pieces
    dest_pc = sq_at(dest).piece
    dest_pc.nil? || king.colour.opposite?(dest_pc.colour)
  end

  def chk_mv_knight(src, dest)
    # Knights move in an "L" shape
    return false unless ((src.x - dest.x).abs + (src.y - dest.y).abs) == 3

    # Can only capture opposite coloured pieces
    knight = sq_at(src).piece
    dest_pc = sq_at(dest).piece

    dest_pc.nil? || knight.colour.opposite?(dest_pc.colour)
  end

  #----------------------------------------------------------------------------
  # Start legal move checks
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Start checkmate detection
  #----------------------------------------------------------------------------
  def checkmate?(clr)
    in_check?(clr) && !has_move?(clr)
  end

  #----------------------------------------------------------------------------
  # End checkmate detection
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Start draw detection
  #----------------------------------------------------------------------------

  def draw?(colour_to_move)
    # fastest check
    return true if @fifty_mv_rule >= 50
    return true if @three_fold_cache.values.any?{|i| i >= 3}

    # Check for only two kings.
    if (@pc_pos[Chess::Piece::KING] == (@clr_pos[Colour::WHITE] | @clr_pos[Colour::BLACK]))
      return true
    end

    # Check for king versus king and bishop
    [Colour::WHITE, Colour::BLACK].each {|colour|
      if (@clr_pos[colour] & @pc_pos[Chess::Piece::KING] == @clr_pos[colour])
        # White has only a king
        if (bit_count(@clr_pos[colour.flip]) == 2)
          if (bit_count(@pc_pos[Chess::Piece::KNIGHT] & @clr_pos[colour.flip]) == 1 ||
                  bit_count(@pc_pos[Chess::Piece::BISHOP] & @clr_pos[colour.flip]) == 1)
            # Only king and knight or bishop left - insufficient material
            return true
          end
        end
      end
    }

    # Check for king and bishop vs. king and bishop with bishop of same colour
    if (bit_count(@clr_pos[Colour::WHITE]) == 2 && bit_count(@clr_pos[Colour::BLACK]) == 2)
      # Each side has only two pieces left - one is the king
      if (bit_count(@pc_pos[Chess::Piece::BISHOP]) == 2)
        # Each side has only a bishop and king left
        w_sq = sq_at(get_coord_for_bv(@clr_pos[Colour::WHITE] & @pc_pos[Chess::Piece::BISHOP]))
        b_sq = sq_at(get_coord_for_bv(@clr_pos[Colour::BLACK] & @pc_pos[Chess::Piece::BISHOP]))
        if (w_sq.colour == b_sq.colour)
          # The bishops are not opposite colours - insufficient material
          return true
        end
      end
    end

    # TODO: This is kinda slow
    # Stalemate
    if (!has_move?(colour_to_move) && !in_check?(colour_to_move))
      return true
    end

    false
  end

  #TODO: You guessed it, this is slow :-p

  def bit_count(bv)
    count = 0
    0.upto(63) {|i|
      count += bv & 0x01
      bv >>= 1
    }
    count
  end

  #----------------------------------------------------------------------------
  # End draw detection
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Start check detection
  #----------------------------------------------------------------------------

  def in_check?(clr)
    bv = @clr_pos[clr] & @pc_pos[Chess::Piece::KING]
    if (bv == 0) 
      raise ArgumentError, "#{clr} king has disappeared.\n#{pp_bv(@clr_pos[clr])}\n#{pp_bv(@pc_pos[Chess::Piece::KING])}\n#{pp_bv(bv)}"
    end
    src = get_coord_for_bv(bv)
    all_dir = [
            Coord::NORTH, Coord::SOUTH, Coord::EAST, Coord::WEST,
                    Coord::NORTHWEST, Coord::NORTHEAST, Coord::SOUTHWEST, Coord::SOUTHEAST
    ]
    cardinal = Coord::NORTH | Coord::SOUTH | Coord::EAST | Coord::WEST
    diagonal = Coord::NORTHEAST | Coord::NORTHWEST | Coord::SOUTHEAST | Coord::SOUTHWEST

    # check for pawns
    pawn_dir = clr.white? ? [Coord::NORTHEAST, Coord::NORTHWEST] : [Coord::SOUTHEAST, Coord::SOUTHWEST]

    pawn_dir.each do |dir|
      sq = sq_at(src.go(dir))
      pc = sq.nil? ? nil : sq.piece
      return true if !pc.nil? && pc.colour.opposite?(clr) && pc.pawn?
    end

    # check for knights
    [src.north.north.west, src.north.north.east, src.north.west.west, src.north.east.east, \
     src.south.south.west, src.south.south.east, src.south.west.west, src.south.east.east].each{|coord|

      sq = sq_at(coord)
      pc = sq.nil? ? nil : sq.piece
      if (!pc.nil? && clr.opposite?(pc.colour) && pc.knight?)
        return true
      end
    }

    all_dir.each do |dir|
      vector = RulesEngine.calc_board_vector(src, dir)
      catch :DIRECTION do
        vector.each_coord do |coord|
          next if coord == src
          pc = sq_at(coord).piece
          next if pc.nil?
          if (!pc.nil?)
            if (pc.colour.opposite?(clr))
              if ((dir & cardinal == dir) && (pc.queen? || pc.rook?))
                return true
              elsif ((dir & diagonal == dir) && (pc.queen? || pc.bishop?))
                return true
              else
                throw :DIRECTION
              end
            else
              throw :DIRECTION
            end
          end
        end
      end
    end

    return false
  end

  def check?(src, attk_bv)
    attacked_calc?(src, attk_bv)
  end
  #----------------------------------------------------------------------------
  # End check detection
  #----------------------------------------------------------------------------

  :private
  def three_fold_hash
    hash = to_txt
    
    # store the queen castling state
    hash += @white_can_castle_kingside.to_s + @white_can_castle_queenside.to_s +
        @black_can_castle_kingside.to_s + @black_can_castle_queenside.to_s
      
    # en passant state (simply the attack vectors for now)
    hash += calculate_colour_attack(Colour::WHITE).to_s
    hash += calculate_colour_attack(Colour::BLACK).to_s

    hash
  end

end
