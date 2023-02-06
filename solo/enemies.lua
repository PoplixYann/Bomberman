local audio = require("audio")
local gameInfo = require("gameInfo")
local grid = require("solo/grid")
local animation = require("animation")

local data = {}
local enemiesList = {}

--Initialize map copy var
local function initMapCopy()
  data.unit = gameInfo.getUnit()
  data.freeCellsCopy = grid.getFreeCellsCopy()
  data.mapCopy = grid.getMap()
end

--Initialize images
local function initImages()
  data.images = {}
  data.images.enemy1 = love.graphics.newImage('Assets/Images/Enemy1.png')
  data.images.enemy1Dead = love.graphics.newImage('Assets/Images/Enemy1Dead.png')
  data.images.enemy2 = love.graphics.newImage('Assets/Images/Enemy2.png')
  data.images.enemy2Dead = love.graphics.newImage('Assets/Images/Enemy2Dead.png')
  data.images.enemy3 = love.graphics.newImage('Assets/Images/Enemy3.png')
  data.images.enemy3Dead = love.graphics.newImage('Assets/Images/Enemy3Dead.png')
end

--Initialize sounds
local function initSound()
  local audioData = audio.getEnemiesAudio()
  data.audio = {}
  data.audio.AllEnemiesDead = audioData.allDead.source
  data.audio.AllEnemiesDeadIsPlayed = false
end

--Create path for enemy
local function removeFreeCellsForIa(dir, line, column)
  local walkingCell = 0
  local nbCellToWalking = love.math.random(3, 4)
  local i = 1
  if (dir == "horizontal") then
    while walkingCell < nbCellToWalking do
      if (grid.cellIsAvailable(line, column-nbCellToWalking+i)) then
        for cellId, cell in ipairs(data.freeCellsCopy) do
          if (cell.line == line and cell.column == column-nbCellToWalking+i) then
            table.remove(data.freeCellsCopy, cellId)
          end
        end
        walkingCell = walkingCell + 1
      end
      i = i+1
    end
  elseif (dir == "vertical") then
    while walkingCell < nbCellToWalking do
      if (grid.cellIsAvailable(line-nbCellToWalking+i, column)) then
        for cellId, cell in ipairs(data.freeCellsCopy) do
          if (cell.line == line-nbCellToWalking+i and cell.column == column) then
            table.remove(data.freeCellsCopy, cellId)
          end
        end
        walkingCell = walkingCell + 1
      end
      i = i+1
    end
  end
end

