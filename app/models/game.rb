class Game < ApplicationRecord
  after_initialize :setup_board, if: :new_record?
  # attribute :board, :array, default: -> { Array.new(8) { Array.new(8, nil) } }
  serialize :board, Array
  
  def setup_board
    self.board = Array.new(8) { Array.new(8, nil) } # 8x8 のボード
    self.board[3][3] = 'white'
    self.board[3][4] = 'black'
    self.board[4][3] = 'black'
    self.board[4][4] = 'white'
    self.current_player = 'black' # 最初のプレイヤー
  end

  # ボードを2次元配列に変換
  def board_as_array
    JSON.parse(board || '[]')
  end

  # ボードを保存用のJSONに変換
  def board=(value)
    super(value.to_json)
  end

  # 次のプレイヤーに切り替える
  def switch_player
    self.current_player = current_player == 'black' ? 'white' : 'black'
  end
  
  def to_s
    board.map { |row| row.map { |cell| cell || '.' }.join(' ') }.join("\n")
  end
end