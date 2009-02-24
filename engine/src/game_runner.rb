class GameRunner
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
    return @rules_engine.checkmate?(Colour::WHITE) || @rules_engine.checkmate?(Colour::BLACK) || @rules_engine.draw?
  end
  
  def next_move
    return @next_move if !@next_move.nil?
    @next_move = @move_engine[@to_move].get_move(@to_move, @rules_engine)
    @next_move    
  end
    
  def move    
    move = next_move
    @rules_engine.move!(move.src, move.dest)
    if (@rules_engine.can_promote?(@to_move))
      @rules_engine.promote!(move.dest, @move_engine[@to_move].get_promotion_piece)
    end
    @to_move = @to_move.flip
    @next_move = nil
    move
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
    return nil if @rules_engine.draw?
  end
  
  
end
