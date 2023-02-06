local screen = require("screen")
local audio = require("audio")
local keybinding = require("solo/keybinding")
local gameInfo = require("gameInfo")
local level = require("solo/level")
local font = require("font")
local animation = require("animation")
local skins = require("solo/skins")

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

--Load
function class.load()
  initVar()
end

--Load Waiting Screen
function class.loadWaiting()
  data.waiting = {}

  --Get Actual Level Stage
  data.waiting.actualStage = level.getStage()

  --Audio
  love.audio.stop()
  local audioData = audio.getMenuWaitingAudio()
  audioData.music.source:play()

  --Timer (waiting screen duration)
  data.waiting.timer = 0
  data.waiting.timerMax = 4
end

--Update Waiting Screen
function class.updateWaiting(dt)
  if (data.waiting.timer > data.waiting.timerMax) then
    level.playMusic()
    gameInfo.setGamestate("solo_playing")
  else
    data.waiting.timer = data.waiting.timer + dt
  end
end

--Draw Waiting Screen
function class.drawWaiting()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 0, 0, screen.getWidth(), screen.getHeight())
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font.getFont("fontWhite"))
  if (data.waiting.actualStage == 1) then
    love.graphics.printf("good luck and have fun !", 0, screen.getHeight()/2-font.getFont("fontWhite"):getHeight()/2-100, screen.getWidth(), 'center')
  else
    love.graphics.printf("well played !", 0, screen.getHeight()/2-font.getFont("fontWhite"):getHeight()/2-150, screen.getWidth(), 'center')
    love.graphics.printf("you get 1000 score points", 0, screen.getHeight()/2-font.getFont("fontWhite"):getHeight()/2-100, screen.getWidth(), 'center')
  end
  love.graphics.printf("stage : " .. data.waiting.actualStage, 0, screen.getHeight()/2-font.getFont("fontWhite"):getHeight()/2, screen.getWidth(), 'center')
end

--Play
local function play()
  class.load()
  level.initVar()
  level.load(level.getStage())
  class.loadWaiting()
  gameInfo.setGamestate("solo_menu_waiting")
end

--Go to Skins
local function goToSkins()
  class.load()
  class.loadSkins()
  gameInfo.setGamestate("solo_menu_skins")
end

--Go to Options
local function goToOptions()
  class.load()
  class.loadOptions()
  gameInfo.setGamestate("solo_menu_options")
end

--Leave the solo
local function leave()
  data.main.leave = true
end

--Back to main menu
local function backToMain()
  class.load()
  class.loadMain()
  gameInfo.setGamestate("solo_menu_main")
end

--Load Gameover Menu
function class.loadGameover()
  data.gameover = {}

  --Audio
  love.audio.stop()
  local audioData = audio.getGameoverAudio()
  audioData.music.source:play()

  --Get Player Score
  data.gameover.score = level.getData().score

  --Get Player DieReason
  data.gameover.dieReason = level.getData().dieReason

  --Menu Draw Information
  data.gameover.alpha = 0
  data.gameover.backgroundAlpha = 0

  --Images
  data.gameover.title = love.graphics.newImage('Assets/Images/Gameover.png')
  data.gameover.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animations
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.gameover.arrow:getWidth()/7, data.gameover.arrow:getHeight()
  data.gameover.arrowAnim = animation.new(data.gameover.arrow, frame, framerate, x, y, w, h)

  --Buttons Creation
  local buttons = {}
  local offsetX = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2, screen.getHeight()/2 - buttons.h/2 + 200
  createButton(nil, "retry", buttons.x-offsetX-150, buttons.y, buttons.w, buttons.h, 0, play)
  createButton(nil, "main menu", buttons.x+offsetX, buttons.y, buttons.w, buttons.h, 0, backToMain)

  --Buttons Information
  data.gameover.selectedButtonId = 1
  data.gameover.buttonSelected = false
end

--Update Gameover Menu
function class.updateGameover(dt)
  if (data.gameover.alpha < 1) then
    data.gameover.alpha = data.gameover.alpha + dt/4
    if (data.gameover.alpha < 0.7) then
      data.gameover.backgroundAlpha = data.gameover.alpha
    elseif (data.gameover.backgroundAlpha ~= 0.7) then
      data.gameover.backgroundAlpha = 0.7
    end
  elseif (data.gameover.alpha ~= 1) then
    data.gameover.alpha = 1
  end
  animation.updateTimer(data.gameover.arrowAnim, dt)
  if (data.gameover.buttonSelected) then
    if (buttonsList[data.gameover.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.gameover.selectedButtonId].alpha > 0) then
        buttonsList[data.gameover.selectedButtonId].alpha = 0
      elseif (buttonsList[data.gameover.selectedButtonId].alpha == 0) then
        buttonsList[data.gameover.selectedButtonId].alpha = 1
      end
      buttonsList[data.gameover.selectedButtonId].alphaRepeatTime = buttonsList[data.gameover.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.gameover.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.gameover.selectedButtonId].func()
        return;
      end
      buttonsList[data.gameover.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.gameover.selectedButtonId].alphaTimer = buttonsList[data.gameover.selectedButtonId].alphaTimer + dt
    end
  else
    for buttonId, button in ipairs(buttonsList) do
      button.alpha = data.gameover.alpha
    end
  end
end

--Draw Gameover Menu
function class.drawGameover()
  love.graphics.setColor(0.2, 0.2, 0.2, data.gameover.backgroundAlpha)
  love.graphics.rectangle('fill', screen.getWidth()/2-600, screen.getHeight()/2-200, 1200, 400)
  love.graphics.setColor(1, 1, 1, data.gameover.alpha)
  love.graphics.draw(data.gameover.title, screen.getWidth()/2-data.gameover.title:getWidth()/2, screen.getHeight()/2-data.gameover.title:getHeight()/2-100)
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf({"reason : ", data.gameover.dieReason}, 0, screen.getHeight()/2, screen.getWidth(), 'center')
  love.graphics.printf({"your score : ", data.gameover.score}, 0, screen.getHeight()/2 + 75, screen.getWidth(), 'center')
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y, button.w, 'left')
    if (data.gameover.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1, data.gameover.alpha)
      animation.draw(data.gameover.arrowAnim, button.x, button.y, 50)
    end
  end
end

