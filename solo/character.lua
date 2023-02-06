local audio = require("audio")
local keybinding = require("solo/keybinding")
local gameInfo = require("gameInfo")
local animation = require("animation")
local bomb = require("solo/bomb")
local grid = require("solo/grid")
local skins = require("solo/skins")

local mapSettings = {}
local unit
local data = {}

--Initialize character var
local function initVar()
  mapSettings = {}
  data = {}
end

--Initialize character
local function initCharacter(maxBomb, sizeBomb, detonate, charSpeed, score)
  --Character State
  data.isPlaying = true
  data.isAlive = true
  data.isDead = false

  --Position and Move
  data.w = 20
  data.h = 20
  data.x = (2 - 1) * mapSettings.cell.w + mapSettings.offset.x + mapSettings.cell.w/2 - data.w/2
  data.y = (2 - 1) * mapSettings.cell.h + mapSettings.offset.y + mapSettings.cell.h/2 - data.h/2
  data.ox, data.oy = 10, 32
  data.speed = charSpeed
  data.direction = "down"
  data.dirV = 1
  data.dirH = 1
  data.cell = {line = math.ceil(((data.y+data.h/2)/unit) - (mapSettings.offset.y/unit)), column = math.ceil(((data.x+data.w/2)/unit) - (mapSettings.offset.x/unit))}


  --Skin
  local skin = skins.getCharacterSkin()
  --Images
  data.image = skin.imageMovement
  data.deathImage = skin.imageDeath
  --Animation
  data.animations = {}
  --Anim moving
  data.animations.move = {}
  local frame = skin.move.frame
  local framerate = skin.move.framerate
  local x, y, w, h = skin.move.x, skin.move.y, skin.move.w, skin.move.h
  data.animations.move.up = animation.new(data.image, frame, framerate, x, y, w, h)
  data.animations.move.down = animation.new(data.image, frame, framerate, x, y*0, w, h)
  data.animations.move.left = animation.new(data.image, frame, framerate, x, y*2, w, h)
  data.animations.move.right = animation.new(data.image, frame, framerate, x, y*3, w, h)
  --Anim idle
  data.animations.idle = {}
  frame = skin.idle.frame
  framerate = skin.idle.framerate
  x, y, w, h = skin.idle.x, skin.idle.y, skin.idle.w, skin.idle.h
  data.animations.idle.up = animation.new(data.image, frame, framerate, x, y, w, h)
  data.animations.idle.down = animation.new(data.image, frame, framerate, x, y*0, w, h)
  data.animations.idle.left = animation.new(data.image, frame, framerate, x, y*2, w, h)
  data.animations.idle.right = animation.new(data.image, frame, framerate, x, y*3, w, h)
  --Anim dead
  frame = skin.death.frame
  framerate = skin.death.framerate
  x, y, w, h = skin.death.x, skin.death.y, skin.death.w, skin.death.h
  data.animations.deathNormal = animation.new(data.deathImage, frame, framerate, x, y*0, w, h)
  data.animations.deathExplosion = animation.new(data.deathImage, frame, framerate, x, y, w, h)
  data.dyingAlpha = 1
  data.alphaTimer = 0
  --Current Animation played
  data.currentAnim = data.animations.idle.down
  data.deathAnimPlayed = false

  --Bonus
  data.maxBomb = {}
  data.sizeBomb = {}
  data.maxBomb.actual = maxBomb
  data.maxBomb.min = 1
  data.maxBomb.max = 9
  data.sizeBomb.actual = sizeBomb
  data.sizeBomb.min = 1
  data.sizeBomb.max = 9
  data.detonate = detonate

  --Player Information
  data.score = score
  data.dieReason = ""
  data.winBomb = 0

  --Audio
  local audioData = audio.getCharacterAudio()
  data.sound = {}
  data.sound.walk = audioData.walk.source
  data.sound.walkTimer = 0
  data.sound.bomb = audioData.bomb.source
end

--get actual character cell pos
local function getCharCell()
  local newCellData = {line = math.ceil(((data.y+data.h/2)/unit) - (mapSettings.offset.y/unit)), column = math.ceil(((data.x+data.w/2)/unit) - (mapSettings.offset.x/unit))}
  if (newCellData.line ~= data.cell.line or newCellData.column ~= data.cell.column) then
    data.cell = newCellData
  end
end

