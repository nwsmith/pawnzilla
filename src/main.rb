#
#   $Id$
#
#   Copyright 2005, 2006 Nathan Smith, Sheldon Fuchs, Ron Thomas
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
require "rule_std"

puts "Pawnzilla game."
puts
puts "Copyright 2005 - Nathan Smith, Sheldon Fuchs, Ron Thomas"
puts

e = Rule_Std::Engine.new();

# Main Game Loop
num_mv = 1

loop do

    puts e.state.to_txt
    puts
    clr = (num_mv & 1 == 1) ? "White" : "Black" 
    print "Enter move #{num_mv} for #{clr}: "
    $stdout.flush
    mv = gets
    mv.chop!
    
    break if !(mv[/^q$/i].nil?)
   
    puts
    src = Rule_Std::AlgCoord.new(mv[0].chr, mv[1].chr.to_i)
    dest = Rule_Std::AlgCoord.new(mv[2].chr, mv[3].chr.to_i)
    
    if (e.move?(src, dest)) 
        e.move(src, dest)
        num_mv += 1
        puts
        puts        
        next
    end
    
    puts "#{mv} is not a legal move.  Try again, beeyotch."    
    puts
end

puts "Thanks for the playing"
