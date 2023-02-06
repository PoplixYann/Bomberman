local audio = require("audio")
local gameInfo = require("gameInfo")
local animation = require("animation")
local keybinding = require("multi/keybinding")
local grid = require("multi/grid")
local bomb = require("multi/bomb")

local data
local playerList
local mapSettings
local unit
local isEnd
local playerWin
local freeCellsCopy

local function initVar()
  data = {player1 = {}, player2 = {}, player3 = {}, player4 = {}}
  playerList = {}
  mapSettings = grid.getMapSettings()
  unit = gameInfo.getUnit()
  isEnd = false
  playerWin = {}
  freeCellsCopy = grid.getFreeCellsCopy()
end

local function initPlayersPos()
  data.player1.x = (2 - 1) * mapSettings.cell.w + mapSettings.offset.x + mapSettings.cell.w/2 - 10
  data.player1.y = (2 - 1) * mapSettings.cell.h + mapSettings.offset.y + mapSettings.cell.h/2 - 10
  data.player1.color = {1, 0, 0}
  data.player2.x = (mapSettings.field.column - 2) * mapSettings.cell.w + mapSettings.offset.x + mapSettings.cell.w/2 - 10
  data.player2.y = (mapSettings.field.line - 2) * mapSettings.cell.h + mapSettings.offset.y + mapSettings.cell.h/2 - 10
  data.player2.color = {0, 1, 0}
  data.player3.x = (mapSettings.field.column - 2) * mapSettings.cell.w + mapSettings.offset.x + mapSettings.cell.w/2 - 10
  data.player3.y = (2 - 1) * mapSettings.cell.h + mapSettings.offset.y + mapSettings.cell.h/2 - 10
  data.player3.color = {0, 0, 1}
  data.player4.x = (2 - 1) * mapSettings.cell.w + mapSettings.offset.x + mapSettings.cell.w/2 - 10
  data.player4.y = (mapSettings.field.line - 2) * mapSettings.cell.h + mapSettings.offset.y + mapSettings.cell.h/2 - 10
  data.player4.color = {1, 1, 0}
end

local function initPlayers(nbPlayers)
  for i = 1, nbPlayers do
    local player = {}

    --Index
    player.index = i

    --Character State
    player.isAlive = true

    --Position and Move
    player.w = 20
    player.h = 20
    player.x = data["player"..i].x
    player.y = data["player"..i].y
    player.ox, player.oy = 10, 32
    player.speed = 200
    player.direction = "down"
    player.dirV = 1
    player.dirH = 1
    player.cell = {line = math.ceil(((player.y+player.h/2)/unit) - (mapSettings.offset.y/unit)), column = math.ceil(((player.x+player.w/2)/unit) - (mapSettings.offset.x/unit))}


    --Images
    player.image = love.graphics.newImage('Assets/Images/BomberboyMovement.png')
    player.deathImage = love.graphics.newImage('Assets/Images/BomberboyDeath.png')
    --Animation
    player.animations = {}
    --Anim moving
    player.animations.move = {}
    local frame = 6
    local framerate = 9
    local x, y, w, h = 36, 54, 36, 54
    player.animations.move.up = animation.new(player.image, frame, framerate, x, y, w, h)
    player.animations.move.down = animation.new(player.image, frame, framerate, x, y*0, w, h)
    player.animations.move.left = animation.new(player.image, frame, framerate, x, y*2, w, h)
    player.animations.move.right = animation.new(player.image, frame, framerate, x, y*3, w, h)
    --Anim idle
    player.animations.idle = {}
    frame = 1
    framerate = 2
    x, y, w, h = 0, 54, 36, 54
    player.animations.idle.up = animation.new(player.image, frame, framerate, x, y, w, h)
    player.animations.idle.down = animation.new(player.image, frame, framerate, x, y*0, w, h)
    player.animations.idle.left = animation.new(player.image, frame, framerate, x, y*2, w, h)
    player.animations.idle.right = animation.new(player.image, frame, framerate, x, y*3, w, h)
    --Anim dead
    frame = 5
    framerate = 5
    x, y, w, h = 0, 54, 54, 54
    player.animations.deathNormal = animation.new(player.deathImage, frame, framerate, x, y*0, w, h)
    player.animations.deathExplosion = animation.new(player.deathImage, frame, framerate, x, y, w, h)
    --Current Animation played
    player.currentAnim = player.animations.idle.down
    --Color
    player.color = data["player"..i].color

    --Bonus
    player.maxBomb = {}
    player.sizeBomb = {}
    player.maxBomb.actual = 1
    player.maxBomb.min = 1
    player.maxBomb.max = 9
    player.sizeBomb.actual = 1
    player.sizeBomb.min = 1
    player.sizeBomb.max = 9

    --Audio
    local audioData = audio.getCharacterAudio()
    player.sound = {}
    player.sound.bomb = audioData.bomb.source

    --Keybinding
    local keyBind = keybinding.getPlayer(i)
    player.key = {}
    player.key.up = keyBind.up
    player.key.down = keyBind.down
    player.key.left = keyBind.left
    player.key.right = keyBind.right
    player.key.bomb = keyBind.bomb

    --Delete around free cells
    for line = player.cell.line-1, player.cell.line+1 do
      for column = player.cell.column-1, player.cell.column+1 do
        if (grid.cellIsAvailable(line, column)) then
          for cellId, cell in ipairs(freeCellsCopy) do
            if (cell.line == line and cell.column == column) then
              table.remove(freeCellsCopy, cellId)
            end
          end
        end
      end
    end

    table.insert(playerList, player)
  end
