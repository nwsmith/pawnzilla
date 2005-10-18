#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs
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
module ChessPiece
    class ChessPiece
        attr_reader :color
        attr_reader :value
        attr_reader :name
        :state

        def initialize(color, value, name)
            @color = color
            @value = value
            @name = name
            @state = PieceState.new
        end
    end

    class PieceState
        attr_accessor :moved
        attr_accessor :captured

        def initialize 
            @moved = false
            @captured = false
        end

        def is_moved?
            return @moved
        end

        def is_captured?
            return @captured
        end
    end
end
