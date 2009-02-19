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

    # select random piece
    loop do
      if (gamestate.in_check?(clr))
        # Have to move out of check
        bv = gamestate.clr_pos[clr] & gamestate.pos[Chess::Piece::KING]
      else
        bv = 0x01 << rand(64)
      end
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
    # TODO: cache rejected illegal moves to prevent lockups
    tried_moves = []
    loop do
      bv = 0x01 << rand(64)
      next if tried_moves.include?(bv)
      tried_moves.push(bv)
      if (bv & all_mv == bv)
        dest = gamestate.get_coord_for_bv(bv)
        if (gamestate.chk_mv(src, dest))
          f = true
        end
      end
      break if f
    end

    return Move.new(src, dest)
  end
end
