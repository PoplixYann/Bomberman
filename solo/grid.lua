local screen = require("screen")
local gameInfo = require("gameInfo")
local animation = require("animation")

local data = {}
local settings = {}
local images = {}
local freeCells = {}

--Initialize grid var
local function initVar()
  data = {}
  settings = {}
  images = {}
  freeCells = {}
end

--Initialize grid settings
local function initSettings(fieldLine, fieldColumn, offsetX, nbCrate, nbBonus, nbMalus, bonusDetonate)
  settings.field = {}
  settings.field.line, settings.field.column = fieldLine, fieldColumn
  settings.cell = {}
  settings.cell.w, settings.cell.h = gameInfo.getUnit(), gameInfo.getUnit()
  settings.offset = {}
  settings.offset.x = offsetX
  settings.offset.y = screen.getHeight()/2 - (settings.field.line * settings.cell.h)/2
  settings.nbCrate = nbCrate
  settings.nbBonus = nbBonus
  settings.nbMalus = nbMalus
  settings.bonusDetonate = bonusDetonate
end

--Initialize grid images
local function initImages()
  images.floor = love.graphics.newImage('Assets/Images/Floor.jpg')
  images.wall = love.graphics.newImage('Assets/Images/Wall.jpg')
  images.door = love.graphics.newImage('Assets/Images/Door.jpg')
  images.crate = love.graphics.newImage('Assets/Images/Crate.jpg')
  images.crateAnim = love.graphics.newImage('Assets/Images/CrateAnim.png')
  images.bonus = {}
  images.bonus.image = love.graphics.newImage('Assets/Images/Bonus.png')
  images.bonus.quads = {}
  local size = 40
  images.bonus.quads[1] = love.graphics.newQuad(0 * size, 0, size, size, images.bonus.image:getDimensions())
  images.bonus.quads[2] = love.graphics.newQuad(1 * size, 0, size, size, images.bonus.image:getDimensions())
  images.bonus.quads[3] = love.graphics.newQuad(2 * size, 0, size, size, images.bonus.image:getDimensions())
  images.bonus.quads[4] = love.graphics.newQuad(3 * size, 0, size, size, images.bonus.image:getDimensions())
  images.bonus.quads[5] = love.graphics.newQuad(4 * size, 0, size, size, images.bonus.image:getDimensions())
end

--Create void map
local function createMap()
  for line = 1, settings.field.line do
    data[line] = {}
    for column = 1, settings.field.column do
      data[line][column] = {}
      data[line][column].index = 0
      data[line][column].collide = false
      data[line][column].bomb = false
      data[line][column].explose = false
      data[line][column].timer = 0
      data[line][column].bonus = false
      data[line][column].exit = false
      data[line][column].animation = nil
      data[line][column].playAnim = false
      data[line][column].exploDir = nil
    end
  end
end

--Create wall on the map
local function createWall()
  local maxLine, maxColumn = settings.field.line, settings.field.column
  for line = 1, settings.field.line do
    data[line][1].index = 1
    data[line][1].collide = true
    data[line][maxColumn].index = 1
    data[line][maxColumn].collide = true
  end
  for column = 1, settings.field.column do
    data[1][column].index = 1
    data[1][column].collide = true
    data[maxLine][column].index = 1
    data[maxLine][column].collide = true
  end
  for line = 3, settings.field.line-2, 2 do
    for column = 3, settings.field.column-2, 2 do
      data[line][column].index = 1
      data[line][column].collide = true
    end
  end
end

--Get free cells
local function getFreeCells()
  for line = 1, settings.field.line do
    for column = 1, settings.field.column do
      if (data[line][column].index == 0) then
        if not ((line == 2 or line == 3) and (column == 2 or column == 3)) then
          if not ((line == 2 and column == 4) or (line == 4 and column == 2)) then
            table.insert(freeCells, {line = line, column = column})
          end
        end
      end
    end
  end
end

local class = {}

--Get Stage Exploding Crate
function class.getExplodeCrate()
  local actualCrate = 0
  for line = 1, settings.field.line do
    for column = 1, settings.field.column do
      if (data[line][column].index == 2) then
        actualCrate = actualCrate + 1
      end
    end
  end
  return settings.nbCrate - actualCrate
end

--Set grid offset x
function class.setOffsetX(dir, value, dt)
  if (dir == "left") then
    settings.offset.x = settings.offset.x - value * dt
  elseif (dir == "right") then
    settings.offset.x = settings.offset.x + value * dt
  end
end

function class.getFreeCellsCopy()
  return freeCells
end

--Cell is Available
function class.cellIsAvailable(line, column)
  return line >= 1 and line <= settings.field.line and column >= 1 and column <= settings.field.column
end

--Get cell info
function class.getCellInfo(line, column, info)
  return data[line][column][info]
end

--Set cell info
function class.setCellInfo(line, column, info, value)
  data[line][column][info] = value
end

--Get cell line or column
function class.getCellLineColumn(x, y, w, h, info)
  if (info == "line") then
    return math.ceil(((y+h/2)/settings.cell.h) - (settings.offset.y/settings.cell.h))
  elseif (info == "column") then
    return math.ceil(((x+w/2)/settings.cell.w) - (settings.offset.x/settings.cell.w))
  end
end

--Get cell pos
function class.getCellCoord(line, column, info)
  if (info == "x") then
    return (column - 1) * settings.cell.w + settings.offset.x
  elseif (info == "y") then
    return (line - 1) * settings.cell.h + settings.offset.y
  else
    return {x = (column - 1) * settings.cell.w + settings.offset.x, y = (line - 1) * settings.cell.h + settings.offset.y, w = settings.cell.w, h = settings.cell.h}
  end
end

--Get actual map settings
function class.getMapSettings()
  return settings
