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
require "move_engine"

class RandomMoveEngine < MoveEngine
  def get_promotion_piece
    num = rand(4)
    case num
    when 0:
      return Chess::Piece::QUEEN
    when 1:
      return Chess::Piece::ROOK
    when 2:
      return Chess::Piece::BISHOP
    end
    return Chess::Piece::KNIGHT
  end

  def get_move(clr, gamestate)
    f = false
    src = nil
    dest = nil
    all_mv = 0

    catch :CHOOSE_PIECE do
      # select random piece
      loop do
        bv = 0x01 << rand(64)
        coord = gamestate.get_coord_for_bv(bv)
        piece = gamestate.sq_at(coord).piece
        if (!piece.nil? && piece.colour == clr)
          mv_bv = gamestate.calculate_all_moves(coord)
          if (mv_bv > 0)
            src = coord
            all_mv = mv_bv
            f = true
          end
        end
        break if f
      end

      f = false

      # select random move                                       ?
      loop do
        bv = 0x01 << rand(64)
        if (bv & all_mv == bv)
          dest = gamestate.get_coord_for_bv(bv)
          if (gamestate.chk_mv(src, dest))
            f = true
          else
            # not the most elegant way, but if we choose a piece that
            # can't move, this should beat deadlocks
            throw :CHOOSE_PIECE
          end
        end
        break if f
      end
      # we shouldn't need this but we do
      if (!gamestate.chk_mv(src, dest))
        throw :CHOOSE_PIECE
      end
    end

    return Move.new(src, dest)
  end
end
