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
module Move
    class MoveNode
        attr_accessor :white_ply
        attr_accessor :black_ply
        attr_accessor :next

        :children

        def initialize
            @children = Array.new()
        end

        def add_child(node)
            @children.append(node)
        end
    end

    class Ply
        attr_reader :source
        attr_reader :destination

        def initialize(source, destination)
            @source = source
            @destination = destination
        end
    end
end
