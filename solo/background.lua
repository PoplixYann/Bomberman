local screen = require("screen")

local data = {}

local class = {}

function class.moveX(dir, value, dt)
  if (dir == "left") then
    data.x1 = data.x1 - value * dt
    data.x2 = data.x2 - value * dt
    if (data.x1 < -screen.getWidth()) then
      data.x2 = 0
      data.x1 = screen.getWidth()
    elseif (data.x2 < -screen.getWidth()) then
      data.x2 = screen.getWidth()
      data.x1 = 0
    end
  elseif(dir == "right") then
    data.x1 = data.x1 + value * dt
    data.x2 = data.x2 + value * dt
    if (data.x1 > screen.getWidth()) then
      data.x1 = -screen.getWidth()
      data.x2 = 0
    elseif (data.x2 > screen.getWidth()) then
      data.x1 = 0
      data.x2 = -screen.getWidth()
    end
  end
end

function class.load()
  data = {}
  data.image = love.graphics.newImage('Assets/Images/PlayBackground.jpg')
  data.x1 = 0
  data.x2 = screen.getWidth()
end

function class.draw()
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.draw(data.image, data.x1)
  love.graphics.draw(data.image, data.x2)
end

return class