end

--Get actual map data
function class.getMap()
  return data
end

--Create crate on map
function class.createCrate()
  local actualNbCrate = 0
  local line, column = 2, 4
  data[line][column].index = 2
  data[line][column].collide = true
  data[line][column].animation = animation.new(images.crateAnim, 6, 11.6, 0, 0, 50, 50)
  actualNbCrate = actualNbCrate + 1
  line, column = 4, 2
  data[line][column].index = 2
  data[line][column].collide = true
  data[line][column].animation = animation.new(images.crateAnim, 6, 11.6, 0, 0, 50, 50)
  actualNbCrate = actualNbCrate + 1
  while actualNbCrate < settings.nbCrate do
    local random = love.math.random(1, #freeCells)
    local line, column = freeCells[random].line, freeCells[random].column
    data[line][column].index = 2
    data[line][column].collide = true
    data[line][column].animation = animation.new(images.crateAnim, 6, 11.6, 0, 0, 50, 50)
    table.remove(freeCells, random)
    actualNbCrate = actualNbCrate + 1
  end
end

--Create bonus on map
function class.createBonus()
  local actualNbBonus = 0
  local actualNbMalus = 0
  local detonateIsPlaced = false
  while actualNbBonus < settings.nbBonus do
    local line, column = love.math.random(2, settings.field.line-1), love.math.random(2, settings.field.column-1)
    local cellData = data[line][column]
    if (cellData.index == 2 and cellData.bonus == false) then
      if (love.math.random(1, 2) == 1) then
        cellData.bonus = 2
        actualNbBonus = actualNbBonus + 1
      elseif (love.math.random(1, 6) == 1) then
        cellData.bonus = 1
        actualNbBonus = actualNbBonus + 1
      end
    end
  end
  while actualNbMalus < settings.nbMalus do
    local line, column = love.math.random(2, settings.field.line-1), love.math.random(2, settings.field.column-1)
    local cellData = data[line][column]
    if (cellData.index == 2 and cellData.bonus == false) then
      cellData.bonus = love.math.random(4, 5)
      actualNbMalus = actualNbMalus + 1
    end
  end
  if (settings.bonusDetonate) then
    while (not detonateIsPlaced) do
      local line, column = love.math.random(2, settings.field.line-1), love.math.random(2, settings.field.column-1)
      local cellData = data[line][column]
      if (cellData.index == 2 and cellData.bonus == false) then
        cellData.bonus = 3
        detonateIsPlaced = true
      end
    end
  end
end

--Create exit on map
function class.createExit()
  local line, column = love.math.random(2, settings.field.line-1), love.math.random(2, settings.field.column-1)
  while (data[line][column].index ~= 2 or data[line][column].bonus ~= false) do
    line, column = love.math.random(2, settings.field.line-1), love.math.random(2, settings.field.column-1)
  end
  data[line][column].exit = true
end

--Load
function class.load(fieldLine, fieldColumn, offsetX, nbCrate, nbBonus, nbMalus, bonusDetonate)
  initVar()
  initSettings(fieldLine, fieldColumn, offsetX, nbCrate, nbBonus, nbMalus, bonusDetonate)
  initImages()
  createMap()
  createWall()
  getFreeCells()
end

--Update
function class.update(dt)
  local drawColumnMin, drawColumnMax = class.getCellLineColumn(-50, 0, settings.cell.w, settings.cell.h, "column"), class.getCellLineColumn(1920, 0, settings.cell.w, settings.cell.h, "column")
  if (drawColumnMin < 1) then
    drawColumnMin = 1
  end
  if (drawColumnMax > settings.field.column) then
    drawColumnMax = settings.field.column
  end
  for line = 1, settings.field.line do
    for column = drawColumnMin, drawColumnMax do
      local cellData = data[line][column]
      if (cellData.playAnim) then
        if (animation.updateLoop(cellData.animation, dt, 1)) then
          if (cellData.explose) then
            cellData.explose = false
          end
          cellData.playAnim = false
          if (cellData.index == 2) then cellData.index = 0 end
        end
      end
    end
  end
end

--Draw Map
function class.draw()
  local drawColumnMin, drawColumnMax = class.getCellLineColumn(-50, 0, settings.cell.w, settings.cell.h, "column"), class.getCellLineColumn(1920, 0, settings.cell.w, settings.cell.h, "column")
  if (drawColumnMin < 1) then
    drawColumnMin = 1
  end
  if (drawColumnMax > settings.field.column) then
    drawColumnMax = settings.field.column
  end
  for line = 1, settings.field.line do
    for column = drawColumnMin, drawColumnMax do
      local cellData = data[line][column]
      local x, y = (column - 1) * settings.cell.w + settings.offset.x, (line - 1) * settings.cell.h + settings.offset.y
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(images.floor, x, y)
      if (cellData.index == 0) then
        if (cellData.bonus) then
          love.graphics.setColor(1, 1, 1)
          love.graphics.draw(images.bonus.image, images.bonus.quads[cellData.bonus], x + settings.cell.w/2 - 20, y+ settings.cell.h/2 - 20)
        elseif (cellData.exit) then
          love.graphics.setColor(1, 1, 1)
          love.graphics.draw(images.door, x, y)
        end
        if (cellData.playAnim) then
          love.graphics.setColor(1, 1, 1)
          animation.draw(cellData.animation, x, y)
        end
      elseif (cellData.index == 1) then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(images.wall, x, y)
      elseif (cellData.index == 2) then
        if (cellData.playAnim) then
          love.graphics.setColor(1, 1, 1)
          animation.draw(cellData.animation, x, y)
        else
          love.graphics.setColor(1, 1, 1)
          love.graphics.draw(images.crate, x, y)
        end
      end
    end
  end
end

return class