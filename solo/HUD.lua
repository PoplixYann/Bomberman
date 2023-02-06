local screen = require("screen")
local gameInfo = require("gameInfo")
local grid = require("solo/grid")
local character = require("solo/character")
local font = require("font")

local data = {}

local class = {}

--Move HUD OVERLAY with camera
function class.moveX(dir, value, dt)
  if (dir == "left") then
    data.xLeft = data.xLeft - value * dt
    data.xRight = data.xRight - value * dt
    data.xCenter1 = data.xCenter1 - value * dt
    data.xCenter2 = data.xCenter2 - value * dt
    data.xCenter3 = data.xCenter3 - value * dt
    for scoreId, score in ipairs(data.scoreList) do
      score.x = score.x - value * dt
      score.xFinal = score.xFinal - value * dt
    end
    if (data.xCenter1 < 0 and data.xCenter3 < 0) then
      data.xCenter3 = data.xCenter2 + data.imageCenter:getWidth()
    elseif (data.xCenter2 < 0 and data.xCenter1 < 0) then
      data.xCenter1 = data.xCenter3 + data.imageCenter:getWidth()
    elseif (data.xCenter3 < 0 and data.xCenter2 < 0) then
      data.xCenter2 = data.xCenter1 + data.imageCenter:getWidth()
    end
  elseif(dir == "right") then
    data.xLeft = data.xLeft + value * dt
    data.xRight = data.xRight + value * dt
    data.xCenter1 = data.xCenter1 + value * dt
    data.xCenter2 = data.xCenter2 + value * dt
    data.xCenter3 = data.xCenter3 + value * dt
    for scoreId, score in ipairs(data.scoreList) do
      score.x = score.x + value * dt
      score.xFinal = score.xFinal + value * dt
    end
    if (data.xCenter1 > screen.getWidth() and data.xCenter3 > screen.getWidth()/2) then
      data.xCenter1 = data.xCenter2 - data.imageCenter:getWidth()
    elseif (data.xCenter3 > screen.getWidth() and data.xCenter2 > screen.getWidth()/2) then
      data.xCenter3 = data.xCenter1 - data.imageCenter:getWidth()
    elseif (data.xCenter2 > screen.getWidth() and data.xCenter1 > screen.getWidth()/2) then
      data.xCenter2 = data.xCenter3 - data.imageCenter:getWidth()
    end
  end
end

--Setup Score Add Info
function class.setupScoreAdd(x, y, points)
  local score = {}

  score.x, score.y = x + 20, y
  score.xFinal = x + 30
  score.text = points
  score.timer = 0

  table.insert(data.scoreList, score)
end

--LOAD HUD
function class.load(nbColumn)
  data = {}

  --Overlay
  data.imageLeft = love.graphics.newImage('Assets/Images/HudLeft.png')
  data.imageRight = love.graphics.newImage('Assets/Images/HudRight.png')
  data.imageCenter = love.graphics.newImage('Assets/Images/HudCenter.png')

  --Bonus
  data.imagebonus = {}
  data.imagebonus.image = love.graphics.newImage('Assets/Images/Bonus.png')
  data.imagebonus.quads = {}
  local size = 40
  data.imagebonus.quads.sizeBomb = love.graphics.newQuad(0 * size, 0, size, size, data.imagebonus.image:getDimensions())
  data.imagebonus.quads.nbBomb = love.graphics.newQuad(1 * size, 0, size, size, data.imagebonus.image:getDimensions())
  data.imagebonus.quads.detonate = love.graphics.newQuad(2 * size, 0, size, size, data.imagebonus.image:getDimensions())

  --Overlay Position
  data.xLeft = 0
  if ((nbColumn * gameInfo.getUnit()) + (234*2) > screen.getWidth()) then
    data.xRight = 234 - (data.imageRight:getWidth() - 234) + nbColumn * gameInfo.getUnit()
  else
    data.xRight = screen.getWidth() - data.imageRight:getWidth()
  end
  data.xCenter1 = data.imageLeft:getWidth() - data.imageCenter:getWidth()
  data.xCenter2 = data.imageLeft:getWidth()
  data.xCenter3 = data.imageLeft:getWidth() + data.imageCenter:getWidth()

  --Information HUD
  data.info = {}
  data.info.background = {}
  data.info.background.w, data.info.background.h = screen.getWidth() - (2*158), 110
  data.info.background.x, data.info.background.y = 158, 965
  data.info.score = {}
  data.info.score.x, data.info.score.y = data.info.background.x+76, data.info.background.y+(data.info.background.h/2)-(font.getFont("fontWhite"):getHeight()/2)
  data.info.timerX = data.info.background.x+480
  data.info.timerY = data.info.background.y + (data.info.background.h/2) - (font.getFont("fontWhite"):getHeight()/2)
  data.info.bonus = {}
  data.info.bonus.nbBomb = {}
  data.info.bonus.nbBomb.imageX, data.info.bonus.nbBomb.imageY = 1200, 980
  data.info.bonus.nbBomb.textX, data.info.bonus.nbBomb.textY = 1240, 985
  data.info.bonus.sizeBomb = {}
  data.info.bonus.sizeBomb.imageX, data.info.bonus.sizeBomb.imageY = 1400, 980
  data.info.bonus.sizeBomb.textX, data.info.bonus.sizeBomb.textY = 1440, 985
  data.info.bonus.detonate = {}
  data.info.bonus.detonate.imageX, data.info.bonus.detonate.imageY = 1200, 1030
  data.info.bonus.detonate.textX, data.info.bonus.detonate.textY = 1240, 1035
  data.info.bonus.detonate.text1, data.info.bonus.detonate.text2 = ": activated", ": not activated"

  --Score Add
  data.scoreList = {}
