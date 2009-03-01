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
class GameRunner
  MAX_ATTEMPTS = 16
  attr_reader(:rules_engine, :to_move)

  def initialize(white_move_engine, black_move_engine)
    @move_engine = {
            Colour::WHITE => white_move_engine,
            Colour::BLACK => black_move_engine
    }
    @rules_engine = RulesEngine.new()
    @to_move = Colour::WHITE
    @next_move
  end

  def game_is_over
    return @rules_engine.checkmate?(Colour::WHITE) || @rules_engine.checkmate?(Colour::BLACK) || @rules_engine.draw?(@to_move)
  end

  def next_move
    return @next_move if !@next_move.nil?

    i, moves, current_move = 0, [], nil
    loop do 
      current_move = @move_engine[@to_move].get_move(@to_move, @rules_engine)
      break if @rules_engine.chk_mv(current_move.src, current_move.dest)
      moves.push(current_move)
      i += 1
      if (i > MAX_ATTEMPTS)
        err_msg = "Tried #{MAX_ATTEMPTS} times to find legal move.  Candidate were:\n "
        moves.each {|mv|  err_msg += "#{mv.src.to_alg}-#{mv.dest.to_alg}\n"}
        raise ArgumentError, err_msg
      end
    end
    @next_move = current_move
    @next_move
  end

  def move
    current_move = next_move

    @rules_engine.move!(current_move.src, current_move.dest)
    if (@rules_engine.can_promote?(@to_move))
      @rules_engine.promote!(current_move.dest, @move_engine[@to_move].get_promotion_piece)
    end
    @to_move = @to_move.flip
    @next_move = nil
    current_move
  end

  def move_list
    @rules_engine.move_list
  end

  def to_move
    @to_move
  end

  def winner
    return nil unless game_is_over
    return Colour::BLACK if @rules_engine.checkmate?(Colour::WHITE)
    return Colour::WHITE if @rules_engine.checkmate?(Colour::BLACK)
    return nil if @rules_engine.draw?(@to_move)
  end


end
