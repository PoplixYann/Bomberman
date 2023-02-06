local screen = require("screen")
local gameInfo = require("gameInfo")
local font = require("font")
local animation = require("animation")
local audio = require("audio")
local level = require("multi/level")
local players = require("multi/players")

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

function class.load()
  initVar()
end

--Go to Select number of players menu
local function goToNbPlayerSelect()
  class.load()
  class.loadNbPlayer()
  gameInfo.setGamestate("multi_menu_nbPlayer")
end

--Go To Options
local function goToOptions()
  class.load()
  class.loadOptions()
  gameInfo.setGamestate("multi_menu_options")
end

--Back to main
local function backToMain()
  class.load()
  class.loadMain()
  gameInfo.setGamestate("multi_menu_main")
end

--Leave the multi
local function leave()
  data.main.leave = true
end

function class.getLeave()
  return data.main.leave
end


function class.loadMain()
  data.main = {}

  data.main.leave = false

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
  createButton(nil, "play", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, goToNbPlayerSelect)
  createButton(nil, "options", buttons.x, buttons.y, buttons.w, buttons.h, 1, goToOptions)
  createButton(nil, "leave", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, leave)

  --Buttons Information
  data.main.buttonSelect = false
  data.main.selectedButtonId = 1
end

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
      if (buttonsList[data.main.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.main.selectedButtonId].func()
        return;
      end
      buttonsList[data.main.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.main.selectedButtonId].alphaTimer = buttonsList[data.main.selectedButtonId].alphaTimer + dt
    end
  end
end

function class.drawMain()
  love.graphics.setColor(1, 1, 1)
  if (data.main.selectedButtonId == 1) then
    love.graphics.draw(data.main.backgroundPlay)
  elseif (data.main.selectedButtonId == 2) then
    love.graphics.draw(data.main.backgroundOptions)
  elseif (data.main.selectedButtonId == 3) then
    love.graphics.draw(data.main.backgroundLeave)
  end
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf("multiplayer", 0, 50, screen.getWidth(), 'center')
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.main.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.main.arrowAnim, button.x, button.y, 40, data.main.arrow:getHeight()/2 - button.h/2)
    end
  end
end

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
  gameInfo.setGamestate("multi_menu_audioOptions")
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
  createButton(nil, "audio", buttons.x, buttons.y, buttons.w, buttons.h, 1, goToAudioOptions)

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
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf("options", 0, 50, screen.getWidth(), 'center')
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




local function select2Players()
  class.load()
  class.loadLobby(2)
  gameInfo.setGamestate("multi_menu_lobby")
end

local function select3Players()
  class.load()
  class.loadLobby(3)
  gameInfo.setGamestate("multi_menu_lobby")
end

local function select4Players()
  class.load()
  class.loadLobby(4)
  gameInfo.setGamestate("multi_menu_lobby")
end


function class.loadNbPlayer()
  data.nbPlayer = {}

  data.nbPlayer.leave = false

  --Images
  data.nbPlayer.background = love.graphics.newImage('Assets/Images/MainBackgroundPlay.jpg')
  data.nbPlayer.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.nbPlayer.arrow:getWidth()/7, data.nbPlayer.arrow:getHeight()
  data.nbPlayer.arrowAnim = animation.new(data.nbPlayer.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 125
  createButton(nil, "2 players", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, select2Players)
  createButton(nil, "3 players", buttons.x, buttons.y, buttons.w, buttons.h, 1, select3Players)
  createButton(nil, "4 players", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, select4Players)

  --Buttons Information
  data.nbPlayer.buttonSelect = false
  data.nbPlayer.selectedButtonId = 1
end

function class.updateNbPlayer(dt)
  animation.updateTimer(data.nbPlayer.arrowAnim, dt)
  if (data.nbPlayer.buttonSelect) then
    if (buttonsList[data.nbPlayer.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.nbPlayer.selectedButtonId].alpha == 1) then
        buttonsList[data.nbPlayer.selectedButtonId].alpha = 0
      elseif (buttonsList[data.nbPlayer.selectedButtonId].alpha == 0) then
        buttonsList[data.nbPlayer.selectedButtonId].alpha = 1
      end
      buttonsList[data.nbPlayer.selectedButtonId].alphaRepeatTime = buttonsList[data.nbPlayer.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.nbPlayer.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.nbPlayer.selectedButtonId].func()
        return;
      end
      buttonsList[data.nbPlayer.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.nbPlayer.selectedButtonId].alphaTimer = buttonsList[data.nbPlayer.selectedButtonId].alphaTimer + dt
    end
  end
end

function class.drawNbPlayer()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.nbPlayer.background)
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf("select number of players", 0, 50, screen.getWidth(), 'center')
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.nbPlayer.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.nbPlayer.arrowAnim, button.x, button.y, 40, data.nbPlayer.arrow:getHeight()/2 - button.h/2)
    end
  end
