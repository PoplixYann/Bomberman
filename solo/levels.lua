
local data

local class = {}

function class.getData()
  return data
end

function class.load()
  data = {}
  

  local level

  --Level 1
  level = {}
  level.field = {}
  level.field.line, level.field.column = 9, 15
  level.nbEnemies1 = 0
  level.nbEnemies2 = 0
  level.nbEnemies3 = 0
  level.nbCrate = 4
  level.nbBonus = 0
  level.nbMalus = 0
  level.bonusDetonate = false
  level.timer = 60
  table.insert(data, level)

  --Level 2
  level = {}
  level.field = {}
  level.field.line, level.field.column = 11, 21
  level.nbEnemies1 = 1
  level.nbEnemies2 = 0
  level.nbEnemies3 = 0
  level.nbCrate = 9
  level.nbBonus = 0
  level.nbMalus = 0
  level.bonusDetonate = false
  level.timer = 60
  table.insert(data, level)
  
  --Level 3
  level = {}
  level.field = {}
  level.field.line, level.field.column = 11, 23
  level.nbEnemies1 = 2
  level.nbEnemies2 = 0
  level.nbEnemies3 = 0
  level.nbCrate = 14
  level.nbBonus = 1
  level.nbMalus = 0
  level.bonusDetonate = false
  level.timer = 60
  table.insert(data, level)
  
  --Level 4
  level = {}
  level.field = {}
  level.field.line, level.field.column = 13, 25
  level.nbEnemies1 = 2
  level.nbEnemies2 = 1
  level.nbEnemies3 = 0
  level.nbCrate = 38
  level.nbBonus = 7
  level.nbMalus = 3
  level.bonusDetonate = false
  level.timer = 80
  table.insert(data, level)
  
  --Level 5
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 31
  level.nbEnemies1 = 3
  level.nbEnemies2 = 3
  level.nbEnemies3 = 1
  level.nbCrate = 50
  level.nbBonus = 10
  level.nbMalus = 5
  level.bonusDetonate = false
  level.timer = 100
  table.insert(data, level)
  
  --Level 6
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 35
  level.nbEnemies1 = 3
  level.nbEnemies2 = 5
  level.nbEnemies3 = 2
  level.nbCrate = 55
  level.nbBonus = 11
  level.nbMalus = 5
  level.bonusDetonate = true
  level.timer = 100
  table.insert(data, level)
  
  --Level 7
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 40
  level.nbEnemies1 = 5
  level.nbEnemies2 = 5
  level.nbEnemies3 = 5
  level.nbCrate = 65
  level.nbBonus = 12
  level.nbMalus = 7
  level.bonusDetonate = true
  level.timer = 140
  table.insert(data, level)
  
  --Level 8
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 45
  level.nbEnemies1 = 4
  level.nbEnemies2 = 7
  level.nbEnemies3 = 5
  level.nbCrate = 75
  level.nbBonus = 12
  level.nbMalus = 7
  level.bonusDetonate = true
  level.timer = 150
  table.insert(data, level)
  
  --Level 9
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 51
  level.nbEnemies1 = 5
  level.nbEnemies2 = 8
  level.nbEnemies3 = 6
  level.nbCrate = 80
  level.nbBonus = 14
  level.nbMalus = 7
  level.bonusDetonate = true
  level.timer = 160
  table.insert(data, level)
  
  --Level 10
  level = {}
  level.field = {}
  level.field.line, level.field.column = 15, 55
  level.nbEnemies1 = 13
  level.nbEnemies2 = 9
  level.nbEnemies3 = 7
  level.nbCrate = 100
  level.nbBonus = 5
  level.nbMalus = 20
  level.bonusDetonate = true
  level.timer = 420
  table.insert(data, level)
  
  --Level 11
  level = {}
  level.field = {}
  level.field.line, level.field.column = 9, 15
  level.nbEnemies1 = 0
  level.nbEnemies2 = 0
  level.nbEnemies3 = 0
  level.nbCrate = 4
  level.nbBonus = 0
  level.nbMalus = 0
  level.bonusDetonate = true
  level.timer = 10000
  table.insert(data, level)

end

return class