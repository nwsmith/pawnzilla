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
