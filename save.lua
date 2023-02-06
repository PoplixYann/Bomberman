

local finalStringTemp = "return { \r\n"
local function escape(str)
  local symbols = {
    bell = "\a",
    form_feed = "\f",
    new_line = "\n",
    carriage_return = "\r",
    verticle_tab = "\v",
    backslash = "\\",
    double_quote = "\"",
  }
  local escapedSymbols = {
    bell = "\\a",
    form_feed = "\\f",
    new_line = "\\n",
    carriage_return = "\\r",
    verticle_tab = "\\v",
    backslash = "\\\\",
    double_quote = "\\\"",
  }
  local str2 = str
  str2 = str2:gsub(symbols.backslash, escapedSymbols.backslash)
  for i,v in pairs(symbols) do
    if i ~= "backslash" then
      str2 = str2:gsub(v, escapedSymbols[i])
    end
  end
  return str2
end


local function formatData2(data)
  local finalString = finalStringTemp
  
  local function formatData1(data)
    local indTypeForm
      for i, v in pairs(data) do
        assert((type(i) ~= "table"), "Data table cannot have an table as a key reference")
        if type(i) == "string" then
          indTypeForm = "[\""..escape(i).."\"]"
        else
          indTypeForm = "["..tostring(i).."]"
        end
        if type(v) == "table" then
          finalString = finalString..indTypeForm.."= {\r\n"
          formatData1(v)
          finalString = finalString.."},\r\n"
        else
          if type(v) == "string" then v = [["]]..escape(v)..[["]] end
          finalString = finalString..indTypeForm.."="..v..",\r\n"
        end
      end
    finalString = finalString:sub(1, string.len(finalString)-3).."\r\n"
  end

  formatData1(data)
  finalString = finalString.."\r\n} "
  return finalString
end

local data = {}

local class = {}

function class.saveAudio(info, value)
  data.audio[info] = value
end

function class.getAudio()
  return data.audio
end

function class.saveKeybinding(info, value)
  data.keybinding[info] = value
end

function class.getKeybinding()
  return data.keybinding
end

function class.saveSkins(index)
  data.skins.index = index
end

function class.getSkins()
  return data.skins
end

function class.saveAll()
  local success = love.filesystem.write("config.lua", formatData2(data))
end

function class.load()
  local info = love.filesystem.getInfo("config.lua")
  if (info == nil) then
    data.audio = {}
    data.audio.volume = 0.2
    data.audio.soundEffect = "true"
    data.audio.music = "true"
    
    data.keybinding = {}
    data.keybinding.up = "z"
    data.keybinding.left = "q"
    data.keybinding.down = "s"
    data.keybinding.right = "d"
    data.keybinding.bomb = "space"
    data.keybinding.detonate = "e"
    
    data.skins = {}
    data.skins.index = 1
  else
    local chunk = love.filesystem.load("config.lua")
    data = chunk()
  end
end

return class