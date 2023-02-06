local data = {}

local class = {}

--Get actual gamestate
function class.getGamestate()
  return data.gamestate
end

--Set new gamestate
function class.setGamestate(newState)
  data.gamestate = newState
end

--Get actual mode
function class.getMode()
  return data.modestate
end

--Set new mode
function class.setMode(newMode)
  data.modestate = newMode
end

--Get unit size
function class.getUnit()
  return data.unit
end

--Get lastLevel bool
function class.getLastlevel()
  return data.lastLevel
end

--Set lastLevel bool
function class.setLastlevel()
  if (data.lastLevel == "none") then
    data.lastLevel = "10"
  elseif (data.lastLevel == "10") then
    data.lastLevel = "last"
  elseif (data.lastLevel == "last") then
    data.lastLevel = "none"
  end
end

--Load
function class.load()
  data.gamestate = "menu_main"
  data.modestate = "main"
  data.unit = 50
  data.lastLevel = "none"
end

return class