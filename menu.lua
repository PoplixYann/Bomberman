local save = require("save")
local screen = require("screen")
local gameInfo = require("gameInfo")
local audio = require("audio")
local font = require("font")
local animation = require("animation")
local keybindingSolo = require("solo/keybinding")
local skinsSolo = require("solo/skins")
local levelsSolo = require("solo/levels")
local soloMenu = require("solo/menu")
local keybindingMulti = require("multi/keybinding")
local multiMenu = require("multi/menu")

local data = {}
local buttonsList = {}

--Initialize menu var
local function initVar()
  data = {}
  buttonsList = {}
end

--Create button
local function createButton(image, text, x, y, w, h, alpha, func)
  local button = {}

  button.image = image
  button.text = text
  button.w = w
  button.h = h
  button.x = x
  button.y = y
  button.func = func
  button.alpha = alpha
  button.alphaTimer = 0
  button.alphaRepeatTime = 0

  table.insert(buttonsList, button)
end

local class = {}

local function goToSolo()
  keybindingSolo.load()
  skinsSolo.load()
  levelsSolo.load()

  soloMenu.load()
  soloMenu.loadMain()
  gameInfo.setMode("solo")
  gameInfo.setGamestate("solo_menu_main")
end

local function goToMulti()
  keybindingMulti.load()
  
  multiMenu.load()
  multiMenu.loadMain()
  gameInfo.setMode("multi")
  gameInfo.setGamestate("multi_menu_main")
end

--Leave the game
local function leave()
  save.saveAll()
  love.event.quit()
end

function class.load()
  initVar()

  --Audio
  if not (gameInfo.getGamestate() == "solo_menu_main" or gameInfo.getGamestate() == "multi_menu_main") then
    love.audio.stop()
    local audioData = audio.getMenuMainAudio()
    audio.getMenuMainAudio().music.source:play()
  end

  --Images
  data.background = love.graphics.newImage('Assets/Images/MainBackgroundPlay.jpg')
  data.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.arrow:getWidth()/7, data.arrow:getHeight()
  data.arrowAnim = animation.new(data.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "singleplayer", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, goToSolo)
  createButton(nil, "multiplayer", buttons.x, buttons.y, buttons.w, buttons.h, 1, goToMulti)
  createButton(nil, "leave", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, leave)

  --Buttons Information
  data.buttonSelect = false
  data.selectedButtonId = 1
end

function class.update(dt)
  animation.updateTimer(data.arrowAnim, dt)
  if (data.buttonSelect) then
    if (buttonsList[data.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.selectedButtonId].alpha == 1) then
        buttonsList[data.selectedButtonId].alpha = 0
      elseif (buttonsList[data.selectedButtonId].alpha == 0) then
        buttonsList[data.selectedButtonId].alpha = 1
      end
      buttonsList[data.selectedButtonId].alphaRepeatTime = buttonsList[data.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.selectedButtonId].func()
        return;
      end
      buttonsList[data.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.selectedButtonId].alphaTimer = buttonsList[data.selectedButtonId].alphaTimer + dt
    end
  end
end

function class.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.background)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (buttonId == 2) then
      love.graphics.printf("< beta", button.x + button.w, button.y+button.h/2-16, button.w*2, 'left')
    end
    if (data.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.arrowAnim, button.x, button.y, 40, data.arrow:getHeight()/2 - button.h/2)
    end
  end
end

function class.keypressed(key)
  if not (data.buttonSelect) then
    if (key == 'up') then
      data.selectedButtonId = data.selectedButtonId - 1
      if (data.selectedButtonId < 1) then
        data.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.selectedButtonId = data.selectedButtonId + 1
      if (data.selectedButtonId > #buttonsList) then
        data.selectedButtonId = 1
      end
    elseif (key == 'return') then
      if (data.selectedButtonId == 1 or data.selectedButtonId == 2) then
        data.buttonSelect = true
      else
        buttonsList[data.selectedButtonId].func()
      end
    end
  end
  if (key == 'escape') then
    leave()
  end
end

return class