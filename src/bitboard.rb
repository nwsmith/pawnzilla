#
#   $Id: src_tmpl.rb 160 2006-08-07 04:39:47Z nwsmith $
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
class Bitboard
    attr :bv
    
    def initialize(bv)
        @bv = bv
    end    
    
    def to_i
        return @bv
    end
    
    def >>(sw) 
        return @bv >> sw
    end
    
    def <<(sw)
        return @bv << sw
    end
    
    def [](index)
        return @bv[index]
    end
    
    def ^(bv) 
        return @bv ^ bv
    end
    
    def &(bv) 
        return @bv & bv
    end
    
    def to_s
		out = ""
		63.downto(0) do |i|
			out += @bv[i].to_s
			out += " " if (i % 8 == 0)						 
		end
		out.chop    
    end
end
