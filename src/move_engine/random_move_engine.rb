require "move_engine"

class RandomMoveEngine < MoveEngine
  def get_move(clr, gamestate) 
    f = false
    src = nil
    dest = nil
    all_mv = 0
    
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
    
    # select random move
    loop do
      bv = 0x01 << rand(64)
      if (bv & all_mv == bv)
        dest = gamestate.get_coord_for_bv(bv)
        f = true
      end
      break if f
    end
    
    return Move.new(src, dest)
  end
end