--Key pressed function in Gameover menu
function class.keypressedGameover(key)
  if not (data.gameover.buttonSelect) then
    if (key == 'left') then
      data.gameover.selectedButtonId = data.gameover.selectedButtonId - 1
      if (data.gameover.selectedButtonId < 1) then
        data.gameover.selectedButtonId = #buttonsList
      end
    elseif (key == 'right') then
      data.gameover.selectedButtonId = data.gameover.selectedButtonId + 1
      if (data.gameover.selectedButtonId > #buttonsList) then
        data.gameover.selectedButtonId = 1
      end
    elseif (key == 'return') then
      data.gameover.buttonSelected = true
    end
  end
  if (key == 'escape') then
    backToMain()
  end
end



--Load Win Menu
function class.loadWin()
  data.win = {}

  --Get Player Info
  data.win.bomb = level.getData().winBomb
  data.win.crate = level.getData().winCrate
  data.win.enemies = level.getData().winEnemies
  data.win.nbLevels = level.getData().winLevels
  data.win.score = level.getData().score

  --Audio
  love.audio.stop()
  local audioData = audio.getWinAudio()
  audioData.music.source:play()

  --Images
  data.win.background = love.graphics.newImage('Assets/Images/WinBackground.jpg')
  data.win.title = love.graphics.newImage('Assets/Images/WinTitle.png')
  data.win.hideTitle = love.graphics.newImage('Assets/Images/WinHideTitle.jpg')
  data.win.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Animations
  local frame, framerate, x, y, w, h = 7, 7, 0, 0, 494, 131
  data.win.titleAnim = animation.new(data.win.title, frame, framerate, x, y, w, h)
  data.win.titleX, data.win.titleY = -(data.win.title:getWidth()/7), screen.getHeight()/4 - 65

  --Arrow Animations
  frame, framerate, x, y, w, h = 7, 12, 0, 0, data.win.arrow:getWidth()/7, data.win.arrow:getHeight()
  data.win.arrowAnim = animation.new(data.win.arrow, frame, framerate, x, y, w, h)

  --Win Menu Animations General
  data.win.animEnd = false
  data.win.alpha1 = 0
  data.win.alpha2 = 0
  data.win.hideTitleX, data.win.hideTitleY = 0, 204
  data.win.hideTitleAlpha = 0
  data.win.titleXFinal = screen.getWidth()/2 - (data.win.title:getWidth()/7)/2

  --Buttons Creation
  local buttons = {}
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight() - buttons.h - 25
  createButton(nil, "main menu", buttons.x, buttons.y, buttons.w, buttons.h, 1, backToMain)

  --Buttons Information
  data.win.selectedButtonId = 1
  data.win.buttonSelected = false
end

--Update Win Menu
function class.updateWin(dt)
  animation.updateTimer(data.win.titleAnim, dt)
  animation.updateTimer(data.win.arrowAnim, dt)
  if not (data.win.animEnd) then
    if (data.win.alpha1 < 1) then
      data.win.alpha1 = data.win.alpha1 + dt
    elseif (data.win.alpha1 > 1) then
      if (data.win.hideTitleAlpha == 0) then
        data.win.hideTitleAlpha = 1
      end
      if (data.win.titleX < data.win.titleXFinal) then
        data.win.titleX = data.win.titleX + 1000 * dt
      else
        if (data.win.alpha2 < 1) then
          data.win.alpha2 = data.win.alpha2 + dt
        else
          data.win.animEnd = true
        end
      end
    end
  end
  if (data.win.buttonSelected) then
    if (buttonsList[data.win.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.win.selectedButtonId].alpha > 0) then
        buttonsList[data.win.selectedButtonId].alpha = 0
      elseif (buttonsList[data.win.selectedButtonId].alpha == 0) then
        buttonsList[data.win.selectedButtonId].alpha = 1
      end
      buttonsList[data.win.selectedButtonId].alphaRepeatTime = buttonsList[data.win.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.win.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.win.selectedButtonId].func()
        return;
      end
      buttonsList[data.win.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.win.selectedButtonId].alphaTimer = buttonsList[data.win.selectedButtonId].alphaTimer + dt
    end
  end
end

--Draw Win Menu
function class.drawWin()
  love.graphics.setColor(1, 1, 1, data.win.alpha1)
  love.graphics.draw(data.win.background)
  for buttonId, button in ipairs(buttonsList) do
    if (data.win.alpha1 >= 1) then
      love.graphics.setColor(1, 1, 1, button.alpha)
    end
    love.graphics.setFont(font.getFont("fontWhite"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.win.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1, data.win.alpha1)
      animation.draw(data.win.arrowAnim, button.x, button.y, 40, data.win.arrow:getHeight()/2 - button.h/2)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
  animation.draw(data.win.titleAnim, data.win.titleX, data.win.titleY)
  love.graphics.setColor(1, 1, 1, data.win.hideTitleAlpha)
  love.graphics.draw(data.win.hideTitle, data.win.hideTitleX, data.win.hideTitleY)
  love.graphics.setColor(1, 1, 1, data.win.alpha2)
  love.graphics.setFont(font.getFont("fontBlack"))
  love.graphics.printf({"your score : ", data.win.score}, screen.getWidth()/2 - 250, screen.getHeight()/3 - font.getFont("fontWhite"):getHeight()/2 + 50, screen.getWidth(), 'left')
  love.graphics.printf({"killed enemies : ", data.win.enemies}, screen.getWidth()/2 - 250, screen.getHeight()/3 - font.getFont("fontWhite"):getHeight()/2 + 150, screen.getWidth(), 'left')
  love.graphics.printf({"placed bombs : ", data.win.bomb}, screen.getWidth()/2 - 250, screen.getHeight()/3 - font.getFont("fontWhite"):getHeight()/2 + 250, screen.getWidth(), 'left')
  love.graphics.printf({"exploding crate : ", data.win.crate}, screen.getWidth()/2 - 250, screen.getHeight()/3 - font.getFont("fontWhite"):getHeight()/2 + 350, screen.getWidth(), 'left')
  love.graphics.printf({"stages cleared : ", data.win.nbLevels}, screen.getWidth()/2 - 250, screen.getHeight()/3 - font.getFont("fontWhite"):getHeight()/2 + 450, screen.getWidth(), 'left')
end

--Key pressed function in Win menu
function class.keypressedWin(key)
  if not (data.win.buttonSelect) then
    if (key == 'return') then
      data.win.buttonSelected = true
    end
  end
  if (key == 'escape') then
    backToMain()
  end
end




function class.getLeave()
  return data.main.leave
end

--Load Main Menu
function class.loadMain()
  data.main = {}

  --Audio
  if not (gameInfo.getGamestate() == "menu_main") then
    love.audio.stop()
    local audioData = audio.getMenuMainAudio()
    audio.getMenuMainAudio().music.source:play()
  end

  data.main.leave = false

  --Player Score
  data.main.score = level.getData().score

  --Images
  data.main.backgroundLeave = love.graphics.newImage('Assets/Images/MainBackgroundLeave.jpg')
  data.main.backgroundPlay = love.graphics.newImage('Assets/Images/MainBackgroundPlay.jpg')
  data.main.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.main.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.main.arrow:getWidth()/7, data.main.arrow:getHeight()
  data.main.arrowAnim = animation.new(data.main.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 125
  createButton(nil, "play", buttons.x, buttons.y-(offsetY*1.5), buttons.w, buttons.h, 1, play)
  createButton(nil, "skins", buttons.x, buttons.y-(offsetY*0.5), buttons.w, buttons.h, 1, goToSkins)
  createButton(nil, "options", buttons.x, buttons.y+(offsetY*0.5), buttons.w, buttons.h, 1, goToOptions)
  createButton(nil, "leave", buttons.x, buttons.y+(offsetY*1.5), buttons.w, buttons.h, 1, leave)

  --Buttons Information
  data.main.buttonSelect = false
  data.main.selectedButtonId = 1
end

--Update Main Menu
function class.updateMain(dt)
  animation.updateTimer(data.main.arrowAnim, dt)
  if (data.main.buttonSelect) then
    if (buttonsList[data.main.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.main.selectedButtonId].alpha == 1) then
        buttonsList[data.main.selectedButtonId].alpha = 0
      elseif (buttonsList[data.main.selectedButtonId].alpha == 0) then
        buttonsList[data.main.selectedButtonId].alpha = 1
      end
      buttonsList[data.main.selectedButtonId].alphaRepeatTime = buttonsList[data.main.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.main.selectedButtonId].alphaRepeatTime > 8) then
        buttonsList[data.main.selectedButtonId].func()
        return;
      end
      buttonsList[data.main.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.main.selectedButtonId].alphaTimer = buttonsList[data.main.selectedButtonId].alphaTimer + dt
    end
  end
end

--Draw Main Menu
function class.drawMain()
  love.graphics.setColor(1, 1, 1)
  if (data.main.selectedButtonId == 1) then
    love.graphics.draw(data.main.backgroundPlay)
  elseif (data.main.selectedButtonId == 2 or data.main.selectedButtonId == 3) then
    love.graphics.draw(data.main.backgroundOptions)
  elseif (data.main.selectedButtonId == 4) then
    love.graphics.draw(data.main.backgroundLeave)
  end
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf("singleplayer", 0, 50, screen.getWidth(), 'center')
  if (gameInfo.getLastlevel() == "10") then
    love.graphics.printf("level 10 : activate", screen.getWidth()/2 + 200, screen.getHeight()/2 + 25, screen.getWidth(), "left")
  elseif (gameInfo.getLastlevel() == "last") then
    love.graphics.printf("last level : activate", screen.getWidth()/2 + 200, screen.getHeight()/2 + 25, screen.getWidth(), "left")
  end
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.main.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.main.arrowAnim, button.x, button.y, 40, data.main.arrow:getHeight()/2 - button.h/2)
      if (buttonId == 1) then
        if (data.main.score ~= nil) then
          love.graphics.setFont(font.getFont("fontWhite"))
          love.graphics.printf({"previous score : ", data.main.score}, 0, screen.getHeight()/2 - font.getFont("fontWhite"):getHeight()/2 - 75, screen.getWidth(), 'center')
        end
      end
    end
  end
end

--Key pressed function in Main menu
function class.keypressedMain(key)
  if not (data.main.buttonSelect) then
    if (key == 'up') then
      data.main.selectedButtonId = data.main.selectedButtonId - 1
      if (data.main.selectedButtonId < 1) then
        data.main.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.main.selectedButtonId = data.main.selectedButtonId + 1
      if (data.main.selectedButtonId > #buttonsList) then
        data.main.selectedButtonId = 1
      end
    elseif (key == 'return') then
      if (data.main.selectedButtonId == 1) then
        data.main.buttonSelect = true
      else
        buttonsList[data.main.selectedButtonId].func()
      end
    end
  end
end


--Go to Audio Options
local function goToAudioOptions()
  class.load()
  class.loadAudioOptions()
  gameInfo.setGamestate("solo_menu_audioOptions")
end

--Go to Keybinding Options
local function goToKeybindingOptions()
  class.load()
  class.loadKeybindingOptions()
  gameInfo.setGamestate("solo_menu_keybindingOptions")
end

--Load Options Menu
function class.loadOptions()
  data.options = {}

  --Images
  data.options.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.options.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.options.arrow:getWidth()/7, data.options.arrow:getHeight()
  data.options.arrowAnim = animation.new(data.options.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "audio", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, goToAudioOptions)
  createButton(nil, "keybinding", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, goToKeybindingOptions)

  --Buttons Information
  data.options.selectedButtonId = 1
end

--Update Options Menu
function class.updateOptions(dt)
  animation.updateTimer(data.options.arrowAnim, dt)
end

--Draw Options Menu
function class.drawOptions()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.options.backgroundOptions)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.options.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.options.arrowAnim, button.x, button.y, 40, data.options.arrow:getHeight()/2 - button.h/2)
    end
  end
