local screen = require("screen")
local grid = require("multi/grid")
local players = require("multi/players")
local font = require("font")

local data = {}

local class = {}

--LOAD HUD
function class.load()
  data = {}

  --Overlay
  data.imageLeft = love.graphics.newImage('Assets/Images/HudLeft.png')
  data.imageRight = love.graphics.newImage('Assets/Images/HudRight.png')
  data.imageCenter = love.graphics.newImage('Assets/Images/HudCenter.png')

  --Overlay Position
  data.xLeft = 0
  data.xRight = screen.getWidth() - data.imageRight:getWidth()
  data.xCenter1 = data.imageLeft:getWidth()
  data.xCenter2 = data.imageLeft:getWidth() + data.imageCenter:getWidth()
end

--DRAW HUD
function class.draw()
  --DRAW OVERLAY
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.imageCenter, data.xCenter1)
  love.graphics.draw(data.imageCenter, data.xCenter2)
  love.graphics.draw(data.imageLeft, data.xLeft)
  love.graphics.draw(data.imageRight, data.xRight)
end

return class