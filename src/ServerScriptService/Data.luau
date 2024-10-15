-- // Data, written by KingCreoo on October 15th, 2024
-- // Manages loading & saving player's Data

-- // DEFINE
local Data = {}

-- // Services, Modules, & Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Settings = require(ReplicatedStorage:WaitForChild("Settings"))

local DataStore = DataStoreService:GetDataStore("army-sim-game")

local Database = {}
local Saves = {}

-- // Local functions
local function DeepCopy(Table)
  local Copy = {}

  for k, v in pairs(Table) do
    if type(v) == table then
      DeepCopy(v)
    else
      Copy[k] = v
    end
  end

  return Copy
end

local function DeepReconcile(Table0 --[[Default data]], Table1 --[[Player's data]])
  for k, v in pairs(Table0) do
    if not Table1[k] then continue end

    if type[v] == table then
      DeepReconcile(Table0[k], Table1[k])
    else
      if Table1[k] then
        Table0[k] = Table1[k]
      end
    end
  end

  return Table0
end

-- // Module functions
function Data.New(Player: Player)
  local PlayerData = DeepCopy(Settings.DefaultData)
  Data.Set(PlayerData)

  return PlayerData
end

function Data.Set(Player: Player, PlayerData: table)
  Database[Player.Name] = PlayerData

  local leaderstats = Player:FindFirstChild("leaderstats")
  if leaderstats then
    for Stat, Value in pairs(PlayerData["leaderstats"]) do
      leaderstats:WaitForChild(Stat).Value = Value
    end
  end

  local TimeOfTransaction = os.time()
  local ToSave

  if not Saves[Player.Name] then
    ToSave = true
  else
    if Saves[Player.Name] - TimeOfTransaction > 60 then
      ToSave = true
    end
  end

  if not ToSave then return end

  Saves[Player.Name] = TimeOfTransaction

  local Success, ErrorMessage = pcall(function()
    DataStore:SetAsync("Player_" .. Players:GetUserIdFromNameAsync(Player.Name), PlayerData)
  end)

  if not Success then
    warn("ErrorMessage")
  end
end

function Data.Get(Player: Player)
  return Database[Player.Name]
end

function Data.Remove(Player: Player)
  local PlayerData = DeepCopy(Database[Player.Name])
  Database[Player.Name] = nil

  local Success, ErrorMessage = pcall(function()
    DataStore:SetAsync("Player_" .. Players:GetUserIdFromNameAsync(Player.Name), PlayerData)
  end)
  
  if not Success then
    warn(ErrorMessage)
  end

  return PlayerData
end


-- // RETURN
return Data