end

--Key pressed function in Options menu
function class.keypressedOptions(key)
  if (key == 'up') then
    data.options.selectedButtonId = data.options.selectedButtonId - 1
    if (data.options.selectedButtonId < 1) then
      data.options.selectedButtonId = #buttonsList
    end
  elseif (key == 'down') then
    data.options.selectedButtonId = data.options.selectedButtonId + 1
    if (data.options.selectedButtonId > #buttonsList) then
      data.options.selectedButtonId = 1
    end
  elseif (key == 'return') then
    buttonsList[data.options.selectedButtonId].func()
  end
  if (key == 'escape') then
    backToMain()
  end
end

--Select Volume Button
local function selectVolumeButton()
  if (data.audioOptions.volumeSelected) then
    data.audioOptions.volumeSelected = false
  else
    data.audioOptions.volumeSelected = true
  end
end

--Change Activated Audio state
--Music
local function changeAudioMusicState()
  audio.changeActiveAudio("music")
end
--Sound Effect
local function changeAudioSoundEffectState()
  audio.changeActiveAudio("soundEffect")
end

--Load Audio Options Menu
function class.loadAudioOptions()
  data.audioOptions = {}

  --Images
  data.audioOptions.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.audioOptions.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.audioOptions.arrow:getWidth()/7, data.audioOptions.arrow:getHeight()
  data.audioOptions.arrowAnim = animation.new(data.audioOptions.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "volume", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, selectVolumeButton)
  createButton(nil, "music", buttons.x, buttons.y, buttons.w, buttons.h, 1, changeAudioMusicState)
  createButton(nil, "sound effect", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, changeAudioSoundEffectState)
  data.audioOptions.volumeInfoX = buttons.x + buttons.w
  data.audioOptions.volumeInfoY = buttons.y - offsetY + buttons.h/2 - 17
  data.audioOptions.musicInfoX = buttons.x + buttons.w
  data.audioOptions.musicInfoY = buttons.y + buttons.h/2 - 17
  data.audioOptions.soundEffectInfoX = buttons.x + buttons.w
  data.audioOptions.soundEffectInfoY = buttons.y + offsetY + buttons.h/2 - 17

  --Buttons Information
  data.audioOptions.selectedButtonId = 1
  data.audioOptions.volumeSelected = false
  data.audioOptions.volumeTimer = 0
  data.audioOptions.volumeTimerLimit = 0.2
  data.audioOptions.volumeTimerRepeat = 0
  data.audioOptions.volumeTimerRepeatLimit = 10
end

--Update Audio Options Menu
function class.updateAudioOptions(dt)
  animation.updateTimer(data.audioOptions.arrowAnim, dt)
  if (data.audioOptions.volumeSelected) then
    if (love.keyboard.isDown('left')) then
      if (audio.getVolume() > 0) then
        if (data.audioOptions.volumeTimer > data.audioOptions.volumeTimerLimit) then
          audio.setVolume(audio.getVolume() - 1)
          data.audioOptions.volumeTimer = 0
          data.audioOptions.volumeTimerRepeat = data.audioOptions.volumeTimerRepeat + 1
          if (data.audioOptions.volumeTimerRepeat == data.audioOptions.volumeTimerRepeatLimit) then
            data.audioOptions.volumeTimerLimit =  data.audioOptions.volumeTimerLimit / 2
            data.audioOptions.volumeTimerRepeatLimit = 40
          end
        else
          data.audioOptions.volumeTimer = data.audioOptions.volumeTimer + dt
        end
      end
    elseif (love.keyboard.isDown('right')) then
      if (audio.getVolume() < 100) then
        if (data.audioOptions.volumeTimer > data.audioOptions.volumeTimerLimit) then
          audio.setVolume(audio.getVolume() + 1)
          data.audioOptions.volumeTimer = 0
          data.audioOptions.volumeTimerRepeat = data.audioOptions.volumeTimerRepeat + 1
          if (data.audioOptions.volumeTimerRepeat == data.audioOptions.volumeTimerRepeatLimit) then
            data.audioOptions.volumeTimerLimit =  data.audioOptions.volumeTimerLimit / 2
            data.audioOptions.volumeTimerRepeatLimit = 40
          end
        else
          data.audioOptions.volumeTimer = data.audioOptions.volumeTimer + dt
        end
      end
    else
      data.audioOptions.volumeTimerRepeat = 0
      data.audioOptions.volumeTimerRepeatLimit = 10
      data.audioOptions.volumeTimerLimit = 0.2
    end
  end
end


--Draw Audio Options Menu
function class.drawAudioOptions()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.audioOptions.backgroundOptions)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.audioOptions.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.audioOptions.arrowAnim, button.x, button.y, 40, data.audioOptions.arrow:getHeight()/2 - button.h/2)
    end
  end
  local audioDataActive = audio.getActivatedAudio()
  local audioVolume = audio.getVolume()
  if (data.audioOptions.volumeSelected) then
    love.graphics.print({"< ", audioVolume, " >"}, data.audioOptions.volumeInfoX, data.audioOptions.volumeInfoY)
  else
    love.graphics.print({": ", audioVolume}, data.audioOptions.volumeInfoX, data.audioOptions.volumeInfoY)
  end
  if (audioDataActive.music) then
    love.graphics.print(": on", data.audioOptions.musicInfoX, data.audioOptions.musicInfoY)
  else
    love.graphics.print(": off", data.audioOptions.musicInfoX, data.audioOptions.musicInfoY)
  end
  if (audioDataActive.soundEffect) then
    love.graphics.print(": on", data.audioOptions.soundEffectInfoX, data.audioOptions.soundEffectInfoY)
  else
    love.graphics.print(": off", data.audioOptions.soundEffectInfoX, data.audioOptions.soundEffectInfoY)
  end
