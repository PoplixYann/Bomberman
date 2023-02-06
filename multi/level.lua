local players = require("multi/players")
local grid = require("multi/grid")
local hud = require("multi/HUD")
local collision = require("multi/collision")
local bomb = require("multi/bomb")
local audio = require("audio")


local data = {}

local function initLevel(nbPlayers)
  --Map
  data.nbCrate = 100
  data.nbBonus = 25
  data.nbMalus = 10

  --Players
  data.nbPlayers = nbPlayers

  --Audio
  local audioData = audio.getStageAudio()
  data.audio = {}
  data.audio.music = audioData.music.source
end

local function initBackground()
  data.background = love.graphics.newImage('Assets/Images/PlayBackground.jpg')
end

--Play Stage Music
local function playMusic()
  love.audio.stop()
  data.audio.music:play()
end

local class = {}

--Get NbPlayers
function class.getNbPlayers()
  return data.nbPlayers
end

--Load
function class.load(nbPlayers)
  initLevel(nbPlayers)
  initBackground()
  hud.load()
  grid.load(data.nbCrate, data.nbBonus, data.nbMalus)
  players.load(nbPlayers)
  grid.createCrate()
  grid.createBonus()
  collision.load()
  playMusic()
end

--Update
function class.update(dt)
  players.update(dt)
  collision.update(dt)
  grid.update(dt)
  bomb.update(dt)
end

--Draw
function class.draw()
  --Draw Background
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.draw(data.background)
  --Others
  grid.draw()
  bomb.draw()
  players.draw()
  hud.draw(data.timer)
end

return class