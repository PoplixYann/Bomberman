local save = require("save")

local data = {}

local class = {}

function class.getKey()
  return data
end

function class.changeBinding(key, value)
  local previousKey = data[key]
  if (value == 'escape') then
    data[key] = previousKey
    return false
  end
  for keyId, keyTest in pairs(data) do
    if (keyId ~= data[key]) then
      if (value == keyTest) then
        data[key] = previousKey
        return true
      end
    end
  end
  data[key] = value
  save.saveKeybinding(key, value)
  return false
end

function class.resetBinding()
  data.up = "z"
  data.left = "q"
  data.down = "s"
  data.right = "d"
  data.bomb = "space"
  data.detonate = "e"
  for k, v in pairs(data) do
    save.saveKeybinding(k, v)
  end
end

function class.load()
  local saveKey = save.getKeybinding()
  data.up = saveKey.up
  data.left = saveKey.left
  data.down = saveKey.down
  data.right = saveKey.right
  data.bomb = saveKey.bomb
  data.detonate = saveKey.detonate
end

return class