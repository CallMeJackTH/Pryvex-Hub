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

-- Prefer the executor's hidden UI container when available.
-- Fall back to Fluent's default CoreGui parent otherwise.
local function attachGui()
    local gui = Fluent.GUI
    if not gui then
        return false, "Fluent.GUI is missing"
    end

    local ok, hiddenGui = pcall(function()
        if type(gethui) == "function" then
            return gethui()
        end
        return nil
    end)

    if ok and hiddenGui then
        gui.Parent = hiddenGui
    end

    gui.Enabled = true
    gui.DisplayOrder = 999999
    return gui.Parent ~= nil, gui.Parent and gui.Parent:GetFullName() or "GUI has no parent"
end

local guiAttached, guiStatus = attachGui()
if not guiAttached then
    warn("[Pryvex Hub] GUI attach warning: " .. tostring(guiStatus))
end

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
