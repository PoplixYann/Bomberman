local save = require("save")

local data = {}

local class = {}

function class.getVolume()
  return data.volume * 500
end

function class.setVolume(volume)
  data.volume = volume / 500
  love.audio.setVolume(data.volume)
  save.saveAudio("volume", data.volume)
end

function class.changeActiveAudio(info)
  if (data.active[info]) then
    for soundId, sound in ipairs(data[info]) do
      sound.source:setVolume(0)
    end
    data.active[info] = false
    save.saveAudio(info, "false")
  else
    for soundId, sound in ipairs(data[info]) do
      sound.source:setVolume(sound.initialVolume)
    end
    data.active[info] = true
    save.saveAudio(info, "true")
  end
end

function class.getActivatedAudio()
  return data.active
end

function class.getCharacterAudio()
  return data.character
end

function class.getStageAudio()
  return data.stage
end

function class.getEnemiesAudio()
  return data.enemies
end

function class.getMenuWaitingAudio()
  return data.menuWaiting
end

function class.getMenuMainAudio()
  return data.menuMain
end

function class.getGameoverAudio()
  return data.gameover
end

function class.getWinAudio()
  return data.win
end

function class.load()
  --GENERAL
  data.volume = save.getAudio().volume
  love.audio.setVolume(data.volume)
  --Music and SoundEffect list
  data.soundEffect = {}
  data.music = {}
  --Audio activate ?
  data.active = {}
  local saveAudio = save.getAudio()
  if (saveAudio.soundEffect == "true") then
    data.active.soundEffect = true
  else
    data.active.soundEffect = false
  end
  if (saveAudio.music == "true") then
    data.active.music = true
  else
    data.active.music = false
  end

  --Character sounds
  data.character = {}
  data.character.walk = {}
  data.character.walk.source = love.audio.newSource('Assets/Audio/Walk.wav', 'static')
  data.character.walk.initialVolume = 0.3
  data.character.walk.source:setVolume(data.character.walk.initialVolume)
  table.insert(data.soundEffect, data.character.walk)
  data.character.bomb = {}
  data.character.bomb.source = love.audio.newSource('Assets/Audio/BombPose.wav', 'static')
  data.character.bomb.initialVolume = 0.4
  data.character.bomb.source:setVolume(data.character.bomb.initialVolume)
  table.insert(data.soundEffect, data.character.bomb)

  --Stage sounds
  data.stage = {}
  data.stage.music = {}
  data.stage.music.source = love.audio.newSource('Assets/Audio/Music.mp3', 'stream')
  data.stage.music.source:setLooping(true)
  data.stage.music.initialVolume = 1
  table.insert(data.music, data.stage.music)

  --Enemies sounds
  data.enemies = {}
  data.enemies.allDead = {}
  data.enemies.allDead.source = love.audio.newSource('Assets/Audio/EnemiesDead.wav', 'static')
  data.enemies.allDead.initialVolume = 0.2
  data.enemies.allDead.source:setVolume(data.enemies.allDead.initialVolume)
  table.insert(data.music, data.enemies.allDead)

  --Menu Waiting sounds
  data.menuWaiting = {}
  data.menuWaiting.music = {}
  data.menuWaiting.music.source = love.audio.newSource('Assets/Audio/StageStart.mp3', 'stream')
  data.menuWaiting.music.initialVolume = 0.2
  data.menuWaiting.music.source:setVolume(data.menuWaiting.music.initialVolume)
  table.insert(data.music, data.menuWaiting.music)

  --Menu Main sounds
  data.menuMain = {}
  data.menuMain.music = {}
  data.menuMain.music.source = love.audio.newSource('Assets/Audio/MusicMain.mp3', 'stream')
  data.menuMain.music.source:setLooping(true)
  data.menuMain.music.initialVolume = 0.2
  data.menuMain.music.source:setVolume(data.menuMain.music.initialVolume)
  table.insert(data.music, data.menuMain.music)

  --Menu Gameover sounds
  data.gameover = {}
  data.gameover.music = {}
  data.gameover.music.source = love.audio.newSource('Assets/Audio/Gameover.mp3', 'stream')
  data.gameover.music.initialVolume = 0.2
  data.gameover.music.source:setVolume(data.gameover.music.initialVolume)
  table.insert(data.music, data.gameover.music)

  --Menu Win sounds
  data.win = {}
  data.win.music = {}
  data.win.music.source = love.audio.newSource('Assets/Audio/Win.mp3', 'stream')
  data.win.music.initialVolume = 0.2
  data.win.music.source:setVolume(data.win.music.initialVolume)
  table.insert(data.music, data.win.music)

  if not (data.active.soundEffect) then
    for soundId, sound in ipairs(data.soundEffect) do
      sound.source:setVolume(0)
    end
  end
  if not (data.active.music) then
    for soundId, sound in ipairs(data.music) do
      sound.source:setVolume(0)
    end
  end
end

return class