--Movement function
local function movement(dt)
  local dx1, dx2, dy1, dy2 = 0, 0, 0, 0
  local keyBind = keybinding.getKey()
  if love.keyboard.isDown(keyBind.up) then
    dy1 = -1 
    data.dirV = -1
    data.direction = "up"
  end
  if love.keyboard.isDown(keyBind.down) then
    dy2 = 1 
    data.dirV = 1
    data.direction = "down"
  end
  if love.keyboard.isDown(keyBind.left) then
    dx1 = -1 
    data.dirH = -1
    data.direction = "left"
  end
  if love.keyboard.isDown(keyBind.right) then
    dx2 = 1 
    data.dirH = 1
    data.direction = "right"
  end
  local dx, dy = dx1 + dx2, dy1 + dy2
  if dx ~= 0 or dy ~= 0 then
    if dx ~= 0 and dy ~= 0 then
      local length = math.sqrt(dx^2+dy^2)
      dx = dx / length
      dy = dy / length
    end
    data.x = data.x + dx * data.speed * dt
    data.y = data.y + dy * data.speed * dt
    if (data.sound.walkTimer > 0.3) then
      data.sound.walk:stop()
      data.sound.walk:play()
      data.sound.walkTimer = 0
    else
      data.sound.walkTimer = data.sound.walkTimer + dt
    end
    return "move"
  else
    return "idle"
  end
end

local class = {}

--Set character pos x
function class.setPosX(dir, value, dt)
  if (dir == "left") then
    data.x = data.x - value * dt
  elseif(dir == "right") then
    data.x = data.x + value * dt
  end
end

--Get horizontal direction value
function class.getDirH()
  return data.dirH
end

--Add bonus to character
function class.addBonus(info)
  if (data[info].actual < data[info].max) then
    data[info].actual = data[info].actual + 1
  end
end

--Activate Detonate
function class.activateDetonate()
  data.detonate = true
end

--Add malus to character
function class.addMalus(info)
  if (data[info].actual > data[info].min) then
    data[info].actual = data[info].actual - 1
  end
end

--Get Character Data
function class.getData()
  return data
end

--Load 
function class.load(copyMapSettings, maxBomb, sizeBomb, detonate, charSpeed, score)
  initVar()
  mapSettings = copyMapSettings
  unit = gameInfo.getUnit()
  initCharacter(maxBomb, sizeBomb, detonate, charSpeed, score)
  bomb.load()
end

--Update
function class.update(dt)
  if (data.isAlive) then
    getCharCell()
    local animStatus = movement(dt)
    data.currentAnim = data.animations[animStatus][data.direction]
    animation.updateTimer(data.currentAnim, dt)
  else
    if (skins.getIndex() == 1) then
      if (data.alphaTimer > 0.3) then
        data.alphaTimer = 0
        if (data.dyingAlpha == 1) then
          data.dyingAlpha = 0
        else
          data.dyingAlpha = 1
        end
      else
        data.alphaTimer = data.alphaTimer + dt
      end
      animation.updateTimer(data.currentAnim, dt)
    elseif not (data.deathAnimPlayed) then
      if (animation.updateLoop(data.currentAnim, dt, 1)) then
        data.deathAnimPlayed = true
      end
    end
  end
end

--Draw
function class.draw()
  love.graphics.setColor(1, 1, 1, data.dyingAlpha)
  if not (data.deathAnimPlayed) then
    animation.draw(data.currentAnim, data.x, data.y, data.ox, data.oy)
  end
--  love.graphics.setColor(1, 1, 1)
--  love.graphics.rectangle('line', data.x, data.y, data.w, data.h)
end

--Keypressed
function class.keypressed(key)
  local keyBind = keybinding.getKey()
  if (key == keyBind.bomb) then
    local bombList = bomb.getBombList()
    if (#bombList < data.maxBomb.actual) then
      if (grid.getCellInfo(data.cell.line, data.cell.column, "bomb") == false) then
        data.sound.bomb:stop()
        data.sound.bomb:play()
        bomb.create(data.cell, data.sizeBomb.actual, data.detonate)
        data.winBomb = data.winBomb + 1
      end
    end
  elseif (key == keyBind.detonate and data.detonate) then
    local bombList = bomb.getBombList()
    for bombId = #bombList, 1, -1 do
      local bombi = bombList[bombId]
      if (bombi ~= nil) then
        bomb.explose(bombId, bombi)
      end
    end
  end
end

return class