end

--UPDATE HUD
function class.update(dt)
  for scoreId, score in ipairs(data.scoreList) do
    if (score.timer > 1) then
      table.remove(data.scoreList, scoreId)
    elseif (score.timer < 1) then
      if (score.timer < 0.5) then
        score.y = score.y - 20 * dt
      else
        score.y = score.y + 10 * dt
      end
      if (score.x < score.xFinal) then
        score.x = score.x + 10 * dt
      end
      score.timer = score.timer + dt
    end
  end
end

--DRAW HUD
function class.draw(timer)
  --DRAW OVERLAY
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.imageCenter, data.xCenter1)
  love.graphics.draw(data.imageCenter, data.xCenter2)
  love.graphics.draw(data.imageCenter, data.xCenter3)
  love.graphics.draw(data.imageLeft, data.xLeft)
  love.graphics.draw(data.imageRight, data.xRight)

  --DRAW HUD INFO
  --Background of hud info
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle('fill', data.info.background.x, data.info.background.y, data.info.background.w, data.info.background.h)

  local char = character.getData()
  --Score of hud info
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.print({"score : ", char.score}, data.info.score.x, data.info.score.y)

  --Timer of hud info
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf({"timeleft : ", math.ceil(timer)}, data.info.timerX, data.info.timerY, screen.getWidth(), 'left')

  --Bonus of hud info
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.imagebonus.image, data.imagebonus.quads.nbBomb, data.info.bonus.nbBomb.imageX, data.info.bonus.nbBomb.imageY)
  love.graphics.print({": ", char.maxBomb.actual}, data.info.bonus.nbBomb.textX, data.info.bonus.nbBomb.textY)
  love.graphics.draw(data.imagebonus.image, data.imagebonus.quads.sizeBomb, data.info.bonus.sizeBomb.imageX, data.info.bonus.sizeBomb.imageY)
  love.graphics.print({": ", char.sizeBomb.actual}, data.info.bonus.sizeBomb.textX, data.info.bonus.sizeBomb.textY)
  love.graphics.draw(data.imagebonus.image, data.imagebonus.quads.detonate, data.info.bonus.detonate.imageX, data.info.bonus.detonate.imageY)
  if (character.getData().detonate) then
    love.graphics.print(data.info.bonus.detonate.text1, data.info.bonus.detonate.textX, data.info.bonus.detonate.textY)
  else
    love.graphics.print(data.info.bonus.detonate.text2, data.info.bonus.detonate.textX, data.info.bonus.detonate.textY)
  end

  --Score Add
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font.getFont("fontWhite10"))
  for scoreId, score in ipairs(data.scoreList) do
    love.graphics.print(score.text, score.x, score.y)
  end
end

return class