end

local function getCharCell(player)
  local newCellData = {line = math.ceil(((player.y+player.h/2)/unit) - (mapSettings.offset.y/unit)), column = math.ceil(((player.x+player.w/2)/unit) - (mapSettings.offset.x/unit))}
  if (newCellData.line ~= player.cell.line or newCellData.column ~= player.cell.column) then
    player.cell = newCellData
  end
end

--Movement function
local function movement(playerId, player, dt)
  local dx1, dx2, dy1, dy2 = 0, 0, 0, 0
  if love.keyboard.isDown(player.key.up) then
    dy1 = -1 
    player.dirV = -1
    player.direction = "up"
  end
  if love.keyboard.isDown(player.key.down) then
    dy2 = 1 
    player.dirV = 1
    player.direction = "down"
  end
  if love.keyboard.isDown(player.key.left) then
    dx1 = -1 
    player.dirH = -1
    player.direction = "left"
  end
  if love.keyboard.isDown(player.key.right) then
    dx2 = 1 
    player.dirH = 1
    player.direction = "right"
  end
  local dx, dy = dx1 + dx2, dy1 + dy2
  if dx ~= 0 or dy ~= 0 then
    if dx ~= 0 and dy ~= 0 then
      local length = math.sqrt(dx^2+dy^2)
      dx = dx / length
      dy = dy / length
    end
    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt
    return "move"
  else
    return "idle"
  end
end

local class = {}

function class.getIsEnd()
  return isEnd
end

function class.getPlayerWin()
  return playerWin
end

function class.checkWin()
  playerWin = {}
  if (#playerList > 1) then
    local nbPlayerDead = 0
    for playerId, player in ipairs(playerList) do
      if not (player.isAlive) then
        nbPlayerDead = nbPlayerDead + 1
      else
        table.insert(playerWin, {index = player.index, color = player.color})
      end
    end
    if (nbPlayerDead == #playerList) then
      --DRAW
      isEnd = true
      playerWin = {}
      for playerId, player in ipairs(playerList) do
        table.insert(playerWin, {index = player.index, color = player.color})
      end
    elseif (nbPlayerDead == #playerList-1) then
      isEnd = true
    end
  end
end

function class.getPlayerList()
  return playerList
end

--Add bonus to character
function class.addBonus(player, info)
  if (player[info].actual < player[info].max) then
    player[info].actual = player[info].actual + 1
  end
end

--Add malus to character
function class.addMalus(player, info)
  if (player[info].actual > player[info].min) then
    player[info].actual = player[info].actual - 1
  end
end

function class.load(nbPlayers)
  initVar()
  initPlayersPos()
  initPlayers(nbPlayers)
  bomb.load()
end

function class.update(dt)
  for playerId, player in ipairs(playerList) do
    if (player.isAlive) then
      getCharCell(player)
      local animStatus = movement(playerId, player, dt)
      player.currentAnim = player.animations[animStatus][player.direction]
      animation.updateTimer(player.currentAnim, dt)
    else
      if (animation.updateLoop(player.currentAnim, dt, 1)) then
        table.remove(playerList, playerId)
      end
    end
  end
end

function class.draw()
  for playerId, player in ipairs(playerList) do
    love.graphics.setColor(player.color)
    animation.draw(player.currentAnim, player.x, player.y, player.ox, player.oy)
  end
end

--Keypressed
function class.keypressed(key)
  for playerId, player in ipairs(playerList) do
    if (key == player.key.bomb) then
      local bombList = bomb.getPlayerBombList(playerId)
      if (#bombList < player.maxBomb.actual) then
        if (grid.getCellInfo(player.cell.line, player.cell.column, "bomb") == false) then
          player.sound.bomb:stop()
          player.sound.bomb:play()
          bomb.create(player.cell, player.sizeBomb.actual, playerId)
        end
      end
    end
  end
end

return class