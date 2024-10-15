-- // Created by KingCreoo on October 14th, 2024
-- // Manages basic server functions

-- // Services, Modules, & Variables

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Data = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Data"))

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local FunctionsFolder = ReplicatedStorage:WaitForChild("Functions")
local LoadPlayerEvent = EventsFolder:WaitForChild("LoadPlayer")

local Lobby = workspace:WaitForChild("Lobby")
local SpawnPoints = Lobby:WaitForChild("SpawnPoints")

-- // Local functions

local function InitializeData(Player: Player, PlayerData: table)
  local leaderstats = Instance.new("Folder")
  leaderstats.Parent = Player
  leaderstats.Name = "leaderstats"

  for Name, Value in pairs(PlayerData["leaderstats"]) do
    local String = type(Value) .. "Value"

    local Stat = Instance.new(string.upper(string.sub(String, 1, 1)) .. string.sub(String, 2, -1))
    Stat.Name = Name
    Stat.Value = Value
    Stat.Parent = leaderstats
  end 
end

local function SelectSpawnPoint(Character, BruteForce: boolean)
  local FoundSpawnPoint = false
  for _, SpawnPoint in pairs(SpawnPoints:GetChildren()) do
    if not BruteForce and SpawnPoint:GetAttribute("Occupied") == true then continue end
    FoundSpawnPoint = true

    SpawnPoint:SetAttribute("Occupied", true)
    Character:SetPrimaryPartCFrame(SpawnPoint.CFrame + Vector3.new(0, 5, 0))

    task.wait(30)
    SpawnPoint:SetAttribute("Occupied", false)
    break
  end
  
  return FoundSpawnPoint
end


local function OnPlayerAdded(Player)
  local Character = Player.Character or Player.CharacterAdded:wait()

  -- // Load player's data
  local PlayerData, NewPlayer = Data.Initialize(Player)
  if NewPlayer then
    print('new player')
    -- TODO handle new players
  end
  print('player has joined. their data: ', PlayerData)

  InitializeData(Player, PlayerData)
 
  -- // Player has clicked the 'play' button
  LoadPlayerEvent.OnServerEvent:Connect(function(ReturningPlayer)
    if ReturningPlayer.Name ~= Player.Name then return end 
  
    -- Handle sending player to the lobby with randomly generated spawnpoints
    local FoundSpawnPoint: boolean = SelectSpawnPoint(Character, false)
    if not FoundSpawnPoint then
      SelectSpawnPoint(Character, true)
    end
  end)
end

local function OnPlayerRemoving(Player)
  Data.Remove(Player)
end

-- // Calling & Event management

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
