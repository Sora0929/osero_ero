class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new
    if @game.save
      redirect_to @game, notice: '新しいゲームが作成されました！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def move
    @game = Game.find(params[:id])
    row, col = params[:row].to_i, params[:col].to_i
    # 移動のロジックを実装
    if valid_move?(@game, row, col)
      make_move(@game, row, col)
      @game.save
      redirect_to @game
    else
      flash[:error] = "Invalid move!"
      redirect_to @game
    end
  end

  private

  def valid_move?(game, row, col)
    board = game.board_as_array

    # 1. マスが範囲外、またはすでに埋まっている場合は無効
    return false if row < 0 || col < 0 || row >= 8 || col >= 8 || board[row][col]

    # 2. 各方向に駒を挟む形があるか確認
    directions = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]]

    directions.any? do |dr, dc|
      valid_in_direction?(board, row, col, dr, dc, game.current_player)
    end
    # 移動が有効かどうかを判定するロジック
  end

  def valid_in_direction?(board, row, col, dr, dc, player)
    other_player = player == 'black' ? 'white' : 'black'
    row += dr
    col += dc
    found_other = false
  
    while row >= 0 && col >= 0 && row < 8 && col < 8
      if board[row][col] == other_player
        found_other = true
      elsif board[row][col] == player
        return found_other # 挟む形が成立
      else
        return false # 空のマスがあれば無効
      end
      row += dr
      col += dc
    end
    false
  end

  def make_move(game, row, col)
    board = game.board_as_array
    board[row][col] = game.current_player # 指定されたマスに駒を置く
  
    # 8方向に対して駒をひっくり返す処理を実行
    directions = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]]
    directions.each do |dr, dc|
      flip_pieces_in_direction(board, row, col, dr, dc, game.current_player)
    end
  
    # 更新されたボードを保存
    game.board = board
  end

  def flip_pieces_in_direction(board, row, col, dr, dc, player)
    other_player = player == 'black' ? 'white' : 'black'
    positions_to_flip = []
    row += dr
    col += dc
  
    while row >= 0 && col >= 0 && row < 8 && col < 8
      if board[row][col] == other_player
        positions_to_flip << [row, col] # ひっくり返す候補として保存
      elsif board[row][col] == player
        positions_to_flip.each { |r, c| board[r][c] = player } # 自分の駒にする
        return
      else
        break # 空のマスがあれば中断
      end
      row += dr
      col += dc
    end
  end
end
  