end

--Key pressed function in Audio Options menu
function class.keypressedAudioOptions(key)
  if not (data.audioOptions.volumeSelected) then
    if (key == 'up') then
      data.audioOptions.selectedButtonId = data.audioOptions.selectedButtonId - 1
      if (data.audioOptions.selectedButtonId < 1) then
        data.audioOptions.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.audioOptions.selectedButtonId = data.audioOptions.selectedButtonId + 1
      if (data.audioOptions.selectedButtonId > #buttonsList) then
        data.audioOptions.selectedButtonId = 1
      end
    end
  end
  if (key == 'return') then
    buttonsList[data.audioOptions.selectedButtonId].func()
  end
  if (key == 'escape') then
    if (data.audioOptions.volumeSelected) then
      data.audioOptions.volumeSelected = false
    else
      goToOptions()
    end
  end
end



--Selected Key To Modify
local function selectedKeyToModify()
  if (data.keybindingOptions.keySelected) then
    data.keybindingOptions.keySelected = false
  else
    data.keybindingOptions.keySelected = true
  end
end

--Reset Keybinding
local function resetKeyBinding()
  keybinding.resetBinding()
end


--Load Keybinding Options Menu
function class.loadKeybindingOptions()
  data.keybindingOptions = {}

  --Images
  data.keybindingOptions.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.keybindingOptions.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.keybindingOptions.arrow:getWidth()/7, data.keybindingOptions.arrow:getHeight()
  data.keybindingOptions.arrowAnim = animation.new(data.keybindingOptions.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "up", buttons.x, buttons.y-(offsetY*2.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "down", buttons.x, buttons.y-(offsetY*1.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "left", buttons.x, buttons.y-(offsetY*0.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "right", buttons.x, buttons.y+(offsetY*0.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "bomb", buttons.x, buttons.y+(offsetY*1.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "detonate", buttons.x, buttons.y+(offsetY*2.5), buttons.w, buttons.h, 1, selectedKeyToModify)
  createButton(nil, "reset all bindings", buttons.x-100, buttons.y+(offsetY*6), 600, buttons.h, 1, resetKeyBinding)
  data.keybindingOptions.InfoX = buttons.x + buttons.w
  data.keybindingOptions.upInfoY = buttons.y - (offsetY*2.5) + buttons.h/2 - 17
  data.keybindingOptions.downInfoY = buttons.y - (offsetY*1.5) + buttons.h/2 - 17
  data.keybindingOptions.leftInfoY = buttons.y - (offsetY*0.5) + buttons.h/2 - 17
  data.keybindingOptions.rightInfoY = buttons.y + (offsetY*0.5) + buttons.h/2 - 17
  data.keybindingOptions.bombInfoY = buttons.y + (offsetY*1.5) + buttons.h/2 - 17
  data.keybindingOptions.detonateInfoY = buttons.y + (offsetY*2.5) + buttons.h/2 - 17


  --Buttons Information
  data.keybindingOptions.selectedButtonId = 1
  data.keybindingOptions.keySelected = false

  --Error Message
  data.keybindingOptions.error = false
  data.keybindingOptions.errorText = "This key is already used !"
  data.keybindingOptions.errorY = screen.getHeight()/2 - font.getFont("font40"):getHeight()/2 - 75
  data.keybindingOptions.errorTimer = 0  

end

--Update Audio Options Menu
function class.updateKeybindingOptions(dt)
  animation.updateTimer(data.keybindingOptions.arrowAnim, dt)
  if (data.keybindingOptions.error) then
    if (data.keybindingOptions.errorTimer > 1) then
      data.keybindingOptions.error = false
    else
      data.keybindingOptions.errorTimer = data.keybindingOptions.errorTimer + dt
    end
  end
end

--Draw Keybinding Options Menu
function class.drawKeybindingOptions()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.keybindingOptions.backgroundOptions)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    if (buttonId ~= #buttonsList) then
      love.graphics.setFont(font.getFont("fontBlack"))
    else
      love.graphics.setFont(font.getFont("fontWhite"))
    end
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.keybindingOptions.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.keybindingOptions.arrowAnim, button.x, button.y, 40, data.keybindingOptions.arrow:getHeight()/2 - button.h/2)
    end
  end
  local keyBind = keybinding.getKey()
  love.graphics.setFont(font.getFont("fontBlack"))
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 1) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.upInfoY)
  else
    love.graphics.print({": ", keyBind.up}, data.keybindingOptions.InfoX, data.keybindingOptions.upInfoY)
  end
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 2) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.downInfoY)
  else
    love.graphics.print({": ", keyBind.down}, data.keybindingOptions.InfoX, data.keybindingOptions.downInfoY)
  end
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 3) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.leftInfoY)
  else
    love.graphics.print({": ", keyBind.left}, data.keybindingOptions.InfoX, data.keybindingOptions.leftInfoY)
  end
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 4) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.rightInfoY)
  else
    love.graphics.print({": ", keyBind.right}, data.keybindingOptions.InfoX, data.keybindingOptions.rightInfoY)
  end
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 5) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.bombInfoY)
  else
    love.graphics.print({": ", keyBind.bomb}, data.keybindingOptions.InfoX, data.keybindingOptions.bombInfoY)
  end
  if (data.keybindingOptions.keySelected and data.keybindingOptions.selectedButtonId == 6) then
    love.graphics.print(": ...", data.keybindingOptions.InfoX, data.keybindingOptions.detonateInfoY)
  else
    love.graphics.print({": ", keyBind.detonate}, data.keybindingOptions.InfoX, data.keybindingOptions.detonateInfoY)
  end
  if (data.keybindingOptions.error) then
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(font.getFont("font40"))
    love.graphics.printf(data.keybindingOptions.errorText, 0, data.keybindingOptions.errorY, screen.getWidth(), 'center')
  end
