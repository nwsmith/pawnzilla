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
