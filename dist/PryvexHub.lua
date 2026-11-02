--[[
    Pryvex Hub - Fluent UI distribution
    UI framework: Fluent by dawid-scripts
    Upstream: https://github.com/dawid-scripts/Fluent
    License: MIT (see LICENSE-FLUENT)

    The previous custom Pryvex UI implementation has been replaced.
    This file loads the official Fluent release and applies Pryvex branding.
]]

local FLUENT_URL = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
local PRYVEX_ICON = "rbxassetid://127972121421541"

local function loadFluent()
    assert(type(game.HttpGet) == "function", "[Pryvex Hub] game:HttpGet is unavailable.")
    assert(type(loadstring) == "function", "[Pryvex Hub] loadstring is unavailable.")

    local source = game:HttpGet(FLUENT_URL)
    assert(type(source) == "string" and #source > 0, "[Pryvex Hub] Failed to download Fluent.")

    local chunk, compileError = loadstring(source)
    assert(chunk, "[Pryvex Hub] Fluent compile error: " .. tostring(compileError))

    local ok, library = pcall(chunk)
    assert(ok and type(library) == "table", "[Pryvex Hub] Fluent initialization failed: " .. tostring(library))

    return library
end

local Fluent = loadFluent()

-- Keep Fluent's original API and add the existing Pryvex logo to its title bar.
local originalCreateWindow = Fluent.CreateWindow

Fluent.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)

    if window and window.TitleBar and window.TitleBar.Frame then
        local titleContent = window.TitleBar.Frame:FindFirstChildWhichIsA("Frame")

        if titleContent and not titleContent:FindFirstChild("PryvexLogo") then
            local logo = Instance.new("ImageLabel")
            logo.Name = "PryvexLogo"
            logo.BackgroundTransparency = 1
            logo.Size = UDim2.fromOffset(24, 24)
            logo.Image = PRYVEX_ICON
            logo.ScaleType = Enum.ScaleType.Fit
            logo.LayoutOrder = -1
            logo.Parent = titleContent
        end
    end

    -- Create the floating Open/Close control in a separate ScreenGui.
    -- This keeps the icon visible while Fluent.GUI is hidden.
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local player = Players.LocalPlayer

    local toggleParent = CoreGui
    if type(gethui) == "function" then
        local ok, hiddenGui = pcall(gethui)
        if ok and hiddenGui then toggleParent = hiddenGui end
    end

    local previousToggle = toggleParent:FindFirstChild("PryvexOpenClose")
    if previousToggle then previousToggle:Destroy() end

    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "PryvexOpenClose"
    toggleGui.ResetOnSpawn = false
    toggleGui.IgnoreGuiInset = true
    toggleGui.DisplayOrder = 1000000
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = toggleParent

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Name = "PryvexIconButton"
    toggleButton.AnchorPoint = Vector2.new(1, 1)
    toggleButton.Position = UDim2.new(1, -24, 1, -110)
    toggleButton.Size = UDim2.fromOffset(54, 54)
    toggleButton.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    toggleButton.BackgroundTransparency = 0.08
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.Image = PRYVEX_ICON
    toggleButton.ScaleType = Enum.ScaleType.Fit
    toggleButton.ZIndex = 10
    toggleButton.Parent = toggleGui

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 14)
    buttonCorner.Parent = toggleButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(90, 94, 115)
    buttonStroke.Transparency = 0.78
    buttonStroke.Thickness = 1
    buttonStroke.Parent = toggleButton

    local dragStart, startPosition
    local wasDragged = false

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPosition = toggleButton.Position
            wasDragged = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragStart and startPosition
            and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 6 then wasDragged = true end
            toggleButton.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
            startPosition = nil
        end
    end)

    toggleButton.Activated:Connect(function()
        if wasDragged then
            wasDragged = false
            return
        end
        if Fluent.GUI then
            Fluent.GUI.Enabled = not Fluent.GUI.Enabled
        end
    end)

    return window
end

Fluent.Name = "Pryvex Hub"
Fluent.Brand = "Pryvex"
Fluent.Framework = "Fluent"
Fluent.Icon = PRYVEX_ICON
Fluent.CreatePryvexWindow = function(self, config)
    return self:CreateWindow(config)
end

return Fluent