end

--Key pressed function in Keybinding Options menu
function class.keypressedKeybindingOptions(key)
  if (data.keybindingOptions.keySelected) then
    if (keybinding.changeBinding(buttonsList[data.keybindingOptions.selectedButtonId].text, key)) then
      data.keybindingOptions.errorTimer = 0
      data.keybindingOptions.error = true
    end
    buttonsList[data.keybindingOptions.selectedButtonId].func()
  else
    if (key == 'up') then
      data.keybindingOptions.selectedButtonId = data.keybindingOptions.selectedButtonId - 1
      if (data.keybindingOptions.selectedButtonId < 1) then
        data.keybindingOptions.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.keybindingOptions.selectedButtonId = data.keybindingOptions.selectedButtonId + 1
      if (data.keybindingOptions.selectedButtonId > #buttonsList) then
        data.keybindingOptions.selectedButtonId = 1
      end
    end
    if (key == 'return') then
      buttonsList[data.keybindingOptions.selectedButtonId].func()
    end
    if (key == 'escape') then
      goToOptions()
    end
  end
end



--Resume Pause Menu
local function resumePause()
  gameInfo.setGamestate("solo_playing")
end

--Go To Pause Options Menu
local function goToPauseOptions(titleColor, titleColorDir)
  class.load()
  class.loadPauseOptions(titleColor, titleColorDir)
  gameInfo.setGamestate("solo_menu_pauseOptions")
end

--Load Pause Menu
function class.loadPause(titleColor, titleColorDir)
  data.pause = {}

  --Images
  data.pause.title = love.graphics.newImage('Assets/Images/PauseTitle.png')
  data.pause.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Info
  data.pause.titleX = screen.getWidth()/2 - data.pause.title:getWidth()/2
  data.pause.titleY = screen.getHeight()/3 - 200
  data.pause.titleColor = titleColor or 1
  data.pause.titleColorDir = titleColorDir or "up"

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.pause.arrow:getWidth()/7, data.pause.arrow:getHeight()
  data.pause.arrowAnim = animation.new(data.pause.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 150
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2
  createButton(nil, "resume", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, resumePause)
  createButton(nil, "options", buttons.x, buttons.y, buttons.w, buttons.h, 1, goToPauseOptions)
  createButton(nil, "main menu", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, backToMain)

  --Buttons Information
  data.pause.selectedButtonId = 1
end

--Update Pause Menu
function class.updatePause(dt)
  animation.updateTimer(data.pause.arrowAnim, dt)
  if (data.pause.titleColorDir == "up") then
    if (data.pause.titleColor < 1) then
      data.pause.titleColor = data.pause.titleColor + dt/4
    else
      data.pause.titleColorDir = "down"
    end
  elseif (data.pause.titleColorDir == "down") then
    if (data.pause.titleColor > 0.5) then
      data.pause.titleColor = data.pause.titleColor - dt/4
    else
      data.pause.titleColorDir = "up"
    end
  end
end

--Draw Pause Menu
function class.drawPause()
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle('fill', 0, 0, 1920, 1080)

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', data.pause.titleX, data.pause.titleY, 707, 600)

  love.graphics.setColor(data.pause.titleColor, data.pause.titleColor, data.pause.titleColor)
  love.graphics.draw(data.pause.title, data.pause.titleX, data.pause.titleY)

  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontWhite"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.pause.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.pause.arrowAnim, button.x, button.y, 40, data.pause.arrow:getHeight()/2 - button.h/2)
    end
  end
end

--Keypressed Pause Menu
function class.keypressedPause(key)
  if (key == 'up') then
    data.pause.selectedButtonId = data.pause.selectedButtonId - 1
    if (data.pause.selectedButtonId < 1) then
      data.pause.selectedButtonId = #buttonsList
    end
  elseif (key == 'down') then
    data.pause.selectedButtonId = data.pause.selectedButtonId + 1
    if (data.pause.selectedButtonId > #buttonsList) then
      data.pause.selectedButtonId = 1
    end
  end
  if (key == 'return') then
    if (data.pause.selectedButtonId == 2) then
      buttonsList[data.pause.selectedButtonId].func(data.pause.titleColor, data.pause.titleColorDir)
    else
      buttonsList[data.pause.selectedButtonId].func()
    end
  end
  if (key == 'escape') then
    resumePause()
  end
end




--Back to Pause Menu
local function backToPause(titleColor, titleColorDir)
  class.load()
  class.loadPause(titleColor, titleColorDir)
  gameInfo.setGamestate("solo_menu_pause")
end

--Go to Audio Options
local function goToPauseAudioOptions(titleColor, titleColorDir)
  class.load()
  class.loadPauseAudioOptions(titleColor, titleColorDir)
  gameInfo.setGamestate("solo_menu_pauseAudioOptions")
end

--Go to Keybinding Options
local function goToPauseKeybindingOptions(titleColor, titleColorDir)
  class.load()
  class.loadPauseKeybindingOptions(titleColor, titleColorDir)
  gameInfo.setGamestate("solo_menu_pauseKeybindingOptions")
end

--Load Options Menu
function class.loadPauseOptions(titleColor, titleColorDir)
  data.pauseOptions = {}

  --Images
  data.pauseOptions.titlePause = love.graphics.newImage('Assets/Images/PauseTitle.png')
  data.pauseOptions.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Info
  data.pauseOptions.titleX = screen.getWidth()/2 - data.pauseOptions.titlePause:getWidth()/2
  data.pauseOptions.titleY = screen.getHeight()/3 - 200
  data.pauseOptions.titleColor = titleColor
  data.pauseOptions.titleColorDir = titleColorDir

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.pauseOptions.arrow:getWidth()/7, data.pauseOptions.arrow:getHeight()
  data.pauseOptions.arrowAnim = animation.new(data.pauseOptions.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2
  createButton(nil, "audio", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, goToPauseAudioOptions)
  createButton(nil, "keybinding", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, goToPauseKeybindingOptions)

  --Buttons Information
  data.pauseOptions.selectedButtonId = 1
end

--Update Options Menu
function class.updatePauseOptions(dt)
  animation.updateTimer(data.pauseOptions.arrowAnim, dt)
  if (data.pauseOptions.titleColorDir == "up") then
    if (data.pauseOptions.titleColor < 1) then
      data.pauseOptions.titleColor = data.pauseOptions.titleColor + dt/4
    else
      data.pauseOptions.titleColorDir = "down"
    end
  elseif (data.pauseOptions.titleColorDir == "down") then
    if (data.pauseOptions.titleColor > 0.5) then
      data.pauseOptions.titleColor = data.pauseOptions.titleColor - dt/4
    else
      data.pauseOptions.titleColorDir = "up"
    end
  end
end

--Draw Options Menu
function class.drawPauseOptions()
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle('fill', 0, 0, 1920, 1080)

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', data.pauseOptions.titleX, data.pauseOptions.titleY, 707, 600)

  love.graphics.setColor(data.pauseOptions.titleColor, data.pauseOptions.titleColor, data.pauseOptions.titleColor)
  love.graphics.draw(data.pauseOptions.titlePause, data.pauseOptions.titleX, data.pauseOptions.titleY)

  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontWhite"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.pauseOptions.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.pauseOptions.arrowAnim, button.x, button.y, 40, data.pauseOptions.arrow:getHeight()/2 - button.h/2)
    end
  end
end

--Key pressed function in Options menu
function class.keypressedPauseOptions(key)
  if (key == 'up') then
    data.pauseOptions.selectedButtonId = data.pauseOptions.selectedButtonId - 1
    if (data.pauseOptions.selectedButtonId < 1) then
      data.pauseOptions.selectedButtonId = #buttonsList
    end
  elseif (key == 'down') then
    data.pauseOptions.selectedButtonId = data.pauseOptions.selectedButtonId + 1
    if (data.pauseOptions.selectedButtonId > #buttonsList) then
      data.pauseOptions.selectedButtonId = 1
    end
  elseif (key == 'return') then
    buttonsList[data.pauseOptions.selectedButtonId].func(data.pauseOptions.titleColor, data.pauseOptions.titleColorDir)
  end
  if (key == 'escape') then
    backToPause(data.pauseOptions.titleColor, data.pauseOptions.titleColorDir)
  end
end


--Select Volume Button
local function pauseSelectVolumeButton()
  if (data.pauseAudioOptions.volumeSelected) then
    data.pauseAudioOptions.volumeSelected = false
  else
    data.pauseAudioOptions.volumeSelected = true
  end
end

--Load Audio Options Menu
function class.loadPauseAudioOptions(titleColor, titleColorDir)
  data.pauseAudioOptions = {}

  --Images
  data.pauseAudioOptions.titlePause = love.graphics.newImage('Assets/Images/PauseTitle.png')
  data.pauseAudioOptions.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Info
  data.pauseAudioOptions.titleX = screen.getWidth()/2 - data.pauseAudioOptions.titlePause:getWidth()/2
  data.pauseAudioOptions.titleY = screen.getHeight()/3 - 200
  data.pauseAudioOptions.titleColor = titleColor
  data.pauseAudioOptions.titleColorDir = titleColorDir

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.pauseAudioOptions.arrow:getWidth()/7, data.pauseAudioOptions.arrow:getHeight()
  data.pauseAudioOptions.arrowAnim = animation.new(data.pauseAudioOptions.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2 - 50, screen.getHeight()/2 - buttons.h/2
  createButton(nil, "volume", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, pauseSelectVolumeButton)
  createButton(nil, "music", buttons.x, buttons.y, buttons.w, buttons.h, 1, changeAudioMusicState)
  createButton(nil, "sound effect", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, changeAudioSoundEffectState)
  data.pauseAudioOptions.volumeInfoX = buttons.x + buttons.w
  data.pauseAudioOptions.volumeInfoY = buttons.y - offsetY + buttons.h/2 - 17
  data.pauseAudioOptions.musicInfoX = buttons.x + buttons.w
  data.pauseAudioOptions.musicInfoY = buttons.y + buttons.h/2 - 17
  data.pauseAudioOptions.soundEffectInfoX = buttons.x + buttons.w
  data.pauseAudioOptions.soundEffectInfoY = buttons.y + offsetY + buttons.h/2 - 17

  --Buttons Information
  data.pauseAudioOptions.selectedButtonId = 1
  data.pauseAudioOptions.volumeSelected = false
  data.pauseAudioOptions.volumeTimer = 0
  data.pauseAudioOptions.volumeTimerLimit = 0.2
  data.pauseAudioOptions.volumeTimerRepeat = 0
  data.pauseAudioOptions.volumeTimerRepeatLimit = 10
end

--Update Audio Options Menu
function class.updatePauseAudioOptions(dt)
  animation.updateTimer(data.pauseAudioOptions.arrowAnim, dt)
  if (data.pauseAudioOptions.volumeSelected) then
    if (love.keyboard.isDown('left')) then
      if (audio.getVolume() > 0) then
        if (data.pauseAudioOptions.volumeTimer > data.pauseAudioOptions.volumeTimerLimit) then
          audio.setVolume(audio.getVolume() - 1)
          data.pauseAudioOptions.volumeTimer = 0
          data.pauseAudioOptions.volumeTimerRepeat = data.pauseAudioOptions.volumeTimerRepeat + 1
          if (data.pauseAudioOptions.volumeTimerRepeat == data.pauseAudioOptions.volumeTimerRepeatLimit) then
            data.pauseAudioOptions.volumeTimerLimit =  data.pauseAudioOptions.volumeTimerLimit / 2
            data.pauseAudioOptions.volumeTimerRepeatLimit = 40
          end
        else
          data.pauseAudioOptions.volumeTimer = data.pauseAudioOptions.volumeTimer + dt
        end
      end
    elseif (love.keyboard.isDown('right')) then
      if (audio.getVolume() < 100) then
        if (data.pauseAudioOptions.volumeTimer > data.pauseAudioOptions.volumeTimerLimit) then
          audio.setVolume(audio.getVolume() + 1)
          data.pauseAudioOptions.volumeTimer = 0
          data.pauseAudioOptions.volumeTimerRepeat = data.pauseAudioOptions.volumeTimerRepeat + 1
          if (data.pauseAudioOptions.volumeTimerRepeat == data.pauseAudioOptions.volumeTimerRepeatLimit) then
            data.pauseAudioOptions.volumeTimerLimit =  data.pauseAudioOptions.volumeTimerLimit / 2
            data.pauseAudioOptions.volumeTimerRepeatLimit = 40
          end
        else
          data.pauseAudioOptions.volumeTimer = data.pauseAudioOptions.volumeTimer + dt
        end
      end
    else
      data.pauseAudioOptions.volumeTimerRepeat = 0
      data.pauseAudioOptions.volumeTimerRepeatLimit = 10
      data.pauseAudioOptions.volumeTimerLimit = 0.2
    end
  end

  if (data.pauseAudioOptions.titleColorDir == "up") then
    if (data.pauseAudioOptions.titleColor < 1) then
      data.pauseAudioOptions.titleColor = data.pauseAudioOptions.titleColor + dt/4
    else
      data.pauseAudioOptions.titleColorDir = "down"
    end
  elseif (data.pauseAudioOptions.titleColorDir == "down") then
    if (data.pauseAudioOptions.titleColor > 0.5) then
      data.pauseAudioOptions.titleColor = data.pauseAudioOptions.titleColor - dt/4
    else
      data.pauseAudioOptions.titleColorDir = "up"
    end
  end
end


--Draw Audio Options Menu
function class.drawPauseAudioOptions()
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle('fill', 0, 0, 1920, 1080)

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', data.pauseAudioOptions.titleX, data.pauseAudioOptions.titleY, 707, 600)

  love.graphics.setColor(data.pauseAudioOptions.titleColor, data.pauseAudioOptions.titleColor, data.pauseAudioOptions.titleColor)
  love.graphics.draw(data.pauseAudioOptions.titlePause, data.pauseAudioOptions.titleX, data.pauseAudioOptions.titleY)

  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontWhite"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.pauseAudioOptions.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.pauseAudioOptions.arrowAnim, button.x, button.y, 40, data.pauseAudioOptions.arrow:getHeight()/2 - button.h/2)
    end
  end
  local audioDataActive = audio.getActivatedAudio()
  local audioVolume = audio.getVolume()
  if (data.pauseAudioOptions.volumeSelected) then
    love.graphics.print({"< ", audioVolume, " >"}, data.pauseAudioOptions.volumeInfoX, data.pauseAudioOptions.volumeInfoY)
  else
    love.graphics.print({": ", audioVolume}, data.pauseAudioOptions.volumeInfoX, data.pauseAudioOptions.volumeInfoY)
  end
  if (audioDataActive.music) then
    love.graphics.print(": on", data.pauseAudioOptions.musicInfoX, data.pauseAudioOptions.musicInfoY)
  else
    love.graphics.print(": off", data.pauseAudioOptions.musicInfoX, data.pauseAudioOptions.musicInfoY)
  end
  if (audioDataActive.soundEffect) then
    love.graphics.print(": on", data.pauseAudioOptions.soundEffectInfoX, data.pauseAudioOptions.soundEffectInfoY)
  else
    love.graphics.print(": off", data.pauseAudioOptions.soundEffectInfoX, data.pauseAudioOptions.soundEffectInfoY)
  end
end

--Key pressed function in Audio Options menu
function class.keypressedPauseAudioOptions(key)
  if not (data.pauseAudioOptions.volumeSelected) then
    if (key == 'up') then
      data.pauseAudioOptions.selectedButtonId = data.pauseAudioOptions.selectedButtonId - 1
      if (data.pauseAudioOptions.selectedButtonId < 1) then
        data.pauseAudioOptions.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.pauseAudioOptions.selectedButtonId = data.pauseAudioOptions.selectedButtonId + 1
      if (data.pauseAudioOptions.selectedButtonId > #buttonsList) then
        data.pauseAudioOptions.selectedButtonId = 1
      end
    end
  end
  if (key == 'return') then
    buttonsList[data.pauseAudioOptions.selectedButtonId].func()
  end
  if (key == 'escape') then
    if (data.pauseAudioOptions.volumeSelected) then
      data.pauseAudioOptions.volumeSelected = false
    else
      goToPauseOptions(data.pauseAudioOptions.titleColor, data.pauseAudioOptions.titleColorDir)
    end
  end
end



--Selected Key To Modify
local function pauseSelectedKeyToModify()
  if (data.pauseKeybindingOptions.keySelected) then
    data.pauseKeybindingOptions.keySelected = false
  else
    data.pauseKeybindingOptions.keySelected = true
  end
end

--Load Keybinding Options Menu
function class.loadPauseKeybindingOptions(titleColor, titleColorDir)
  data.pauseKeybindingOptions = {}

  --Images
  data.pauseKeybindingOptions.titlePause = love.graphics.newImage('Assets/Images/PauseTitle.png')
  data.pauseKeybindingOptions.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Info
  data.pauseKeybindingOptions.titleX = screen.getWidth()/2 - data.pauseKeybindingOptions.titlePause:getWidth()/2
  data.pauseKeybindingOptions.titleY = screen.getHeight()/3 - 200
  data.pauseKeybindingOptions.titleColor = titleColor
  data.pauseKeybindingOptions.titleColorDir = titleColorDir

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.pauseKeybindingOptions.arrow:getWidth()/7, data.pauseKeybindingOptions.arrow:getHeight()
  data.pauseKeybindingOptions.arrowAnim = animation.new(data.pauseKeybindingOptions.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 300, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2 - 100, screen.getHeight()/2 - buttons.h/2 - 50
  createButton(nil, "up", buttons.x, buttons.y-(offsetY*2.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "down", buttons.x, buttons.y-(offsetY*1.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "left", buttons.x, buttons.y-(offsetY*0.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "right", buttons.x, buttons.y+(offsetY*0.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "bomb", buttons.x, buttons.y+(offsetY*1.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "detonate", buttons.x, buttons.y+(offsetY*2.5), buttons.w, buttons.h, 1, pauseSelectedKeyToModify)
  createButton(nil, "reset all bindings", buttons.x-50, buttons.y+(offsetY*4), 600, buttons.h, 1, resetKeyBinding)
  data.pauseKeybindingOptions.InfoX = buttons.x + buttons.w
  data.pauseKeybindingOptions.upInfoY = buttons.y - (offsetY*2.5) + buttons.h/2 - 17
  data.pauseKeybindingOptions.downInfoY = buttons.y - (offsetY*1.5) + buttons.h/2 - 17
  data.pauseKeybindingOptions.leftInfoY = buttons.y - (offsetY*0.5) + buttons.h/2 - 17
  data.pauseKeybindingOptions.rightInfoY = buttons.y + (offsetY*0.5) + buttons.h/2 - 17
  data.pauseKeybindingOptions.bombInfoY = buttons.y + (offsetY*1.5) + buttons.h/2 - 17
  data.pauseKeybindingOptions.detonateInfoY = buttons.y + (offsetY*2.5) + buttons.h/2 - 17


  --Buttons Information
  data.pauseKeybindingOptions.selectedButtonId = 1
  data.pauseKeybindingOptions.keySelected = false

  --Error Message
  data.pauseKeybindingOptions.error = false
  data.pauseKeybindingOptions.errorText = "This key is already used !"
  data.pauseKeybindingOptions.errorY = screen.getHeight()/2 - font.getFont("font40"):getHeight()/2 - 75
  data.pauseKeybindingOptions.errorTimer = 0  

end

--Update Audio Options Menu
function class.updatePauseKeybindingOptions(dt)
  animation.updateTimer(data.pauseKeybindingOptions.arrowAnim, dt)
  if (data.pauseKeybindingOptions.error) then
    if (data.pauseKeybindingOptions.errorTimer > 1) then
      data.pauseKeybindingOptions.error = false
    else
      data.pauseKeybindingOptions.errorTimer = data.pauseKeybindingOptions.errorTimer + dt
    end
  end

  if (data.pauseKeybindingOptions.titleColorDir == "up") then
    if (data.pauseKeybindingOptions.titleColor < 1) then
      data.pauseKeybindingOptions.titleColor = data.pauseKeybindingOptions.titleColor + dt/4
    else
      data.pauseKeybindingOptions.titleColorDir = "down"
    end
  elseif (data.pauseKeybindingOptions.titleColorDir == "down") then
    if (data.pauseKeybindingOptions.titleColor > 0.5) then
      data.pauseKeybindingOptions.titleColor = data.pauseKeybindingOptions.titleColor - dt/4
    else
      data.pauseKeybindingOptions.titleColorDir = "up"
    end
  end
end

--Draw Keybinding Options Menu
function class.drawPauseKeybindingOptions()
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle('fill', 0, 0, 1920, 1080)

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', data.pauseKeybindingOptions.titleX, data.pauseKeybindingOptions.titleY, 707, 600)

  love.graphics.setColor(data.pauseKeybindingOptions.titleColor, data.pauseKeybindingOptions.titleColor, data.pauseKeybindingOptions.titleColor)
  love.graphics.draw(data.pauseKeybindingOptions.titlePause, data.pauseKeybindingOptions.titleX, data.pauseKeybindingOptions.titleY)

  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    if (buttonId ~= #buttonsList) then
      love.graphics.setFont(font.getFont("fontWhite"))
    else
      love.graphics.setFont(font.getFont("fontBlack"))
    end
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.pauseKeybindingOptions.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.pauseKeybindingOptions.arrowAnim, button.x, button.y, 40, data.pauseKeybindingOptions.arrow:getHeight()/2 - button.h/2)
    end
  end
  local keyBind = keybinding.getKey()
  love.graphics.setFont(font.getFont("fontWhite"))
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 1) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.upInfoY)
  else
    love.graphics.print({": ", keyBind.up}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.upInfoY)
  end
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 2) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.downInfoY)
  else
    love.graphics.print({": ", keyBind.down}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.downInfoY)
  end
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 3) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.leftInfoY)
  else
    love.graphics.print({": ", keyBind.left}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.leftInfoY)
  end
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 4) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.rightInfoY)
  else
    love.graphics.print({": ", keyBind.right}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.rightInfoY)
  end
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 5) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.bombInfoY)
  else
    love.graphics.print({": ", keyBind.bomb}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.bombInfoY)
  end
  if (data.pauseKeybindingOptions.keySelected and data.pauseKeybindingOptions.selectedButtonId == 6) then
    love.graphics.print(": ...", data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.detonateInfoY)
  else
    love.graphics.print({": ", keyBind.detonate}, data.pauseKeybindingOptions.InfoX, data.pauseKeybindingOptions.detonateInfoY)
  end
  if (data.pauseKeybindingOptions.error) then
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(font.getFont("font40"))
    love.graphics.printf(data.pauseKeybindingOptions.errorText, 0, data.pauseKeybindingOptions.errorY, screen.getWidth(), 'center')
  end
end

--Key pressed function in Keybinding Options menu
function class.keypressedPauseKeybindingOptions(key)
  if (data.pauseKeybindingOptions.keySelected) then
    if (keybinding.changeBinding(buttonsList[data.pauseKeybindingOptions.selectedButtonId].text, key)) then
      data.pauseKeybindingOptions.errorTimer = 0
      data.pauseKeybindingOptions.error = true
    end
    buttonsList[data.pauseKeybindingOptions.selectedButtonId].func()
  else
    if (key == 'up') then
      data.pauseKeybindingOptions.selectedButtonId = data.pauseKeybindingOptions.selectedButtonId - 1
      if (data.pauseKeybindingOptions.selectedButtonId < 1) then
        data.pauseKeybindingOptions.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.pauseKeybindingOptions.selectedButtonId = data.pauseKeybindingOptions.selectedButtonId + 1
      if (data.pauseKeybindingOptions.selectedButtonId > #buttonsList) then
        data.pauseKeybindingOptions.selectedButtonId = 1
      end
    end
    if (key == 'return') then
      buttonsList[data.pauseKeybindingOptions.selectedButtonId].func()
    end
    if (key == 'escape') then
      goToPauseOptions(data.pauseKeybindingOptions.titleColor, data.pauseKeybindingOptions.titleColorDir)
    end
  end
end


--Go to Character Skins Menu
local function goToCharacterSkins()
  class.load()
  class.loadCharacterSkins()
  gameInfo.setGamestate("solo_menu_characterSkins")
end


--Load Skins Menu
function class.loadSkins()
  data.skins = {}

  --Images
  data.skins.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.skins.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.skins.arrow:getWidth()/7, data.skins.arrow:getHeight()
  data.skins.arrowAnim = animation.new(data.skins.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 50
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "character", buttons.x, buttons.y, buttons.w, buttons.h, 1, goToCharacterSkins)

  --Buttons Information
  data.skins.selectedButtonId = 1
end

--Update Skins Menu
function class.updateSkins(dt)
  animation.updateTimer(data.skins.arrowAnim, dt)
end

--Draw Skins Menu
function class.drawSkins()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.skins.backgroundOptions)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.skins.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.skins.arrowAnim, button.x, button.y, 40, data.skins.arrow:getHeight()/2 - button.h/2)
    end
  end
end

--Key pressed function in Skins menu
function class.keypressedSkins(key)
  if (key == 'up') then
    data.skins.selectedButtonId = data.skins.selectedButtonId - 1
    if (data.skins.selectedButtonId < 1) then
      data.skins.selectedButtonId = #buttonsList
    end
  elseif (key == 'down') then
    data.skins.selectedButtonId = data.skins.selectedButtonId + 1
    if (data.skins.selectedButtonId > #buttonsList) then
      data.skins.selectedButtonId = 1
    end
  elseif (key == 'return') then
    buttonsList[data.skins.selectedButtonId].func()
  end
  if (key == 'escape') then
    backToMain()
  end
end




--Select Character Skins
local function selectCharacterSkins()
  skins.setIndex(data.characterSkins.selectedSkin)
end

--Load Character Skins Menu
function class.loadCharacterSkins()
  data.characterSkins = {}

  --Images
  data.characterSkins.backgroundOptions = love.graphics.newImage('Assets/Images/MainBackgroundOptions.jpg')
  data.characterSkins.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.characterSkins.arrow:getWidth()/7, data.characterSkins.arrow:getHeight()
  data.characterSkins.arrowAnim = animation.new(data.characterSkins.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 100
  createButton(nil, "mighty", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, selectCharacterSkins)
  createButton(nil, "bomberboy", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, selectCharacterSkins)

  --Buttons Information
  data.characterSkins.selectedButtonId = 1
  data.characterSkins.selectedSkin = skins.getIndex()
end

--Update Character Skins Menu
function class.updateCharacterSkins(dt)
  animation.updateTimer(data.characterSkins.arrowAnim, dt)
end

--Draw Character Skins Menu
function class.drawCharacterSkins()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.characterSkins.backgroundOptions)
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.characterSkins.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.characterSkins.arrowAnim, button.x, button.y, 40, data.characterSkins.arrow:getHeight()/2 - button.h/2)
    end
    if (data.characterSkins.selectedSkin == buttonId) then
      love.graphics.setColor(0, 1, 0)
      love.graphics.circle('fill', button.x + button.w + 20, button.y + button.h/2 - 10, 20)
    end
  end
end

--Key pressed function in Character Skins menu
function class.keypressedCharacterSkins(key)
  if (key == 'up') then
    data.characterSkins.selectedButtonId = data.characterSkins.selectedButtonId - 1
    if (data.characterSkins.selectedButtonId < 1) then
      data.characterSkins.selectedButtonId = #buttonsList
    end
  elseif (key == 'down') then
    data.characterSkins.selectedButtonId = data.characterSkins.selectedButtonId + 1
    if (data.characterSkins.selectedButtonId > #buttonsList) then
      data.characterSkins.selectedButtonId = 1
    end
  elseif (key == 'return') then
    data.characterSkins.selectedSkin = data.characterSkins.selectedButtonId
    buttonsList[data.characterSkins.selectedButtonId].func()
  end
  if (key == 'escape') then
    goToSkins()
  end
end

return class