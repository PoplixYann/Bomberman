local gameInfo = require("gameInfo")
local grid = require("solo/grid")
local character = require("solo/character")
local enemies = require("solo/enemies")
local bomb = require("solo/bomb")
local hud = require("solo/HUD")

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
  local char = character.getData()
  local charLine, charColumn = char.cell.line, char.cell.column

  for line = charLine-char.dirV, charLine+char.dirV, char.dirV do
    for column = charColumn-char.dirH, charColumn+char.dirH, char.dirH do
      if (map[line][column].collide) then
        local cell = grid.getCellCoord(line, column)
        if (checkRectCollision(char, cell)) then
          replaceCharacter(char, cell)
        end
      end
    end
  end
end

--Check if our character is colliding with a bonus cell
local function checkCharacterBonusCollision()
  local map = grid.getMap()
  local char = character.getData()
  local charLine, charColumn = char.cell.line, char.cell.column

  if (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 1) then
    character.addBonus("sizeBomb")
    grid.setCellInfo(charLine, charColumn, "bonus", false)
    hud.setupScoreAdd(grid.getCellCoord(charLine, charColumn, "x"), grid.getCellCoord(charLine, charColumn, "y"), 20)
    char.score = char.score + 20
  elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 2) then
    character.addBonus("maxBomb")
    grid.setCellInfo(charLine, charColumn, "bonus", false)
    hud.setupScoreAdd(grid.getCellCoord(charLine, charColumn, "x"), grid.getCellCoord(charLine, charColumn, "y"), 20)
    char.score = char.score + 20
  elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 3) then
    character.activateDetonate()
    grid.setCellInfo(charLine, charColumn, "bonus", false)
    hud.setupScoreAdd(grid.getCellCoord(charLine, charColumn, "x"), grid.getCellCoord(charLine, charColumn, "y"), 50)
    char.score = char.score + 50
  elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 4) then
    character.addMalus("sizeBomb")
    grid.setCellInfo(charLine, charColumn, "bonus", false)
    hud.setupScoreAdd(grid.getCellCoord(charLine, charColumn, "x"), grid.getCellCoord(charLine, charColumn, "y"), 100)
    char.score = char.score + 100
  elseif (map[charLine][charColumn].index == 0 and map[charLine][charColumn].bonus == 5) then
    character.addMalus("maxBomb")
    grid.setCellInfo(charLine, charColumn, "bonus", false)
    hud.setupScoreAdd(grid.getCellCoord(charLine, charColumn, "x"), grid.getCellCoord(charLine, charColumn, "y"), 100)
    char.score = char.score + 100
  end
end

--Check if our character is colliding with explosion
local function checkCharacterExplosionCollision()
  local map = grid.getMap()
  local char = character.getData()
  local charLine, charColumn = char.cell.line, char.cell.column

  if (map[charLine][charColumn].explose) then
    char.isAlive = false
    char.isDead = true
    char.currentAnim = char.animations.deathExplosion
    char.dieReason = "you explode yourself !"
  end
end

