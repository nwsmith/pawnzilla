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
    white_was_in_check = @gamerunner.rules_engine.check?(Colour::WHITE)
    black_was_in_check = @gamerunner.rules_engine.check?(Colour::BLACK)
    
    move = @gamerunner.next_move
    src_pc = @gamerunner.rules_engine.sq_at(move.src).piece
    @gamerunner.move
    
    curr_pos = @gamerunner.rules_engine.to_txt
    
    # Check one: make sure that the piece moving didn't disappear.  This 
    # generally happens with bugs in chk_mv
    dest_pc = @gamerunner.rules_engine.sq_at(move.dest).piece
    if (dest_pc.nil?)
      err_ms = "#{src_pc.name} has disappeared!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    # Check two: kings just disappear sometimes, usually to illegal captures
    e = @gamerunner.rules_engine
    if ((e.clr_pos[Colour::WHITE] & e.pos[Chess::Piece::KING]) == 0 || \
        (e.clr_pos[Colour::BLACK] & e.pos[Chess::Piece::KING]) == 0) 
      err_ms = "King has disappeared!\n"
      err_ms += "Move: #{move.src.to_alg} - #{move.dest.to_alg}\n"
      err_ms += "Before move:\n#{prev_pos}\n"
      err_ms += "After move:\n#{curr_pos}\n"
      raise ArgumentError, err_ms
    end
    
    #Check three: king did not get out of check
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
  end  
end
