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
require "chess"
require "geometry"
require "game"

module Rule_Std
    B_SZ = 8
    MIN_FILE = 'a'
    MAX_FILE = 'h'
    MIN_RANK = 1
    MAX_RANK = 8
    
    class Engine      
        attr_accessor :state 
        :pc_val
          
        def initialize 
            @pc_val = {
                Chess::Piece::BISHOP => PieceInfo.new(3.5, method(:chk_mv_bishop)),
                Chess::Piece::KING => PieceInfo.new(1_000_000, method(:chk_mv_king)),
                Chess::Piece::KNIGHT => PieceInfo.new(3.5, method(:chk_mv_knight)),
                Chess::Piece::PAWN => PieceInfo.new(1, method(:chk_mv_pawn)),
                Chess::Piece::QUEEN => PieceInfo.new(9, method(:chk_mv_queen)),
                Chess::Piece::ROOK => PieceInfo.new(5, method(:chk_mv_rook))
            }
        
            @state = Game::State.new(B_SZ)
            
            clr = Chess::Colour::WHITE

            # Pawn Rows
            [1, 6].each do |y|
                (0...B_SZ).each do |x|
                    state.place_piece(Coord.new(x, y),
                        Chess::Piece.new(clr, Chess::Piece::PAWN))
                end
                
                clr = clr.flip
            end
            
            # Back Rows                        
            bck_row = [Chess::Piece::ROOK, Chess::Piece::KNIGHT, Chess::Piece::BISHOP, Chess::Piece::QUEEN, 
                       Chess::Piece::KING, Chess::Piece::BISHOP, Chess::Piece::KNIGHT, Chess::Piece::ROOK]
            
            [0, 7].each do |y|
                bck_row.each_index do |x|
                    state.place_piece(Coord.new(x, y),
                        Chess::Piece.new(clr, bck_row[x]))
                end
                
                clr = clr.flip
            end
        end
        
        def move?(src, dest)
            chk_mv(src.to_coord, dest.to_coord)
        end
                
        def Engine.coord_to_alg(coord)
            Rule_Std::AlgCoord.new((97 + coord.x).chr, (coord.y + 1))
        end
        
        def chk_mv(src, dest) 
            pc = @state.board.sq_at(src).piece
            
            if pc.nil?
                return false
            end
            
            fp = @pc_val[pc.name].function;
            fp.call(src, dest, @state);
        end
        
        def chk_mv_pawn(src, dest, state)
            pc_src = state.board.sq_at(src).piece
            pc_dest = state.board.sq_at(dest).piece        
        
            # no matter what, the pawn has to move forward
            dst = dest.y - src.y
            
            # in the coordinate system, a forward move is a reduction in y for black
            dst = -dst if pc_src.colour.black?
           
            return false unless dst > 0           

            # no matter what, the pawn can only stay on the same rank or ONE either way            
            return false unless ((src.x - 1)..(src.x + 1)) === dest.x
            
            # pawns can move one square forward except for first move
            # I'm not a fan of this, but it works for now:
            at_strt = (pc_src.colour.white? ? src.y == 1 : src.y == 6)
            if at_strt && ![1,2].include?(dst) || !at_strt && dst != 1
                return false
            end
           
            if dst == 1 && [src.x + 1, src.x - 1].include?(dest.x)
                # it's a diagonal move, ensure it's a capture
                return false unless !pc_dest.nil? && pc_dest.colour.opposite?(pc_src.colour)
            else 
                # it's a straight move, ensure it's not blocked                                
                return false if !pc_dest.nil? || state.blocked?(src, dest)
            end
            
            true
        end        
        
        def chk_mv_bishop(src, dest, state) 
            # Bishops can only move diagonally and cannot jump pieces
            return false unless src.on_diag?(dest) && !state.blocked?(src, dest)    
            
            # If a piece is on the dest square, make sure it's a capture.
            pc_dest = state.board.sq_at(dest).piece
            pc_src = state.board.sq_at(src).piece
            
            (!pc_dest.nil? && !pc_src.color.opposite?(pc_dest.color)) || true
        end
        
        def chk_mv_rook(src, dest, state) 
            return false unless (src.on_rank?(dest) || src.on_file?(dest)) && !state.blocked?(src, dest)
            
            # If a piece is on the dest square, make sure it's a capture.
            pc_dest = state.board.sq_at(dest).piece
            pc_src = state.board.sq_at(src).piece
            
            (!pc_dest.nil? && !pc_src.color.opposite?(pc_dest.color)) || true            
        end
        
        def chk_mv_queen(src, dest, state)
            chk_mv_bishop(src, dest, state) || chk_mv_rook(src, dest, state)
        end
        
        def chk_mv_king(src, dest, state)
            l = Line.new(src, dest)
            
            # Kings can only move one square
            return false unless l.len == 1
            
            # Can only capture opposite coloured pieces
            king = state.board.sq_at(src).piece
            dest_pc = state.board.sq_at(dest).piece
            
            (!dest_pc.nil? && !king.color.opposite?(dest_pc.color)) || true
        end
        
        def chk_mv_knight(src, dest, state)
            # Knights move in an "L" shape
            return false unless ((src.x - dest.x).abs + (src.y - dest.y).abs) == 3

            # Can only capture opposite coloured pieces
            knight = state.board.sq_at(src).piece
            dest_pc = state.board.sq_at(dest).piece
            
            (!dest_pc.nil? && !knight.color.opposite?(dest_pc.color)) || true
        end
    end
    
    class AlgCoord
        attr_accessor :file
        attr_accessor :rank
        
        def initialize(file, rank)
            unless (MIN_FILE..MAX_FILE) === file
                raise ArgumentException, "Illegal Alpha"
            end
            @file = file
 
            unless (MIN_RANK..MAX_RANK) === rank           
                raise ArgumentException, "Illegal Numeric"
            end            
            @rank = rank
        end
        
        def ==(c)
            (@file == c.file && @rank == c.rank)
        end
        
        def to_coord
            Coord.new(@file[0] - 97, @rank - 1)            
        end
    end
    
    class PieceInfo
        attr_accessor :value
        attr_accessor :function
        
        def initialize(value, function)
            @value = value
            @function = function
        end
    end

end
