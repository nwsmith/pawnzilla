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

# This is a simple stub to allow the game to be played via the
# xboard interface

require "rule_std"
require "geometry"

module Network

    class Client
        @engine
        @move_cnt

        def initialize()
            @engine = GameState.new
            @move_cnt = 0
        end

        def send_move(move) 
            src  = Coord.from_alg(move[0].chr, move[1].chr)
            dest = Coord.from_alg(move[2].chr, move[3].chr)

            if (@engine.move?(src, dest))
                @engine.move_piece(src, dest)
                true
            else
                false
            end
        end

        def recieve_move()
            moves = [
                "a7a6",
                "b7b6",
                "c7c6",
                "d7d6",
                "e7e6",
                "f7f6",
                "g7g6",
                "a6a5",
                "b6b5",
                "c6c5",
                "d6d5",
                "e6e5",
                "f6f5",
                "g6g5",
                "a5a7",
                "b5b7",
                "c5c7",
                "d5d7",
                "e5e7",
                "f5f7",
                "g5g7"
            ]

            compMove = moves[@move_cnt]
            @move_cnt = @move_cnt + 1
            
            src  = Coord.from_alg(compMove[0].chr + compMove[1].chr)
            dest = Coord.from_alg(compMove[2].chr + compMove[3].chr)
            @engine.move_piece(src, dest)
            return compMove
        end
    end
end