end

function class.keypressedNbPlayer(key)
  if not (data.nbPlayer.buttonSelect) then
    if (key == 'up') then
      data.nbPlayer.selectedButtonId = data.nbPlayer.selectedButtonId - 1
      if (data.nbPlayer.selectedButtonId < 1) then
        data.nbPlayer.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.nbPlayer.selectedButtonId = data.nbPlayer.selectedButtonId + 1
      if (data.nbPlayer.selectedButtonId > #buttonsList) then
        data.nbPlayer.selectedButtonId = 1
      end
    elseif (key == 'return') then
      data.nbPlayer.buttonSelect = true
    end
  end
  if (key == 'escape') then
    backToMain()
  end
end


local function play()
  local nbPlayers
  if (gameInfo.getGamestate() == "multi_menu_lobby") then
    nbPlayers = data.lobby.nbPlayer
  elseif (gameInfo.getGamestate() == "multi_menu_endgame") then
    nbPlayers = data.endgame.nbPlayer
  end
  level.load(nbPlayers)
  gameInfo.setGamestate("multi_playing")
end

function class.loadLobby(nbPlayers)
  data.lobby = {}

  --Audio
  if (gameInfo.getGamestate() == "multi_menu_endgame" or gameInfo.getGamestate() == "multi_playing") then
    love.audio.stop()
    local audioData = audio.getMenuMainAudio()
    audio.getMenuMainAudio().music.source:play()
  end

  data.lobby.nbPlayer = nbPlayers

  data.lobby.leave = false

  --Images
  data.lobby.background = love.graphics.newImage('Assets/Images/MainBackgroundPlay.jpg')
  data.lobby.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Arrow Animation
  local frame, framerate, x, y, w, h = 7, 12, 0, 0, data.lobby.arrow:getWidth()/7, data.lobby.arrow:getHeight()
  data.lobby.arrowAnim = animation.new(data.lobby.arrow, frame, framerate, x, y, w, h)

  --Buttons Creations
  local buttons = {}
  local offsetY = 100
  buttons.w, buttons.h = 400, 100
  buttons.x, buttons.y = screen.getWidth()/2 - buttons.w/2, screen.getHeight()/2 - buttons.h/2 + 125
  createButton(nil, "launch game !", buttons.x, buttons.y-offsetY, buttons.w, buttons.h, 1, play)
  createButton(nil, "back", buttons.x, buttons.y+offsetY, buttons.w, buttons.h, 1, goToNbPlayerSelect)

  --Buttons Information
  data.lobby.buttonSelect = false
  data.lobby.selectedButtonId = 1
end

function class.updateLobby(dt)
  animation.updateTimer(data.lobby.arrowAnim, dt)
  if (data.lobby.buttonSelect) then
    if (buttonsList[data.lobby.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.lobby.selectedButtonId].alpha == 1) then
        buttonsList[data.lobby.selectedButtonId].alpha = 0
      elseif (buttonsList[data.lobby.selectedButtonId].alpha == 0) then
        buttonsList[data.lobby.selectedButtonId].alpha = 1
      end
      buttonsList[data.lobby.selectedButtonId].alphaRepeatTime = buttonsList[data.lobby.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.lobby.selectedButtonId].alphaRepeatTime > 8) then
        buttonsList[data.lobby.selectedButtonId].func()
        return;
      end
      buttonsList[data.lobby.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.lobby.selectedButtonId].alphaTimer = buttonsList[data.lobby.selectedButtonId].alphaTimer + dt
    end
  end
