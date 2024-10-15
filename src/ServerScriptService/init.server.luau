-- // Created by KingCreoo on October 14th, 2024
-- // Manages basic server functions

-- // Services & Variables

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local FunctionsFolder = ReplicatedStorage:WaitForChild("Functions")
local LoadPlayerEvent = EventsFolder:WaitForChild("LoadPlayer")

local Lobby = workspace:WaitForChild("Lobby")
local SpawnPoints = Lobby:WaitForChild("SpawnPoints")

-- // Local functions

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


local function LoadPlayer(Player)
  local Character = Player.Character or Player.CharacterAdded:wait()

  -- TODO Load player's data
 
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



-- // Calling & Event management

Players.PlayerAdded:Connect(LoadPlayer)
