local save = require("save")
local screen = require("screen")
local font = require("font")
local audio = require("audio")
local gameInfo = require("gameInfo")
local menuMain = require("menu")
local menuSolo = require("solo/menu")
local levelSolo = require("solo/level")
local levelsSolo = require("solo/levels")
local characterSolo = require("solo/character")
local menuMulti = require("multi/menu")
local levelMulti = require("multi/level")
local playerMulti = require("multi/players")

--First LOAD
function love.load()
  save.load()
  screen.load()
  font.load()
  audio.load()
  gameInfo.load()
  menuMain.load()
end

--General Update
function love.update(dt)
  if (gameInfo.getMode() == "main") then
    if (gameInfo.getGamestate() == "menu_main") then
      menuMain.update(dt)
    end
  elseif (gameInfo.getMode() == "solo") then
    if (gameInfo.getGamestate() == "solo_playing") then
      if (characterSolo.getData().isPlaying) then
        levelSolo.update(dt)
      else
        --Take the door go to next level
        if (levelSolo.getStage() + 1 <= #levelsSolo.getData()) then
          menuSolo.load()
          levelSolo.load(levelSolo.getStage() + 1)
          menuSolo.loadWaiting()
          gameInfo.setGamestate("solo_menu_waiting")
          --Take the door at last level then player win
        else
          menuSolo.load()
          levelSolo.setScore()
          levelSolo.setWin()
          menuSolo.loadWin()
          gameInfo.setGamestate("solo_menu_win")
        end
      end
      --Player die
      if (not characterSolo.getData().isAlive and characterSolo.getData().isDead) then
        menuSolo.load()
        levelSolo.setScore()
        levelSolo.setDieReason()
        menuSolo.loadGameover()
        gameInfo.setGamestate("solo_menu_gameover")
      end
    elseif (gameInfo.getGamestate() == "solo_menu_pause") then
      menuSolo.updatePause(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseOptions") then
      menuSolo.updatePauseOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseAudioOptions") then
      menuSolo.updatePauseAudioOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseKeybindingOptions") then
      menuSolo.updatePauseKeybindingOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_main") then
      if (menuSolo.getLeave()) then
        menuMain.load()
        gameInfo.setMode("main")
        gameInfo.setGamestate("menu_main")
      end
      menuSolo.updateMain(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_options") then
      menuSolo.updateOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_audioOptions") then
      menuSolo.updateAudioOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_keybindingOptions") then
      menuSolo.updateKeybindingOptions(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_skins") then
      menuSolo.updateSkins(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_characterSkins") then
      menuSolo.updateCharacterSkins(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_gameover") then
      levelSolo.update(dt)
      menuSolo.updateGameover(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_win") then
      menuSolo.updateWin(dt)
    elseif (gameInfo.getGamestate() == "solo_menu_waiting") then
      menuSolo.updateWaiting(dt)
    end
  elseif (gameInfo.getMode() == "multi") then
    if (gameInfo.getGamestate() == "multi_playing") then
      levelMulti.update(dt)
      if (playerMulti.getIsEnd()) then
        menuMulti.load()
        menuMulti.loadEndGame()
        gameInfo.setGamestate("multi_menu_endgame")
      end
    elseif (gameInfo.getGamestate() == "multi_menu_main") then
      if (menuMulti.getLeave()) then
        menuMain.load()
        gameInfo.setMode("main")
        gameInfo.setGamestate("menu_main")
      end
      menuMulti.updateMain(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_nbPlayer") then
      menuMulti.updateNbPlayer(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_lobby") then
      menuMulti.updateLobby(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_keybindings") then
      menuMulti.updateKeybindings(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_options" ) then
      menuMulti.updateOptions(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_audioOptions") then
      menuMulti.updateAudioOptions(dt)
    elseif (gameInfo.getGamestate() == "multi_menu_endgame") then
      menuMulti.updateEndGame(dt)
    end
  end
end

--General Draw
function love.draw()
  if (gameInfo.getMode() == "main") then
    if (gameInfo.getGamestate() == "menu_main") then
      menuMain.draw()
    end
  elseif (gameInfo.getMode() == "solo") then
    if (gameInfo.getGamestate() == "solo_playing") then
      levelSolo.draw()
    elseif (gameInfo.getGamestate() == "solo_menu_pause") then
      levelSolo.draw()
      menuSolo.drawPause()
    elseif (gameInfo.getGamestate() == "solo_menu_pauseOptions") then
      levelSolo.draw()
      menuSolo.drawPauseOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_pauseAudioOptions") then
      levelSolo.draw()
      menuSolo.drawPauseAudioOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_pauseKeybindingOptions") then
      levelSolo.draw()
      menuSolo.drawPauseKeybindingOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_main") then
      menuSolo.drawMain()
    elseif (gameInfo.getGamestate() == "solo_menu_options") then
      menuSolo.drawOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_audioOptions") then
      menuSolo.drawAudioOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_keybindingOptions") then
      menuSolo.drawKeybindingOptions()
    elseif (gameInfo.getGamestate() == "solo_menu_skins") then
      menuSolo.drawSkins()
    elseif (gameInfo.getGamestate() == "solo_menu_characterSkins") then
      menuSolo.drawCharacterSkins()
    elseif (gameInfo.getGamestate() == "solo_menu_gameover") then
      levelSolo.draw()
      menuSolo.drawGameover()
    elseif (gameInfo.getGamestate() == "solo_menu_win") then
      menuSolo.drawWin()
    elseif (gameInfo.getGamestate() == "solo_menu_waiting") then
      menuSolo.drawWaiting()
    end
  elseif (gameInfo.getMode() == "multi") then
    if (gameInfo.getGamestate() == "multi_playing") then
      levelMulti.draw()
    elseif (gameInfo.getGamestate() == "multi_menu_main") then
      menuMulti.drawMain()
    elseif (gameInfo.getGamestate() == "multi_menu_nbPlayer") then
      menuMulti.drawNbPlayer()
    elseif (gameInfo.getGamestate() == "multi_menu_lobby") then
      menuMulti.drawLobby()
    elseif (gameInfo.getGamestate() == "multi_menu_keybindings") then
      menuMulti.drawKeybindings()
    elseif (gameInfo.getGamestate() == "multi_menu_options" ) then
      menuMulti.drawOptions()
    elseif (gameInfo.getGamestate() == "multi_menu_audioOptions") then
      menuMulti.drawAudioOptions()
    elseif (gameInfo.getGamestate() == "multi_menu_endgame") then
      levelMulti.draw()
      menuMulti.drawEndGame()
    end
  end
end

--General Keypressed
function love.keypressed(key)
  if (gameInfo.getMode() == "main") then
    if (gameInfo.getGamestate() == "menu_main") then
      menuMain.keypressed(key)
    end
  elseif (gameInfo.getMode() == "solo") then
    if (gameInfo.getGamestate() == "solo_playing") then
      if (characterSolo.getData().isAlive) then
        characterSolo.keypressed(key)
      end
      if (key == 'escape') then
        menuSolo.load()
        menuSolo.loadPause()
        gameInfo.setGamestate("solo_menu_pause")
      end
    elseif (gameInfo.getGamestate() == "solo_menu_pause") then
      menuSolo.keypressedPause(key)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseOptions") then
      menuSolo.keypressedPauseOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseAudioOptions") then
      menuSolo.keypressedPauseAudioOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_pauseKeybindingOptions") then
      menuSolo.keypressedPauseKeybindingOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_main") then
      menuSolo.keypressedMain(key)
      if (key == 'escape') then
        menuMain.load()
        gameInfo.setMode("main")
        gameInfo.setGamestate("menu_main")
      end
    elseif (gameInfo.getGamestate() == "solo_menu_options" ) then
      menuSolo.keypressedOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_audioOptions") then
      menuSolo.keypressedAudioOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_keybindingOptions") then
      menuSolo.keypressedKeybindingOptions(key)
    elseif (gameInfo.getGamestate() == "solo_menu_skins") then
      menuSolo.keypressedSkins(key)
    elseif (gameInfo.getGamestate() == "solo_menu_characterSkins") then
      menuSolo.keypressedCharacterSkins(key)
    elseif (gameInfo.getGamestate() == "solo_menu_gameover") then
      menuSolo.keypressedGameover(key)
    elseif (gameInfo.getGamestate() == "solo_menu_win") then
      menuSolo.keypressedWin(key)
    end
  elseif (gameInfo.getMode() == "multi") then
    if (gameInfo.getGamestate() == "multi_playing") then
      playerMulti.keypressed(key)
      if (key == 'escape') then
        menuMulti.backToLobby()
      end
    elseif (gameInfo.getGamestate() == "multi_menu_main") then
      menuMulti.keypressedMain(key)
      if (key == 'escape') then
        menuMain.load()
        gameInfo.setMode("main")
        gameInfo.setGamestate("menu_main")
      end
    elseif (gameInfo.getGamestate() == "multi_menu_nbPlayer") then
      menuMulti.keypressedNbPlayer(key)
    elseif (gameInfo.getGamestate() == "multi_menu_lobby") then
      menuMulti.keypressedLobby(key)
    elseif (gameInfo.getGamestate() == "multi_menu_keybindings") then
      menuMulti.keypressedKeybindings(key)
    elseif (gameInfo.getGamestate() == "multi_menu_options" ) then
      menuMulti.keypressedOptions(key)
    elseif (gameInfo.getGamestate() == "multi_menu_audioOptions") then
      menuMulti.keypressedAudioOptions(key)
    elseif (gameInfo.getGamestate() == "multi_menu_endgame") then
      menuMulti.keypressedEndGame(key)
    end
  end
  if (key == 'f1') then
    gameInfo.setLastlevel()
  end
end