--Check if character is colliding with exit
local function checkCharacterExitCollision()
  local map = grid.getMap()
  local char = character.getData()
  local charLine, charColumn = char.cell.line, char.cell.column
  local enemiesList = enemies.getEnemiesListCopy()

  if (map[charLine][charColumn].exit and #enemiesList == 0) then
    char.score = char.score + 1000
    char.isPlaying = false
  end
end

--Check if character is colliding with bomb
local function checkCharacterBombCollision()
  local char = character.getData()
  local charLine, charColumn = char.cell.line, char.cell.column

  bomb.changeCollide(charLine, charColumn)
end

--Check if enemy1 is colliding with collide cell
local function colEnemy1CollideCell(enemy)
  local map = grid.getMap()
  if (enemy.isAlive) then
    if (enemy.direction == "up") then
      if (map[enemy.line-1][enemy.column].collide or map[enemy.line-1][enemy.column].bomb) then
        local cell = grid.getCellCoord(enemy.line-1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "down"
          if (enemy.prevLine ~= enemy.line) then
            enemy.currentAnim = enemy.animations.one
            enemy.prevLine = enemy.line
          end
          if (map[enemy.line][enemy.column-1].index == 0 and map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "left"
              enemy.currentAnim = enemy.animations.two
            elseif (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column+1].explose == false) then
              if (love.math.random(1, 2) == 1) then
                enemy.direction = "right"
                enemy.currentAnim = enemy.animations.one
              end
            end
          elseif (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column+1].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "right"
              enemy.currentAnim = enemy.animations.one
            end
          end
        end
      end
    elseif (enemy.direction == "down") then
      if (map[enemy.line+1][enemy.column].collide or map[enemy.line+1][enemy.column].bomb) then
        local cell = grid.getCellCoord(enemy.line+1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "up"
          if (enemy.prevLine ~= enemy.line) then
            enemy.currentAnim = enemy.animations.two
            enemy.prevLine = enemy.line
          end
          if (map[enemy.line][enemy.column-1].index == 0 and map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "left"
              enemy.currentAnim = enemy.animations.two
            elseif (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column+1].explose == false) then
              if (love.math.random(1, 2) == 1) then
                enemy.direction = "right"
                enemy.currentAnim = enemy.animations.one
              end
            end
          elseif (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column+1].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "right"
              enemy.currentAnim = enemy.animations.one
            end
          end
        end
      end
    elseif (enemy.direction == "left") then
      if (map[enemy.line][enemy.column-1].collide or map[enemy.line][enemy.column-1].bomb) then
        local cell = grid.getCellCoord(enemy.line, enemy.column-1)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "right"
          if (enemy.prevColumn ~= enemy.column) then
            enemy.currentAnim = enemy.animations.one
            enemy.prevColumn = enemy.column
          end
          if (map[enemy.line+1][enemy.column].index == 0 and map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "down"
              enemy.currentAnim = enemy.animations.one
            elseif (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false) then
              if (love.math.random(1, 2) == 1) then
                enemy.direction = "up"
                enemy.currentAnim = enemy.animations.two
              end
            end
          elseif (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "up"
              enemy.currentAnim = enemy.animations.two
            end
          end
        end
      end
    elseif (enemy.direction == "right") then
      if (map[enemy.line][enemy.column+1].collide or map[enemy.line][enemy.column+1].bomb) then
        local cell = grid.getCellCoord(enemy.line, enemy.column+1)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "left"
          if (enemy.prevColumn ~= enemy.column) then
            enemy.currentAnim = enemy.animations.two
            enemy.prevColumn = enemy.column
          end
          if (map[enemy.line+1][enemy.column].index == 0 and map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "down"
              enemy.currentAnim = enemy.animations.one
            elseif (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false) then
              if (love.math.random(1, 2) == 1) then
                enemy.direction = "up"
                enemy.currentAnim = enemy.animations.two
              end
            end
          elseif (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false) then
            if (love.math.random(1, 2) == 1) then
              enemy.direction = "up"
              enemy.currentAnim = enemy.animations.two
            end
          end
        end
      end
    end
  end
end

--Check if enemy2 is colliding with collide cell
local function colEnemy2CollideCell(enemy)
  local map = grid.getMap()
  if (enemy.isAlive) then
    if (enemy.direction == "up") then
      if (map[enemy.line-1][enemy.column].collide or map[enemy.line-1][enemy.column].bomb) then
        local cell = grid.getCellCoord(enemy.line-1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "down"
          if (enemy.prevLine ~= enemy.line) then
            enemy.currentAnim = enemy.animations.one
            enemy.prevLine = enemy.line
          end
        end
      end
      if (enemy.turn == false) then
        local cell = grid.getCellCoord(enemy.line-1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line][enemy.column-1].index == 0 and map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 8) == 1) then
              isTurning = true
              enemy.direction = "left"
              enemy.currentAnim = enemy.animations.two
            end
          end
          if (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column+1].explose == false and isTurning == false) then
            if (love.math.random(1, 8) == 1) then
              enemy.direction = "right"
              enemy.currentAnim = enemy.animations.one
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "down") then
      if (map[enemy.line+1][enemy.column].collide or map[enemy.line+1][enemy.column].bomb) then
        local cell = grid.getCellCoord(enemy.line+1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "up"
          if (enemy.prevLine ~= enemy.line) then
            enemy.currentAnim = enemy.animations.two
            enemy.prevLine = enemy.line
          end
        end
      end
      if (enemy.turn == false) then
        local cell = grid.getCellCoord(enemy.line+1, enemy.column)
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line][enemy.column-1].index == 0 and map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 8) == 1) then
              isTurning = true
              enemy.direction = "left"
              enemy.currentAnim = enemy.animations.two
            end
          end
          if (map[enemy.line][enemy.column+1].index == 0 and map[enemy.line][enemy.column-1].explose == false and isTurning == false) then
            if (love.math.random(1, 8) == 1) then
              enemy.direction = "right"
              enemy.currentAnim = enemy.animations.one
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "left") then
      if (map[enemy.line][enemy.column-1].collide or map[enemy.line][enemy.column-1].bomb) then
        local cell = grid.getCellCoord(enemy.line, enemy.column-1)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "right"
          if (enemy.prevColumn ~= enemy.column) then
            enemy.currentAnim = enemy.animations.one
            enemy.prevColumn = enemy.column
          end
        end
      end
      if (enemy.turn == false) then
        local cell = grid.getCellCoord(enemy.line, enemy.column-1)
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line+1][enemy.column].index == 0 and map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 8) == 1) then
              isTurning = true
              enemy.direction = "down"
              enemy.currentAnim = enemy.animations.one
            end
          end
          if (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false and isTurning == false) then
            if (love.math.random(1, 8) == 1) then
              enemy.direction = "up"
              enemy.currentAnim = enemy.animations.two
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "right") then
      if (map[enemy.line][enemy.column+1].collide or map[enemy.line][enemy.column+1].bomb) then
        local cell = grid.getCellCoord(enemy.line, enemy.column+1)
        if (checkRectCollision(enemy, cell)) then
          enemy.direction = "left"
          if (enemy.prevColumn ~= enemy.column) then
            enemy.currentAnim = enemy.animations.two
            enemy.prevColumn = enemy.column
          end
        end
      end
      if (enemy.turn == false) then
        local cell = grid.getCellCoord(enemy.line, enemy.column+1)
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line+1][enemy.column].index == 0 and map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 8) == 1) then
              isTurning = true
              enemy.direction = "down"
              enemy.currentAnim = enemy.animations.one
            end
          end
          if (map[enemy.line-1][enemy.column].index == 0 and map[enemy.line-1][enemy.column].explose == false and isTurning == false) then
            if (love.math.random(1, 8) == 1) then
              enemy.direction = "up"
              enemy.currentAnim = enemy.animations.two
            end
          end
          enemy.turn = true
        end
      end
    end
  end
