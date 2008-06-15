#
#   $Id: src_tmpl.rb 228 2008-03-04 19:50:17Z nwsmith $
#
#   Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
class GameMonitor
  attr_accessor :gamerunner
  
  @gamerunner
  
  def initialize(gamerunner)
    @gamerunner = gamerunner
  end
  
  def move
    prev_pos = @gamerunner.rules_engine.to_txt
    all_pieces_prev = []
    0.upto(7) do |x|
      0.upto(7) do |y|
        all_pieces_prev.push(@gamerunner.rules_engine.sq_at(Coord.new(x, y)))
      end      
    end
    
    white_was_in_check = @gamerunner.rules_engine.check?(Colour::WHITE)
    black_was_in_check = @gamerunner.rules_engine.check?(Colour::BLACK)
    
    move = @gamerunner.next_move
    src_sq = @gamerunner.rules_engine.sq_at(move.src)
    dest_sq = @gamerunner.rules_engine.sq_at(move.dest)
    src_pc = @gamerunner.rules_engine.sq_at(move.src).piece
    @gamerunner.move
    
    all_pieces_curr = []
    0.upto(7) do |x|
      0.upto(7) do |y|
        all_pieces_curr.push(@gamerunner.rules_engine.sq_at(Coord.new(x, y)))
      end
    end
    
    curr_pos = @gamerunner.rules_engine.to_txt
    
    # Check one: make sure pieces aren't drifting
    all_pieces_prev.each_index do |i|
      square = all_pieces_prev[i]
      if (!(square == src_sq || square == dest_sq))
        if (square != all_pieces_curr[i])
          err_ms = "square == src: #{square == src_sq}\n"
          err_ms += "square == dest: #{square == src_dest}"
          err_ms += "previous: #{square}"
          err_ms += "current: #{all_pieces_curr[i]}"
          err_ms += "move from: #{src_sq}"
          err_ms += "move to: #{dest_sq}"

          err_ms = "#{src_pc.name} has drifted!\n";
          err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
          err_ms += "Before move:\n#{prev_pos}\n"
          err_ms += "After move:\n#{curr_pos}\n"
          raise ArgumentError, err_ms
        end
      end
    end
    
    # Check two: make sure that the piece moving didn't disappear.  This 
    # generally happens with bugs in chk_mv
    dest_pc = @gamerunner.rules_engine.sq_at(move.dest).piece
    if (dest_pc.nil?)
      err_ms = "#{src_pc.name} has disappeared!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    # Check three: make sure the piece moved where it was supposed to move.
    dest_pc = @gamerunner.rules_engine.sq_at(move.dest).piece
    if (src_pc != dest_pc)
      err_ms = "#{src_pc.name} was the source piece, "
      err_ms += " but #{dest_pc.name} was the destination piece.\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    # Check four: kings just disappear sometimes, usually to illegal captures
    e = @gamerunner.rules_engine
    if ((e.clr_pos[Colour::WHITE] & e.pos[Chess::Piece::KING]) == 0 || \
        (e.clr_pos[Colour::BLACK] & e.pos[Chess::Piece::KING]) == 0) 
      err_ms = "King has disappeared!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    #Check five: king did not get out of check
    white_is_in_check = e.check?(Colour::WHITE)
    black_is_in_check = e.check?(Colour::BLACK)

    if ((white_was_in_check && white_is_in_check) || \
          (black_was_in_check && black_is_in_check)) 
      err_ms = "King did not move out of check!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    #Check six: move did not result in king being in check
    to_move = @gamerunner.to_move
    
    if ((to_move == Colour::BLACK && (!white_was_in_check && white_is_in_check)) || \
        (to_move == Colour::WHITE && (!black_was_in_check && black_is_in_check)))
      err_ms = "King moved into check!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms      
    end
    
    move
  end  
end
