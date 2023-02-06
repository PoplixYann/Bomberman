local audio = require("audio")
local grid = require("multi/grid")
local animation = require("animation")

local data
local bombList
local playerBombList

--Initialize bombs
local function initBombs()
  data.images = {}
  data.images.bomb = love.graphics.newImage('Assets/Images/Bomb.png')
  data.images.explosion = love.graphics.newImage("Assets/Images/Explosion.png")
end

--Get BombId in playerBombList
local function getBombId(bomb)
  for bombId, bombi in ipairs(playerBombList[bomb.playerId]) do
    if (bombi == bomb) then
      return bombId
    end
  end
end

--Explosing Function
local function bombExplose(bomb)
  local bombLine, bombColumn = bomb.line, bomb.column
  local bombSize = bomb.size
  local map = grid.getMap()
  local waitingBombList = {}

  for line = bombLine-1, bombLine-bombSize, -1 do
    local column = bombColumn
    if (grid.cellIsAvailable(line, column)) then
      if (map[line][column].index == 1 or map[line][column].index == 2) then
        if (map[line][column].index == 2) then
          grid.setCellInfo(line, column, "collide", false)
          grid.setCellInfo(line, column, "playAnim", true)
        end
        break
      else
        if (map[line][column].bomb) then
          table.insert(waitingBombList, {line = line, column = column})
          break
        end
        if (grid.getCellInfo(line, column, "explose") == false) then
          if (line == bombLine-bombSize) then
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 50, 50, 50))
          else
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 100, 50, 50))
          end
          grid.setCellInfo(line, column, "exploDir", "verticale")
        elseif(grid.getCellInfo(line, column, "explose") == true and grid.getCellInfo(line, column, "exploDir") ~= "verticale") then
          grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
        else
          animation.reset(grid.getCellInfo(line, column, "animation"))
        end
        grid.setCellInfo(line, column, "playAnim", true)
        grid.setCellInfo(line, column, "explose", true)
      end
    else break
    end
  end
  for line = bombLine+1, bombLine+bombSize do
    local column = bombColumn
    if (grid.cellIsAvailable(line, column)) then
      if (map[line][column].index == 1 or map[line][column].index == 2) then
        if (map[line][column].index == 2) then
          grid.setCellInfo(line, column, "collide", false)
          grid.setCellInfo(line, column, "playAnim", true)
        end
        break
      else
        if (map[line][column].bomb) then
          table.insert(waitingBombList, {line = line, column = column})
          break
        end
        if (grid.getCellInfo(line, column, "explose") == false) then
          if (line == bombLine+bombSize) then
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 150, 50, 50))
          else
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 200, 50, 50))
          end
          grid.setCellInfo(line, column, "exploDir", "verticale")
        elseif(grid.getCellInfo(line, column, "explose") == true and grid.getCellInfo(line, column, "exploDir") ~= "verticale") then
          grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
        else
          animation.reset(grid.getCellInfo(line, column, "animation"))
        end
        grid.setCellInfo(line, column, "playAnim", true)
        grid.setCellInfo(line, column, "explose", true)
      end
    else break
    end
  end
  for column = bombColumn-1, bombColumn-bombSize, -1 do
    local line = bombLine
    if (grid.cellIsAvailable(line, column)) then
      if (map[line][column].index == 1 or map[line][column].index == 2) then
        if (map[line][column].index == 2) then
          grid.setCellInfo(line, column, "collide", false)
          grid.setCellInfo(line, column, "playAnim", true)
        end
        break
      else
        if (map[line][column].bomb) then
          table.insert(waitingBombList, {line = line, column = column})
          break
        end
        if (grid.getCellInfo(line, column, "explose") == false) then
          if (column == bombColumn-bombSize) then
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 250, 50, 50))
          else
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 300, 50, 50))
          end
          grid.setCellInfo(line, column, "exploDir", "horizontale")
        elseif(grid.getCellInfo(line, column, "explose") == true and grid.getCellInfo(line, column, "exploDir") ~= "horizontale") then
          grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
        else
          animation.reset(grid.getCellInfo(line, column, "animation"))
        end
        grid.setCellInfo(line, column, "playAnim", true)
        grid.setCellInfo(line, column, "explose", true)
      end
    else break
    end
  end
  for column = bombColumn+1, bombColumn+bombSize do
    local line = bombLine
    if (grid.cellIsAvailable(line, column)) then
      if (map[line][column].index == 1 or map[line][column].index == 2) then
        if (map[line][column].index == 2) then
          grid.setCellInfo(line, column, "collide", false)
          grid.setCellInfo(line, column, "playAnim", true)
        end
        break
      else
        if (map[line][column].bomb) then
          table.insert(waitingBombList, {line = line, column = column})
          break
        end
        if (grid.getCellInfo(line, column, "explose") == false) then
          if (column == bombColumn+bombSize) then
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 350, 50, 50))
          else
            grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 400, 50, 50))
          end
          grid.setCellInfo(line, column, "exploDir", "horizontale")
        elseif(grid.getCellInfo(line, column, "explose") == true and grid.getCellInfo(line, column, "exploDir") ~= "horizontale") then
          grid.setCellInfo(line, column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
        else
          animation.reset(grid.getCellInfo(line, column, "animation"))
        end
        grid.setCellInfo(line, column, "playAnim", true)
        grid.setCellInfo(line, column, "explose", true)
      end
    else break
    end
  end
  for waitBombId, waitBomb in ipairs(waitingBombList) do
    for bombId, bomb in ipairs(bombList) do
      if (bomb.line == waitBomb.line and bomb.column == waitBomb.column) then
        grid.setCellInfo(bomb.line, bomb.column, "bomb", false)
        grid.setCellInfo(bomb.line, bomb.column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
        grid.setCellInfo(bomb.line, bomb.column, "playAnim", true)
        grid.setCellInfo(bomb.line, bomb.column, "explose", true)
        grid.setCellInfo(bomb.line, bomb.column, "collide", false)
        table.remove(bombList, bombId)
        table.remove(playerBombList[bomb.playerId], getBombId(bomb))
        bombExplose(bomb)
      end
    end
  end
end

local class = {}

--Change collide bomb state to true
function class.changeCollide(charLine, charColumn)
  for bombId, bomb in ipairs(bombList) do
    if ((bomb.line ~= charLine or bomb.column ~= charColumn) and (grid.getCellInfo(bomb.line, bomb.column, "collide") == false)) then
      grid.setCellInfo(bomb.line, bomb.column, "collide", true)
    end
  end
end

--Get bomb list
function class.getBombList()
  return bombList
end

function class.getPlayerBombList(playerId)
  return playerBombList[playerId]
end

--Create bomb
function class.create(cell, bombSize, playerId)
  local bomb = {}
  local frame, framerate, x, y, w, h

  bomb.playerId = playerId

  --Animation
  frame, framerate, x, y, w, h = 3, 6, 0, 0, 50, 50
  bomb.anim = animation.new(data.images.bomb, frame, framerate, x, y, w, h)
  --Bomb position and size
  local cellCoord = grid.getCellCoord(cell.line, cell.column)
  bomb.x = cellCoord.x
  bomb.y = cellCoord.y
  bomb.line = cell.line
  bomb.column = cell.column
  bomb.size = bombSize
  --Audio
  if (audio.getActivatedAudio().soundEffect) then
    bomb.explosionSound = love.audio.newSource('Assets/Audio/Explosion.mp3', 'static')
    bomb.explosionSound:setVolume(0.2)
  end


  grid.setCellInfo(bomb.line, bomb.column, "bomb", true)
  table.insert(bombList, bomb)
  table.insert(playerBombList[playerId], bomb)
end

--Load
function class.load()
  data = {}
  bombList = {}
  playerBombList = {{}, {}, {}, {}}
  initBombs()
end

function class.explose(bombId, bomb)
  if (audio.getActivatedAudio().soundEffect) then
    bomb.explosionSound:play()
  end
  grid.setCellInfo(bomb.line, bomb.column, "bomb", false)
  grid.setCellInfo(bomb.line, bomb.column, "animation", animation.new(data.images.explosion, 4, 8, 0, 0, 50, 50))
  grid.setCellInfo(bomb.line, bomb.column, "playAnim", true)
  grid.setCellInfo(bomb.line, bomb.column, "explose", true)
  grid.setCellInfo(bomb.line, bomb.column, "collide", false)
  table.remove(bombList, bombId)
  table.remove(playerBombList[bomb.playerId], getBombId(bomb))
  bombExplose(bomb)
end

--Update all bombs
function class.update(dt)
  for bombId, bomb in ipairs(bombList) do
    if (animation.updateLoop(bomb.anim, dt, 3)) then
      class.explose(bombId, bomb)
    end
  end
end

--Draw all bombs
function class.draw()
  for bombId, bomb in ipairs(bombList) do
    love.graphics.setColor(1, 1, 1)
    animation.draw(bomb.anim, bomb.x, bomb.y)
  end
end

return class