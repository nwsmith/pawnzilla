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
$:.unshift File.join(File.dirname(__FILE__), "..", "test")
require "geometry/coord"
require "rules_engine"
require "move"
require "move_engine/human_move_engine"
require "move_engine/random_move_engine"
require "game_runner"
require "game_monitor"

  # creates a alg coord notation for an index in a bv
  def get_alg_coord_notation(i)
    x = i % 8
    y = 8 - ((i - x) / 8)
 
    (97 + x).chr + y.to_s
  end
 
  def process_board_string(board_string)
    board_string.gsub(/\s+/, "")
  end

  
  # Takes a processed board and renders it in a more readable form
  def format_board(board_string)
    board_string[0..7]   + "\n" +
    board_string[8..15]  + "\n" +
    board_string[16..23] + "\n" +
    board_string[24..31] + "\n" +
    board_string[32..39] + "\n" +
    board_string[40..47] + "\n" +
    board_string[48..55] + "\n" +
    board_string[56..63] + "\n" +
    ""
  end


puts "Pawnzilla game."
puts ""
puts "Copyright 2005 - 2009 - Nathan Smith, Ron Thomas, Sheldon Fuchs"
puts ""

#e = RulesEngine.new
#move_list = []
  white_move_engine = RandomMoveEngine.new
  black_move_engine = RandomMoveEngine.new
  runner = GameRunner.new(white_move_engine, black_move_engine)
  monitor = GameMonitor.new(runner)
  err_cnt = 0
  max_run = 10
  verbose = false
  tr = PieceTranslator.new

# Main Game Loop
1.upto(max_run) do |run_count|
  puts "start game #{run_count}"
  move_count = 0;
  loop do
    puts monitor.gamerunner.rules_engine.to_txt if verbose
    puts "" if verbose
    move = nil
    begin
      if (monitor.gamerunner.game_is_over)
        winner = runner.winner
        if (winner.nil?)
          puts "A Draw!" if verbose
        else
          puts "#{winner.colour} wins!" if verbose
        end
        white_move_engine = RandomMoveEngine.new
        black_move_engine = RandomMoveEngine.new
        monitor.gamerunner = GameRunner.new(white_move_engine, black_move_engine)
        break
      end  
      move = monitor.move
      move_count += 1
      puts "#{move_count}: #{move.src.to_alg}-#{move.dest.to_alg}" if verbose
    rescue Exception => e
      puts "Crash on run #{run_count}"
      puts "Move: #{move.src.to_alg}-#{move.dest.to_alg}" unless move.nil?
      trace = "caught #{e.class} : #{e.message}\n"
      e.backtrace.each do |line|
        trace += line + "\n"  
      end
      trace += "\n"
      trace += "#{monitor.gamerunner.move_list.size} total plies\n"
      trace += monitor.gamerunner.rules_engine.to_txt
      trace += "\n"
      trace += "------ for testing -----\n\n"
      trace += "e = RulesEngine.new\n"
      trace += "place_pieces(e, \"\n"
      gamestate_state = ""
      0.upto(63) do |i| 
        square = monitor.gamerunner.rules_engine.sq_at(Coord.from_alg(get_alg_coord_notation(i)))
        gamestate_state += square.piece.nil? ? "-" : tr.to_txt(square.piece)
      end
      trace += format_board(gamestate_state)
      trace += "\")\n"
      trace += "white_move_engine = TestMoveEngine.new\n";
      trace += "black_move_engine = TestMoveEngine.new\n";
      monitor.gamerunner.move_list.each_index do |i|
        move = monitor.gamerunner.move_list[i]
        if (i % 2 == 0) 
          trace += "white_move_engine.add_move("
        else 
          trace += "black_move_engine.add_move("
        end
        trace += "Move.new(Coord.from_alg(\"#{move.src.to_alg}\"), Coord.from_alg(\"#{move.dest.to_alg}\")))\n"
      end
      trace += "runner = TestGameRunner.new(white_move_engine, black_move_engine)\n"
      trace += "runner.replay\n"
      trace += "#assertions here\n"
      err_cnt += 1
      filename = "/tmp/pz_err_" + err_cnt.to_s
      File.open(filename, 'w') {|f| f.write(trace)}
      white_move_engine = RandomMoveEngine.new
      black_move_engine = RandomMoveEngine.new
      runner = GameRunner.new(white_move_engine, black_move_engine)
      monitor = GameMonitor.new(runner)
      break
    end
  end
end

puts "There were #{err_cnt} crashes in #{max_run} games"
puts "Thanks for the playing"
