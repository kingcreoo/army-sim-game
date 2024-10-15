-- // Initialize, written by KingCreoo on October 14th, 2023
-- // Manages loading the loading screen immediately on player joins

-- // Services & Variables

local PreparedToPlay = false


local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadPlayerEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LoadPlayer")

local LocalPlayer = Players.LocalPlayer

local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local PlayerControls = PlayerModule:GetControls()

local LocalGui = LocalPlayer.PlayerGui
local LoadingScreenGui = LocalGui:WaitForChild("LoadingScreen")
local LoadingFrame = LoadingScreenGui:WaitForChild("Frame")
local LoadingLabel = LoadingFrame:WaitForChild("Label")
local PlayButton = LoadingFrame:WaitForChild("Play")

local FadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Circular)

-- // Handling

-- // Disable Player's controls 
PlayerControls:Disable()

-- Enable custom loading screen & disable default loading screen
LoadingScreenGui.Enabled = true
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Enable rotation tween for loading label
local RotationTween = TweenService:Create(LoadingLabel, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 359})
RotationTween:Play()

-- Play button management TODO actual load here
task.wait(3)

local FadeTween = TweenService:Create(LoadingLabel, FadeTweenInfo, {TextTransparency = 1})
FadeTween:Play()
FadeTween.Completed:Connect(function()
  LoadingLabel:Destroy()

  local FadeInTween = TweenService:Create(PlayButton, TweenInfo.new(.32), {TextTransparency = 0, BackgroundTransparency = 0})
  FadeInTween:Play()
  PreparedToPlay = true

  PlayButton.MouseButton1Down:Connect(function()
    if PreparedToPlay == true then
      LoadPlayerEvent:FireServer()
      
      task.wait(1)
      TweenService:Create(PlayButton, FadeTweenInfo, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
      TweenService:Create(LoadingFrame, FadeTweenInfo, {BackgroundTransparency = 1}):Play()

      task.wait(.5)
      PlayerControls:Enable()
      task.wait(.5)
      LoadingScreenGui.Enabled = false
    end
end)
end)
