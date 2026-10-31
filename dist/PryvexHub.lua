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

-- Keep the Pryvex logo centered inside Fluent's title bar.
local originalCreateWindow = Fluent.CreateWindow

Fluent.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)

    if window and window.TitleBar and window.TitleBar.Frame then
        local titleContent = window.TitleBar.Frame:FindFirstChildWhichIsA("Frame")

        if titleContent and not titleContent:FindFirstChild("PryvexLogoContainer") then
            local logoContainer = Instance.new("Frame")
            logoContainer.Name = "PryvexLogoContainer"
            logoContainer.BackgroundTransparency = 1
            logoContainer.Size = UDim2.new(0, 24, 1, 0)
            logoContainer.LayoutOrder = -1
            logoContainer.Parent = titleContent

            local logo = Instance.new("ImageLabel")
            logo.Name = "PryvexLogo"
            logo.BackgroundTransparency = 1
            logo.Size = UDim2.fromOffset(22, 22)
            logo.AnchorPoint = Vector2.new(0.5, 0.5)
            logo.Position = UDim2.fromScale(0.5, 0.5)
            logo.Image = PRYVEX_ICON
            logo.ScaleType = Enum.ScaleType.Fit
            logo.Parent = logoContainer
        end
    end

    -- Fluent's default tab ImageLabel uses Stretch. Force Fit and align the
    -- icon/text explicitly so icons keep their proportions across devices.
    if window then
        local originalAddTab = window.AddTab

        window.AddTab = function(tabSelf, tabConfig)
            local tab = originalAddTab(tabSelf, tabConfig)

            if tab and tab.Frame then
                local iconImage = tab.Frame:FindFirstChildWhichIsA("ImageLabel")
                local titleLabel = tab.Frame:FindFirstChildWhichIsA("TextLabel")

                if iconImage and iconImage.Image ~= "" then
                    iconImage.AnchorPoint = Vector2.new(0, 0.5)
                    iconImage.Position = UDim2.new(0, 8, 0.5, 0)
                    iconImage.Size = UDim2.fromOffset(18, 18)
                    iconImage.ScaleType = Enum.ScaleType.Fit
                    iconImage.BackgroundTransparency = 1

                    if titleLabel then
                        titleLabel.Position = UDim2.new(0, 32, 0.5, 0)
                        titleLabel.Size = UDim2.new(1, -38, 1, 0)
                    end
                elseif titleLabel then
                    titleLabel.Position = UDim2.new(0, 12, 0.5, 0)
                    titleLabel.Size = UDim2.new(1, -24, 1, 0)
                end
            end

            return tab
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