--Create one enemy 1
local function createEnemy(index)
  local enemy = {}

  enemy.index = index

  local random = love.math.random(1, #data.freeCellsCopy)
  local line, column = data.freeCellsCopy[random].line, data.freeCellsCopy[random].column
  if (index == 3) then
    while (line == 1 or column == 1) do
      random = love.math.random(1, #data.freeCellsCopy)
      line, column = data.freeCellsCopy[random].line, data.freeCellsCopy[random].column
    end
  else
    while ((line == 3 and column == 4) or (line == 4 and column == 3) or (line == 5 and column == 2) or (line == 2 and column == 5)) do
      random = love.math.random(1, #data.freeCellsCopy)
      line, column = data.freeCellsCopy[random].line, data.freeCellsCopy[random].column
    end
  end

  if (index == 1) then
    enemy.score = 100
  elseif (index == 2) then
    enemy.score = 250
  elseif (index == 3) then
    enemy.score = 400
  end

  enemy.isAlive = true
  enemy.timer = 0

  enemy.line = line
  enemy.column = column
  enemy.prevLine = 0
  enemy.prevColumn = 0
  enemy.w = 50
  enemy.h = 50
  enemy.x = grid.getCellCoord(line, column, "x")+gameInfo.getUnit()/2-enemy.w/2
  enemy.y = grid.getCellCoord(line, column, "y")+gameInfo.getUnit()/2-enemy.h/2
  enemy.speed = love.math.random(45, 75)
  enemy.animations = {}
  if (index == 3) then
    enemy.animations.one = animation.new(data.images["enemy"..index], 2, 8, 0, 0, 50, 50)
    enemy.animations.two = animation.new(data.images["enemy"..index], 2, 8, 0, 50, 50, 50)
    enemy.animations.oneWall = animation.new(data.images["enemy"..index], 1, 2, 100, 0, 50, 50)
    enemy.animations.twoWall = animation.new(data.images["enemy"..index], 1, 2, 100, 50, 50, 50)
  else
    enemy.animations.one = animation.new(data.images["enemy"..index], 4, 2, 0, 0, 50, 50)
    enemy.animations.two = animation.new(data.images["enemy"..index], 4, 2, 0, 50, 50, 50)
  end
  enemy.animations.dead = animation.new(data.images["enemy"..index.."Dead"], 5, 5, 0, 0, 50, 50)
  enemy.currentAnim = enemy.animations.one
  if (data.mapCopy[line][column+1].index == 1 or data.mapCopy[line][column-1].index == 1) then
    enemy.direction = "down"
    removeFreeCellsForIa("vertical", line, column)
  else
    enemy.direction = "right"
    removeFreeCellsForIa("horizontal", line, column)
  end
  enemy.turn = false

  table.insert(enemiesList, enemy)
end


local class = {}

--Set enemies pos x
function class.setEnemiesX(dir, value, dt)
  for enemyId, enemy in ipairs(enemiesList) do
    if (dir == "left") then
      enemy.x = enemy.x - value * dt
    elseif (dir == "right") then
      enemy.x = enemy.x + value * dt
    end
  end
end

--Get enemies list copy
function class.getEnemiesListCopy()
  return enemiesList
end

--Load
function class.load(nbEnemies1, nbEnemies2, nbEnemies3)
  data = {}
  enemiesList = {}
  initMapCopy()
  initImages()
  initSound()
  for i = 1, nbEnemies1 do
    createEnemy(1)
  end
  for i = 1, nbEnemies2 do
    createEnemy(2)
  end
  for i = 1, nbEnemies3 do
    createEnemy(3)
  end
end

--UPDATE
function class.update(dt)
  for enemyId, enemy in ipairs(enemiesList) do
    if (enemy.isAlive) then
      local newLine = grid.getCellLineColumn(enemy.x, enemy.y, enemy.w, enemy.h, "line")
      local newColumn = grid.getCellLineColumn(enemy.x, enemy.y, enemy.w, enemy.h, "column")
      if (newLine ~= enemy.line or newColumn ~= enemy.column) then
        enemy.line = newLine
        enemy.column = newColumn
        enemy.turn = false
      end
      if (enemy.direction == "right") then
        enemy.x = enemy.x + enemy.speed * dt
      elseif (enemy.direction == "left") then
        enemy.x = enemy.x - enemy.speed * dt
      elseif (enemy.direction == "up") then
        enemy.y = enemy.y - enemy.speed * dt
      elseif (enemy.direction == "down") then
        enemy.y = enemy.y + enemy.speed * dt
      end
      animation.updateTimer(enemy.currentAnim, dt)
    else
      if (#enemiesList == 1 and not data.audio.AllEnemiesDeadIsPlayed) then
        data.audio.AllEnemiesDead:play()
        data.audio.AllEnemiesDeadIsPlayed = true
      end
      if (animation.updateLoop(enemy.currentAnim, dt, 1)) then
        table.remove(enemiesList, enemyId)
      end
    end
  end
end

--DRAW
function class.draw()
  love.graphics.setColor(1, 1, 1)
  for enemyId, enemy in ipairs(enemiesList) do
--    love.graphics.rectangle('fill', enemy.x, enemy.y, enemy.w, enemy.h)
    animation.draw(enemy.currentAnim, enemy.x, enemy.y)
  end
end

return class