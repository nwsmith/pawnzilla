#
# $Id$
#
# Copyright 2005, 2006 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "geometry"
require "gamestate"
require "move"

puts "Pawnzilla game."
puts
puts "Copyright 2005 - Nathan Smith, Sheldon Fuchs, Ron Thomas"
puts

e = GameState.new
move_list = []

# Main Game Loop
loop do
  mv_cnt = move_list.length + 1
  puts e.to_txt
  puts
  clr = (mv_cnt & 1 == 1) ? "White" : "Black" 
  print "Enter move #{mv_cnt} for #{clr}: "
  $stdout.flush
  mv = gets
  mv.chop!
  mv.downcase!
  
  if (mv == 'undo' || mv == 'u') 
    move_list.pop.undo(e)
    puts "Undoing last move."
    next
  end

  if (mv == 'moves' || mv == 'm') 
    cnt = 1
    move_list.each_index do |i|
      print "#{cnt}. " if i % 2 == 0
      print "#{move_list[i].to_s} "
      if (i % 2 == 1)
        puts "\n"
        cnt += cnt
      end 
    end
    puts "\n"
    next
  end
   
  break if (mv == 'quit' || mv == 'q' || mv == 'exit' || mv == 'x') 
   
  puts
  src = Coord.from_alg(mv[0].chr + mv[1].chr)
  dest = Coord.from_alg(mv[2].chr + mv[3].chr)
  
  if (e.move?(src, dest)) 
    move_list.push(Move.execute(src, dest, e))
    puts
    puts    
    next
  end
  
  puts "#{mv} is not a legal move.  Try again, beeyotch."    
  puts
end

puts "Thanks for the playing"
