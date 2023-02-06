local data = {}

local class = {}

--Get screen width
function class.getWidth()
  return data.width
end

--Get screen height
function class.getHeight()
  return data.height
end

--Load
function class.load()
  data.width = love.graphics.getWidth()
  data.height = love.graphics.getHeight()
end

return class