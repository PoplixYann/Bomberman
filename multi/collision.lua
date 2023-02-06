local gameInfo = require("gameInfo")
local grid = require("multi/grid")
local players = require("multi/players")
local bomb = require("multi/bomb")

local data = {}

--Check collision with two rectangle
local function checkRectCollision(a, b)
  return a.x < b.x+b.w and b.x < a.x+a.w and a.y < b.y+b.h and b.y < a.y+a.h
end

--After collision move the character out of the Wall
local function replaceCharacter(char, cell)
  local unit = gameInfo.getUnit()

  local colLeft = cell.x + unit - char.x
  local colRight = char.x + char.w - cell.x
  local colUp = cell.y + unit - char.y
  local colDown = char.y + char.h - cell.y
  local colMin = math.min(colLeft, colRight, colUp, colDown)

  if (colMin == colLeft) then char.x = char.x + colLeft end
  if (colMin == colRight) then char.x = char.x - colRight end
  if (colMin == colUp) then char.y = char.y + colUp end
  if (colMin == colDown) then char.y = char.y - colDown end
end

--Check if our character is colliding with an CollideCell
local function checkCharacterCollideCellsCollision()
  local map = grid.getMap()
  local playersList = players.getPlayerList()
  for playerId, player in ipairs(playersList) do
    local charLine, charColumn = player.cell.line, player.cell.column

    for line = charLine-player.dirV, charLine+player.dirV, player.dirV do
      for column = charColumn-player.dirH, charColumn+player.dirH, player.dirH do
        if (map[line][column].collide) then
          local cell = grid.getCellCoord(line, column)
          if (checkRectCollision(player, cell)) then
            replaceCharacter(player, cell)
          end
        end
      end
    end
  end
end

--Check if our character is colliding with a bonus cell
local function checkCharacterBonusCollision()
  local map = grid.getMap()
  local playersList = players.getPlayerList()
  for playerId, player in ipairs(playersList) do
    local charLine, charColumn = player.cell.line, player.cell.column

    if (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 1) then
      players.addBonus(player, "sizeBomb")
      grid.setCellInfo(charLine, charColumn, "bonus", false)
    elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 2) then
      players.addBonus(player, "maxBomb")
      grid.setCellInfo(charLine, charColumn, "bonus", false)
    elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 4) then
      players.addMalus(player, "sizeBomb")
      grid.setCellInfo(charLine, charColumn, "bonus", false)
    elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 5) then
      players.addMalus(player, "maxBomb")
      grid.setCellInfo(charLine, charColumn, "bonus", false)
    end
  end
end

--Check if our character is colliding with explosion
local function checkCharacterExplosionCollision()
  local map = grid.getMap()
  local playersList = players.getPlayerList()
  for playerId, player in ipairs(playersList) do
    local charLine, charColumn = player.cell.line, player.cell.column

    if (map[charLine][charColumn].explose) then
      player.isAlive = false
      player.ox = 20
      player.currentAnim = player.animations.deathExplosion
    end
  end
  players.checkWin()
end

--Check if character is colliding with bomb
local function checkCharacterBombCollision()
  local playersList = players.getPlayerList()
  local bombList = bomb.getBombList()
  for bombId, bomb in ipairs(bombList) do
    if (grid.getCellInfo(bomb.line, bomb.column, "collide") == false) then
      local canBeCollide = true
      for playerId, player in ipairs(playersList) do
        local charLine, charColumn = player.cell.line, player.cell.column
        if (bomb.line == charLine and bomb.column == charColumn) then
          canBeCollide = false
        end
      end
      if (canBeCollide) then
        grid.setCellInfo(bomb.line, bomb.column, "collide", true)
      end
    end
  end
end

local class = {}

--Load
function class.load()
  data = {}
  data.mapSettings = grid.getMapSettings()
end

--Update
function class.update(dt)
  checkCharacterCollideCellsCollision()
  checkCharacterBombCollision()
  checkCharacterBonusCollision()
  checkCharacterExplosionCollision()
  checkCharacterBombCollision()
end

return class