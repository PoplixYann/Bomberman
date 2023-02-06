

local data

local class = {}

function class.getPlayer(index)
  return data["player"..index]
end

function class.load()
  data = {}

  data.player1 = {}
  data.player1.up = 'z'
  data.player1.down = 's'
  data.player1.left = 'q'
  data.player1.right = 'd'
  data.player1.bomb = 'space'
  data.player2 = {}
  data.player2.up = 'up'
  data.player2.down = 'down'
  data.player2.left = 'left'
  data.player2.right = 'right'
  data.player2.bomb = 'rshift'
  data.player3 = {}
  data.player3.up = 'i'
  data.player3.down = 'k'
  data.player3.left = 'j'
  data.player3.right = 'l'
  data.player3.bomb = 'm'
  data.player4 = {}
  data.player4.up = 'kp8'
  data.player4.down = 'kp5'
  data.player4.left = 'kp4'
  data.player4.right = 'kp6'
  data.player4.bomb = 'kp0'

end

return class