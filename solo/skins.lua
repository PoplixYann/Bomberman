local save = require("save")

local data = {}

local class = {}

function class.getIndex()
  return data.index
end

function class.setIndex(newIndex)
  data.index = newIndex
  save.saveSkins(newIndex)
end

function class.getCharacterSkin()
  return data.character[data.index]
end

function class.load()
  data.character = {}
  data.index = save.getSkins().index

  local skin

  --Mighty Skin
  skin = {}
  skin.imageMovement = love.graphics.newImage('Assets/Images/MightyMovement.png')
  skin.imageDeath = love.graphics.newImage('Assets/Images/MightyDeath.png')
  skin.move = {}
  skin.move.frame = 3
  skin.move.framerate = 9
  skin.move.x, skin.move.y, skin.move.w, skin.move.h = 41.2, 55.5, 43.5, 53.7
  skin.idle = {}
  skin.idle.frame = 1
  skin.idle.framerate = 2
  skin.idle.x, skin.idle.y, skin.idle.w, skin.idle.h = 0, 55.5, 37.6, 53.7
  skin.death = {}
  skin.death.frame = 1
  skin.death.framerate = 2
  skin.death.x, skin.death.y, skin.death.w, skin.death.h = 0, 0, 43, 52
  table.insert(data.character, skin)

  --BomberBoy Skin
  skin = {}
  skin.imageMovement = love.graphics.newImage('Assets/Images/BomberboyMovement.png')
  skin.imageDeath = love.graphics.newImage('Assets/Images/BomberboyDeath.png')
  skin.move = {}
  skin.move.frame = 6
  skin.move.framerate = 9
  skin.move.x, skin.move.y, skin.move.w, skin.move.h = 36, 54, 36, 54
  skin.idle = {}
  skin.idle.frame = 1
  skin.idle.framerate = 2
  skin.idle.x, skin.idle.y, skin.idle.w, skin.idle.h = 0, 54, 36, 54
  skin.death = {}
  skin.death.frame = 5
  skin.death.framerate = 5
  skin.death.x, skin.death.y, skin.death.w, skin.death.h = 0, 54, 54, 54
  table.insert(data.character, skin)
  
end

return class