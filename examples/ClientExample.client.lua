--!strict
-- Place PryvexHub (containing init.lua, Theme.lua, Components.lua and Tabs)
-- in ReplicatedStorage, then place this LocalScript in StarterPlayerScripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PryvexHub = require(ReplicatedStorage:WaitForChild("PryvexHub"))

local window = PryvexHub.CreateWindow({
    Title = "Pryvex Hub",
    Subtitle = "CONTROL CENTER",
})

local home = window:AddTab("Home")
home:AddSection("OVERVIEW")
home:AddLabel("Welcome to Pryvex Hub.")
home:AddLabel("Your interface has loaded successfully.")
home:AddButton("Test notification", function()
    window:Notify("Pryvex Hub", "Everything is working.")
end)

local main = window:AddTab("Main")
main:AddSection("EXAMPLE CONTROLS")
main:AddToggle("Example toggle", false, function(enabled)
    print("Example toggle:", enabled)
end)
main:AddButton("Print status", function()
    print("Pryvex Hub is running.")
end)

local settings = window:AddTab("Settings")
settings:AddSection("INTERFACE")
settings:AddButton("Hide window", function()
    window:SetVisible(false)
end)

-- Press RightShift to show or hide the window.
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        window:SetVisible(true)
    end
end)
