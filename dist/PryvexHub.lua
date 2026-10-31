--[[
    Pryvex Hub - Fluent UI distribution
    UI framework: Fluent by dawid-scripts
    Upstream: https://github.com/dawid-scripts/Fluent
    License: MIT (see LICENSE-FLUENT)

    Loads the official Fluent release and applies Pryvex branding,
    a persistent mobile/desktop toggle button, and text-only tabs.
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

local function addPryvexToggle(window)
    if not window or not window.Root or not window.Root.Parent then
        return
    end

    local parent = window.Root.Parent
    local existing = parent:FindFirstChild("PryvexOpenClose")
    if existing then
        existing:Destroy()
    end

    -- This button stays visible while the Fluent window is minimized.
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Name = "PryvexOpenClose"
    toggleButton.Size = UDim2.fromOffset(52, 52)
    toggleButton.Position = UDim2.new(0, 18, 0.5, 0)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    toggleButton.BackgroundTransparency = 0.08
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = true
    toggleButton.Image = PRYVEX_ICON
    toggleButton.ScaleType = Enum.ScaleType.Fit
    toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.ZIndex = 100
    toggleButton.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(105, 170, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.12
    stroke.Parent = toggleButton

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 7)
    padding.PaddingLeft = UDim.new(0, 7)
    padding.PaddingRight = UDim.new(0, 7)
    padding.Parent = toggleButton

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(48, 48)
    sizeConstraint.MaxSize = Vector2.new(56, 56)
    sizeConstraint.Parent = toggleButton

    toggleButton.Activated:Connect(function()
        if window.Root and window.Root.Parent then
            window:Minimize()
        else
            toggleButton:Destroy()
        end
    end)

    -- Remove the floating button when the window is explicitly destroyed.
    local originalDestroy = window.Destroy
    function window:Destroy()
        if toggleButton and toggleButton.Parent then
            toggleButton:Destroy()
        end
        return originalDestroy(self)
    end
end

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

    -- Use text-only tabs: suppress Fluent's tab icons entirely.
    if window then
        local originalAddTab = window.AddTab

        window.AddTab = function(tabSelf, tabConfig)
            tabConfig = tabConfig or {}
            local textOnlyConfig = {}
            for key, value in pairs(tabConfig) do
                textOnlyConfig[key] = value
            end
            textOnlyConfig.Icon = ""

            local tab = originalAddTab(tabSelf, textOnlyConfig)

            if tab and tab.Frame then
                local iconImage = tab.Frame:FindFirstChildWhichIsA("ImageLabel")
                local titleLabel = tab.Frame:FindFirstChildWhichIsA("TextLabel")

                if iconImage then
                    iconImage.Visible = false
                    iconImage.Image = ""
                end

                if titleLabel then
                    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
                    titleLabel.Position = UDim2.new(0, 12, 0.5, 0)
                    titleLabel.Size = UDim2.new(1, -24, 1, 0)
                end
            end

            return tab
        end

        addPryvexToggle(window)
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
