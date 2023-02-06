
local data = {}

local class = {}

function class.getFont(font)
  return data[font]
end

function class.load()
  data.fontWhite = love.graphics.newImageFont( 'Assets/Images/FontWhite.png', '0123456789abcdefghijklmnopqrstuvwxyz :!<>.' )
  data.fontWhite10 = love.graphics.newImageFont( 'Assets/Images/FontWhite10.png', '0123456789abcdefghijklmnopqrstuvwxyz :!<>.' )
  data.fontBlack = love.graphics.newImageFont( 'Assets/Images/FontBlack.png', '0123456789abcdefghijklmnopqrstuvwxyz :!<>.' )
  data.font40 = love.graphics.newFont(40)
end

return class