end

--Check if enemy3 is colliding with collide cell
local function colEnemy3CollideCell(enemy)
  local map = grid.getMap()
  local mapSettings = grid.getMapSettings()
  if (enemy.isAlive) then
    if (enemy.direction == "up") then
      local cell = grid.getCellCoord(enemy.line-1, enemy.column)
      if (map[enemy.line-1][enemy.column].collide or map[enemy.line-1][enemy.column].bomb) then
        if (checkRectCollision(enemy, cell)) then
          if (enemy.line-1 == 1) then
            enemy.direction = "down"
            enemy.currentAnim = enemy.animations.one
          else
            enemy.currentAnim = enemy.animations.twoWall
          end
        end
      elseif (enemy.currentAnim == enemy.animations.twoWall) then
        if (checkRectCollision(enemy, {x = cell.x, y = cell.y, w = cell.w-gameInfo.getUnit()/2, h = cell.h-gameInfo.getUnit()/2})) then
          enemy.currentAnim = enemy.animations.two
        end
      end
      if (enemy.turn == false) then
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 32) == 1) then
              isTurning = true
              enemy.direction = "left"
              if (map[enemy.line][enemy.column-1].collide) then
                enemy.currentAnim = enemy.animations.twoWall
              else
                enemy.currentAnim = enemy.animations.two
              end
            end
          end
          if (map[enemy.line][enemy.column+1].explose == false and isTurning == false) then
            if (love.math.random(1, 32) == 1) then
              enemy.direction = "right"
              if (map[enemy.line][enemy.column+1].collide) then
                enemy.currentAnim = enemy.animations.oneWall
              else
                enemy.currentAnim = enemy.animations.one
              end
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "down") then
      local cell = grid.getCellCoord(enemy.line+1, enemy.column)
      if (map[enemy.line+1][enemy.column].collide or map[enemy.line+1][enemy.column].bomb) then
        if (checkRectCollision(enemy, cell)) then
          if (enemy.line+1 == mapSettings.field.line) then
            enemy.direction = "up"
            enemy.currentAnim = enemy.animations.two
          else
            enemy.currentAnim = enemy.animations.oneWall
          end
        end
      elseif (enemy.currentAnim == enemy.animations.oneWall) then
        if (checkRectCollision(enemy, {x = cell.x, y = cell.y, w = cell.w-gameInfo.getUnit()/2, h = cell.h-gameInfo.getUnit()/2})) then
          enemy.currentAnim = enemy.animations.one
        end
      end
      if (enemy.turn == false) then
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line][enemy.column-1].explose == false) then
            if (love.math.random(1, 32) == 1) then
              isTurning = true
              enemy.direction = "left"
              if (map[enemy.line][enemy.column-1].collide) then
                enemy.currentAnim = enemy.animations.twoWall
              else
                enemy.currentAnim = enemy.animations.two
              end
            end
          end
          if (map[enemy.line][enemy.column+1].explose == false and isTurning == false) then
            if (love.math.random(1, 32) == 1) then
              enemy.direction = "right"
              if (map[enemy.line][enemy.column+1].collide) then
                enemy.currentAnim = enemy.animations.oneWall
              else
                enemy.currentAnim = enemy.animations.one
              end
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "left") then
      local cell = grid.getCellCoord(enemy.line, enemy.column-1)
      if (map[enemy.line][enemy.column-1].collide or map[enemy.line][enemy.column-1].bomb) then
        if (checkRectCollision(enemy, cell)) then
          if (enemy.column-1 == 1) then
            enemy.direction = "right"
            enemy.currentAnim = enemy.animations.one
          else
            enemy.currentAnim = enemy.animations.twoWall
          end
        end
      elseif (enemy.currentAnim == enemy.animations.twoWall) then
        if (checkRectCollision(enemy, {x = cell.x, y = cell.y, w = cell.w-gameInfo.getUnit()/2, h = cell.h-gameInfo.getUnit()/2})) then
          enemy.currentAnim = enemy.animations.two
        end
      end
      if (enemy.turn == false) then
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 32) == 1) then
              isTurning = true
              enemy.direction = "down"
              if (map[enemy.line+1][enemy.column].collide) then
                enemy.currentAnim = enemy.animations.oneWall
              else
                enemy.currentAnim = enemy.animations.one
              end
            end
          end
          if (map[enemy.line-1][enemy.column].explose == false and isTurning == false) then
            if (love.math.random(1, 32) == 1) then
              enemy.direction = "up"
              if (map[enemy.line-1][enemy.column].collide) then
                enemy.currentAnim = enemy.animations.twoWall
              else
                enemy.currentAnim = enemy.animations.two
              end
            end
          end
          enemy.turn = true
        end
      end
    elseif (enemy.direction == "right") then
      local cell = grid.getCellCoord(enemy.line, enemy.column+1)
      if (map[enemy.line][enemy.column+1].collide or map[enemy.line][enemy.column+1].bomb) then
        if (checkRectCollision(enemy, cell)) then
          if (enemy.column+1 == mapSettings.field.column) then
            enemy.direction = "left"
            enemy.currentAnim = enemy.animations.two
          else
            enemy.currentAnim = enemy.animations.oneWall
          end
        end
      elseif (enemy.currentAnim == enemy.animations.oneWall) then
        if (checkRectCollision(enemy, {x = cell.x, y = cell.y, w = cell.w-gameInfo.getUnit()/2, h = cell.h-gameInfo.getUnit()/2})) then
          enemy.currentAnim = enemy.animations.one
        end
      end
      if (enemy.turn == false) then
        if (checkRectCollision(enemy, cell)) then
          local isTurning = false
          if (map[enemy.line+1][enemy.column].explose == false) then
            if (love.math.random(1, 32) == 1) then
              isTurning = true
              enemy.direction = "down"
              if (map[enemy.line+1][enemy.column].collide) then
                enemy.currentAnim = enemy.animations.oneWall
              else
                enemy.currentAnim = enemy.animations.one
              end
            end
          end
          if (map[enemy.line-1][enemy.column].explose == false and isTurning == false) then
            if (love.math.random(1, 32) == 1) then
              enemy.direction = "up"
              if (map[enemy.line-1][enemy.column].collide) then
                enemy.currentAnim = enemy.animations.twoWall
              else
                enemy.currentAnim = enemy.animations.two
              end
            end
          end
          enemy.turn = true
        end
      end
    end
  end
