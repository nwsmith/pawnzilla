class GameRunner
  attr_reader(:rules_engine)
  
  def initialize(white_move_engine, black_move_engine)
    @white_move_engine = white_move_engine
    @black_move_engine = black_move_engine
    @rules_engine = RulesEngine.new()
    @to_move = Colour::WHITE
    @next_move
  end
  
  def game_is_over
    return @rules_engine.checkmate?(Colour::WHITE) || \
      @rules_engine.checkmate?(Colour::BLACK)
  end
  
  def next_move
    return @next_move if !@next_move.nil?
    @next_move = @to_move.white? \
      ? @white_move_engine.get_move(@to_move, @rules_engine) \
      : @black_move_engine.get_move(@to_move, @rules_engine)
    @next_move    
  end
    
  def move    
    move = next_move
    @rules_engine.move!(move.src, move.dest)
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
  
  
end
