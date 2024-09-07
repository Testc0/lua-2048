io.stdout:setvbuf("no")

local board = {}
local score = 0
local game_state
local can_move = false

local tile_textures = {}

function love.load()
  local i = 2
  while i <= 2048 do
    tile_textures[i] = love.graphics.newImage(i..".png")
    i = i * 2
  end
  loadGame()
end

function love.update(dt)
  local fallback_num = math.random(1, 1000)
  math.randomseed(fallback_num)
  game_state = getGameState()
end

function love.draw()
  love.graphics.print("Score: "..score)
  for i, row in ipairs(board) do
    for j, tile in ipairs(row) do
      love.graphics.rectangle("line", j * 76, i * 76, 76, 76)
      if tile > 0 then
        love.graphics.draw(tile_textures[tile], j * 76, i * 76, 0, 0.75, 0.75)
      end
    end
  end
  if game_state == "won" or game_state == "lost" then
    love.graphics.print("You "..game_state.."!", 200, 30)
    love.graphics.print("Press R to restart", 175, 50)
  end
end

function love.keypressed(key)
  if key == "r" then
    loadGame()
  elseif key == "left" then
    moveLeft()
  elseif key == "right" then
    moveRight()
  elseif key == "up" then
    moveUp()
  elseif key == "down" then
    moveDown()
  end
end

function loadGame()
  board = getEmptyBoard()
  score = 0
  randGenTiles()
  randGenTiles()
end

function randGenTiles()
  local gen_four_chance = math.random(1, 10)
  local rand_row = math.random(1, 4)
  local rand_col = math.random(1, 4)
  while board[rand_row][rand_col] > 0 do
    rand_row = math.random(1, 4)
    rand_col = math.random(1, 4)
  end
  if gen_four_chance == 10 then
    board[rand_row][rand_col] = 4
  else
    board[rand_row][rand_col] = 2
  end
end

function getGameState()
  for i, row in ipairs(board) do
    for j, tile in ipairs(row) do
      if tile == 2048 then
        return "won"
      elseif tile == 0 then
        return "ongoing" 
      elseif i < 4 and j < 4 then
        if board[i][4] == board[i + 1][4] 
        or board[4][j] == board[4][j + 1]
        or tile == board[i + 1][j] 
        or tile == board[i][j + 1] then
          return "ongoing"
        end
      end
    end
  end
  return "lost"
end

function compressLeft()
  local new_board = getEmptyBoard()
  local pos
  for i, row in ipairs(board) do
    pos = 1
    for j, tile in ipairs(row) do
      if tile > 0 then
        new_board[i][pos] = tile
        if not (j == pos) then
          can_move = true
        end
        pos = pos + 1
      end
    end
  end
  board = new_board
end

function mergeLeft()
  for i = 1, 4, 1 do
    for j = 1, 3, 1 do
      if board[i][j] == board[i][j + 1] and board[i][j] > 0 then
        board[i][j] = board[i][j] * 2
        board[i][j + 1] = 0
        score = score + board[i][j]
        can_move = true
      end
    end
  end
end

function reverseBoard()
  local new_board = getEmptyBoard()
  for i = 1, 4, 1 do
    for j = 1, 4, 1 do
      new_board[i][j] = board[i][5 - j]
    end
  end
  board = new_board
end

function transposeBoard()
  local new_board = getEmptyBoard()
  for i = 1, 4, 1 do
    for j = 1, 4, 1 do
      new_board[i][j] = board[j][i]
    end
  end
  board = new_board
end

function moveLeft()
  compressLeft()
  mergeLeft()
  compressLeft()
  if can_move then
    randGenTiles()
  end
  can_move = false
end

function moveRight()
  reverseBoard()
  moveLeft()
  reverseBoard()
end

function moveUp()
  transposeBoard()
  moveLeft()
  transposeBoard()
end

function moveDown()
  transposeBoard()
  moveRight()
  transposeBoard()
end

function getEmptyBoard()
  local empty_board = {}
  for i = 1, 4, 1 do
    empty_board[i] = {}
    for j = 1, 4, 1 do
      empty_board[i][j] = 0
    end
  end
  return empty_board
end