end

function class.drawLobby()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(data.lobby.background)
  love.graphics.setFont(font.getFont("fontWhite"))
  love.graphics.printf("game lobby", 0, 50, screen.getWidth(), 'center')
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y+button.h/2-16, button.w, 'center')
    if (data.lobby.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1)
      animation.draw(data.lobby.arrowAnim, button.x, button.y, 40, data.lobby.arrow:getHeight()/2 - button.h/2)
    end
  end
end

function class.keypressedLobby(key)
  if not (data.lobby.buttonSelect) then
    if (key == 'up') then
      data.lobby.selectedButtonId = data.lobby.selectedButtonId - 1
      if (data.lobby.selectedButtonId < 1) then
        data.lobby.selectedButtonId = #buttonsList
      end
    elseif (key == 'down') then
      data.lobby.selectedButtonId = data.lobby.selectedButtonId + 1
      if (data.lobby.selectedButtonId > #buttonsList) then
        data.lobby.selectedButtonId = 1
      end
    elseif (key == 'return') then
      if (data.lobby.selectedButtonId == 1) then
        data.lobby.buttonSelect = true
      else
        buttonsList[data.lobby.selectedButtonId].func()
      end
    end
  end
  if (key == 'escape') then
    goToNbPlayerSelect()
  end
end




--Back to lobby
function class.backToLobby()
  if (level.getNbPlayers() == 2) then
    select2Players()
  elseif (level.getNbPlayers() == 3) then
    select3Players()
  elseif (level.getNbPlayers() == 4) then
    select4Players()
  end
end


function class.loadEndGame()
  data.endgame = {}

  --Audio
  love.audio.stop()
  local audioData = audio.getWinAudio()
  audioData.music.source:play()

  --Players
  data.endgame.nbPlayer = level.getNbPlayers()
  data.endgame.playerWin = players.getPlayerWin()

  --Menu Draw Information
  data.endgame.alpha = 0
  data.endgame.backgroundAlpha = 0

  --Images
  data.endgame.title = love.graphics.newImage('Assets/Images/WinTitle.png')
  data.endgame.arrow = love.graphics.newImage('Assets/Images/Arrow.png')

  --Title Animations
  local frame, framerate, x, y, w, h = 7, 7, 0, 0, 494, 131
  data.endgame.titleAnim = animation.new(data.endgame.title, frame, framerate, x, y, w, h)
  data.endgame.titleX, data.endgame.titleY = screen.getWidth()/2 - w/2, screen.getHeight()/2 - h/2 - h

  --Arrow Animations
  frame, framerate, x, y, w, h = 7, 12, 0, 0, data.endgame.arrow:getWidth()/7, data.endgame.arrow:getHeight()
  data.endgame.arrowAnim = animation.new(data.endgame.arrow, frame, framerate, x, y, w, h)

  --Buttons Creation
  local buttons = {}
  local offsetX = 100
  buttons.w, buttons.h = 600, 100
  buttons.x, buttons.y = screen.getWidth()/2, screen.getHeight()/2 - buttons.h/2 + 200
  createButton(nil, "play !", buttons.x-offsetX-200, buttons.y, buttons.w, buttons.h, 0, play)
  createButton(nil, "back to lobby", buttons.x+offsetX, buttons.y, buttons.w, buttons.h, 0, class.backToLobby)

  --Buttons Information
  data.endgame.selectedButtonId = 1
  data.endgame.buttonSelected = false
end

function class.updateEndGame(dt)
  animation.updateTimer(data.endgame.titleAnim, dt)
  if (data.endgame.alpha < 1) then
    data.endgame.alpha = data.endgame.alpha + dt/4
    if (data.endgame.alpha < 0.7) then
      data.endgame.backgroundAlpha = data.endgame.alpha
    elseif (data.endgame.backgroundAlpha ~= 0.7) then
      data.endgame.backgroundAlpha = 0.7
    end
  elseif (data.endgame.alpha ~= 1) then
    data.endgame.alpha = 1
  end
  animation.updateTimer(data.endgame.arrowAnim, dt)
  if (data.endgame.buttonSelected) then
    if (buttonsList[data.endgame.selectedButtonId].alphaTimer > 0.3) then
      if (buttonsList[data.endgame.selectedButtonId].alpha > 0) then
        buttonsList[data.endgame.selectedButtonId].alpha = 0
      elseif (buttonsList[data.endgame.selectedButtonId].alpha == 0) then
        buttonsList[data.endgame.selectedButtonId].alpha = 1
      end
      buttonsList[data.endgame.selectedButtonId].alphaRepeatTime = buttonsList[data.endgame.selectedButtonId].alphaRepeatTime + 1
      if (buttonsList[data.endgame.selectedButtonId].alphaRepeatTime > 4) then
        buttonsList[data.endgame.selectedButtonId].func()
        return;
      end
      buttonsList[data.endgame.selectedButtonId].alphaTimer = 0
    else
      buttonsList[data.endgame.selectedButtonId].alphaTimer = buttonsList[data.endgame.selectedButtonId].alphaTimer + dt
    end
  else
    for buttonId, button in ipairs(buttonsList) do
      button.alpha = data.endgame.alpha
    end
  end
end

function class.drawEndGame()
  love.graphics.setColor(0.2, 0.2, 0.2, data.endgame.backgroundAlpha)
  love.graphics.rectangle('fill', screen.getWidth()/2-600, screen.getHeight()/2-200, 1200, 400)
  love.graphics.setColor(1, 1, 1, data.endgame.alpha)
  animation.draw(data.endgame.titleAnim, data.endgame.titleX, data.endgame.titleY)
  love.graphics.setFont(font.getFont("fontWhite"))
  for playerId, player in ipairs(data.endgame.playerWin) do
    love.graphics.setColor(player.color)
    love.graphics.print({"player ", player.index}, screen.getWidth()/2 - 900 + (300*playerId), screen.getHeight()/2+100-130)
  end
  for buttonId, button in ipairs(buttonsList) do
    love.graphics.setColor(1, 1, 1, button.alpha)
    love.graphics.setFont(font.getFont("fontBlack"))
    love.graphics.printf(button.text, button.x, button.y, button.w, 'left')
    if (data.endgame.selectedButtonId == buttonId) then
      love.graphics.setColor(1, 1, 1, data.endgame.alpha)
      animation.draw(data.endgame.arrowAnim, button.x, button.y, 50)
    end
  end
end

function class.keypressedEndGame(key)
  if not (data.endgame.buttonSelect) then
    if (key == 'left') then
      data.endgame.selectedButtonId = data.endgame.selectedButtonId - 1
      if (data.endgame.selectedButtonId < 1) then
        data.endgame.selectedButtonId = #buttonsList
      end
    elseif (key == 'right') then
      data.endgame.selectedButtonId = data.endgame.selectedButtonId + 1
      if (data.endgame.selectedButtonId > #buttonsList) then
        data.endgame.selectedButtonId = 1
      end
    elseif (key == 'return') then
      data.endgame.buttonSelected = true
    end
  end
  if (key == 'escape') then
    class.backToLobby()
  end
end

return class