end

--Check if enemies are colliding with an CollideCell
local function checkEnemiesCollideCellsCollision()
  local enemiesList = enemies.getEnemiesListCopy()

  for enemyId, enemy in ipairs(enemiesList) do
    if (enemy.index == 1) then
      colEnemy1CollideCell(enemy)
    elseif (enemy.index == 2) then
      colEnemy2CollideCell(enemy)
    elseif (enemy.index == 3) then
      colEnemy3CollideCell(enemy)
    end
  end
end

--Check if enemy is colliding with explosion
local function checkEnemiesExplosionCollision()
  local map = grid.getMap()
  local enemiesList = enemies.getEnemiesListCopy()
  local char = character.getData()

  for enemyId, enemy in ipairs(enemiesList) do
    if (map[enemy.line][enemy.column].explose and enemy.isAlive) then
      enemy.isAlive = false
      enemy.currentAnim = enemy.animations.dead
      hud.setupScoreAdd(enemy.x, enemy.y, enemy.score)
      char.score = char.score + enemy.score
    end
  end
end

--Check if character is colliding with enemy
local function checkCharacterEnemiesCollision()
  local map = grid.getMap()
  local enemiesList = enemies.getEnemiesListCopy()
  local char = character.getData()

  for enemyId, enemy in ipairs(enemiesList) do
    if (checkRectCollision(char, enemy)) then
      char.isAlive = false
      char.isDead = true
      char.currentAnim = char.animations.deathNormal
      char.dieReason = "an enemy killed you !"
    end
  end
end

local class = {}

--Load
function class.load(mapSettings)
  data = {}
  data.mapSettings = mapSettings
end

--Update
function class.update(dt)
  if (character.getData().isAlive) then
    checkCharacterCollideCellsCollision()
    checkCharacterBombCollision()
    checkCharacterBonusCollision()
    checkCharacterEnemiesCollision()
    checkCharacterExplosionCollision()
    checkCharacterExitCollision()
    checkEnemiesExplosionCollision()
  end
  checkEnemiesCollideCellsCollision()
end

return class