local audio = require("audio")
local grid = require("solo/grid")
local enemies = require("solo/enemies")
local character = require("solo/character")
local bomb = require("solo/bomb")
local collision = require("solo/collision")
local gameInfo = require("gameInfo")
local screen = require("screen")
local background = require("solo/background")
local hud = require("solo/HUD")
local levels = require("solo/levels")

local data = {}

--Initialize the level
local function initLevel()
  --Acutal Stage
  if (gameInfo.getLastlevel() == "none") then
    data.actualStage = 1
  elseif (gameInfo.getLastlevel() == "10") then
    data.actualStage = 10
  elseif (gameInfo.getLastlevel() == "last") then
    data.actualStage = 11
  end

  --Get Data of Current Stage
  local levelData = levels.getData()[data.actualStage]

  --Camera settings
  data.camera = {}
  data.camera.xMin = 234
  data.camera.xMax = screen.getWidth() - 234
  data.camera.colX = screen.getWidth()/2

  --Grid settings
  data.field = {}
  data.field.line, data.field.column = levelData.field.line, levelData.field.column
  if ((data.field.column * gameInfo.getUnit()) + (234*2) > screen.getWidth()) then
    data.gridOffsetX = data.camera.xMin
  else
    data.gridOffsetX = screen.getWidth()/2 - (data.field.column * gameInfo.getUnit())/2
  end

  --Ennemies and Bonus informations
  data.nbEnemies1 = levelData.nbEnemies1
  data.nbEnemies2 = levelData.nbEnemies2
  data.nbEnemies3 = levelData.nbEnemies3
  data.nbCrate = levelData.nbCrate
  data.nbBonus = levelData.nbBonus
  data.nbMalus = levelData.nbMalus
  data.bonusDetonate = levelData.bonusDetonate

  --Character informations
  data.nbStartBomb = 1
  data.rangeStartBomb = 1
  data.detonate = false
  data.characterSpeed = 200
  data.score = 0
  data.dieReason = nil

  --Audio
  local audioData = audio.getStageAudio()
  data.audio = {}
  data.audio.music = audioData.music.source

  --Stage Timer
  data.timer = levelData.timer

  --Win Info
  data.winBomb = 0
  data.winCrate = 0
  data.winEnemies = (data.nbEnemies1 + data.nbEnemies2 + data.nbEnemies3)
  data.winLevels = 0
end

--Next Level
local function nextLevel(actualStage)
  --Acutal Stage
  data.actualStage = actualStage

  --Get Data of Current Stage
  local levelData = levels.getData()[data.actualStage]

  --Camera settings
  data.camera = {}
  data.camera.xMin = 234
  data.camera.xMax = screen.getWidth() - 234
  data.camera.colX = screen.getWidth()/2

  --Grid settings
  data.field = {}
  data.field.line, data.field.column = levelData.field.line, levelData.field.column
  if ((data.field.column * gameInfo.getUnit()) + (234*2) > screen.getWidth()) then
    data.gridOffsetX = data.camera.xMin
  else
    data.gridOffsetX = screen.getWidth()/2 - (data.field.column * gameInfo.getUnit())/2
  end

  --Enemies and Bonus informations
  data.nbEnemies1 = levelData.nbEnemies1
  data.nbEnemies2 = levelData.nbEnemies2
  data.nbEnemies3 = levelData.nbEnemies3
  data.nbCrate = levelData.nbCrate
  data.nbBonus = levelData.nbBonus
  data.nbMalus = levelData.nbMalus
  if not (character.getData().detonate) then
    data.bonusDetonate = levelData.bonusDetonate
  else
    data.bonusDetonate = false
  end

  --Character informations
  local char = character.getData()
  data.nbStartBomb = char.maxBomb.actual
  data.rangeStartBomb = char.sizeBomb.actual
  data.detonate = char.detonate
  data.characterSpeed = char.speed
  data.score = char.score
  data.dieReason = nil

  --Audio
  local audioData = audio.getStageAudio()
  data.audio = {}
  data.audio.music = audioData.music.source

  --Stage Timer
  data.timer = levelData.timer

  --Win Info
  data.winBomb = data.winBomb + char.winBomb
  data.winCrate = data.winCrate + grid.getExplodeCrate()
  data.winEnemies = data.winEnemies + (data.nbEnemies1 + data.nbEnemies2 + data.nbEnemies3)
end

--Update Timer
local function updateTimer(dt)
  local char = character.getData()

  if (char.isAlive) then
    if (data.timer <= 0) then
      char.isAlive = false
      char.isDead = true
      char.currentAnim = char.animations.deathNormal
      char.dieReason = "time's up !"
    else
      data.timer = data.timer - dt
    end
  end
end

--Update Camera
local function updateCamera(dt)
  local char = character.getData()
  local cameraSpeed = char.speed

  if (char.x + char.w/2 > data.camera.colX + char.w/2) then
    if (grid.getCellCoord(1, data.field.column, "x") + gameInfo.getUnit() > data.camera.xMax) then
      grid.setOffsetX("left",cameraSpeed, dt)
      enemies.setEnemiesX("left",cameraSpeed, dt)
      bomb.setBombsX("left",cameraSpeed, dt)
      character.setPosX("left",cameraSpeed, dt)
      background.moveX("left",cameraSpeed, dt)
      hud.moveX("left",cameraSpeed, dt)
    end
  elseif (char.x + char.w/2 < data.camera.colX - char.w/2) then
    if (grid.getCellCoord(1, 1, "x") < data.camera.xMin) then
      grid.setOffsetX("right",cameraSpeed, dt)
      enemies.setEnemiesX("right",cameraSpeed, dt)
      bomb.setBombsX("right",cameraSpeed, dt)
      character.setPosX("right",cameraSpeed, dt)
      background.moveX("right",cameraSpeed, dt)
      hud.moveX("right",cameraSpeed, dt)
    end
  end
end

local class = {}

--Play Stage Music
function class.playMusic()
  love.audio.stop()
  data.audio.music:play()
end

--Init Level Var
function class.initVar()
  data = {}
end

--Get Level data
function class.getData()
  return data
end

--Set Level score
function class.setScore()
  data.score = character.getData().score
end

--Set Level win
function class.setWin()
  data.winBomb = data.winBomb + character.getData().winBomb
  data.winCrate = data.winCrate + grid.getExplodeCrate()
  data.winLevels = #levels.getData()
end

--Set Level dieReason
function class.setDieReason()
  data.dieReason = character.getData().dieReason
end

--Get Actual Stage
function class.getStage()
  return data.actualStage
end

--Load
function class.load(actualStage)
  if (actualStage == nil) then
    initLevel()
  else
    nextLevel(actualStage)
  end
  background.load()
  hud.load(data.field.column)
  grid.load(data.field.line, data.field.column, data.gridOffsetX, data.nbCrate, data.nbBonus, data.nbMalus, data.bonusDetonate)
  enemies.load(data.nbEnemies1, data.nbEnemies2, data.nbEnemies3)
  grid.createCrate()
  grid.createBonus()
  grid.createExit()
  collision.load(grid.getMapSettings())
  character.load(grid.getMapSettings(), data.nbStartBomb, data.rangeStartBomb, data.detonate, data.characterSpeed, data.score)
end

--Update
function class.update(dt)
  character.update(dt)
  enemies.update(dt)
  collision.update(dt)
  grid.update(dt)
  bomb.update(dt)
  updateCamera(dt)
  updateTimer(dt)
  hud.update(dt)
end

--Draw
function class.draw()
  background.draw()
  grid.draw()
  bomb.draw()
  enemies.draw()
  character.draw()
  hud.draw(data.timer)
end



return class