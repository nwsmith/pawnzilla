require "move_engine"

class HumanMoveEngine < MoveEngine
  def get_move(clr, gamestate) 
    print "Enter move: " 
    $stdout.flush
    mv = gets
    mv.chomp!
    mv.downcase!
    
    src = Coord.from_alg(mv[0].chr + mv[1].chr)
    dest = Coord.from_alg(mv[2].chr + mv[3].chr)
    
    return Move.new(src, dest)
  end
end
