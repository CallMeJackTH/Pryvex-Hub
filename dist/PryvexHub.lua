--[[
    Pryvex Hub - Fluent UI distribution
    UI framework: Fluent by dawid-scripts
    Upstream: https://github.com/dawid-scripts/Fluent
    License: MIT (see LICENSE-FLUENT)

    Loads the official Fluent release and applies Pryvex branding,
    rounded menu icons, and a draggable floating open/close button.
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

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Name = "PryvexOpenClose"
    toggleButton.Size = UDim2.fromOffset(54, 54)
    toggleButton.Position = UDim2.new(0, 18, 0.5, 0)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    toggleButton.BackgroundTransparency = 0.05
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = true
    toggleButton.Image = PRYVEX_ICON
    toggleButton.ScaleType = Enum.ScaleType.Fit
    toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.ZIndex = 100
    toggleButton.Active = true
    toggleButton.Parent = parent

    -- Rounded-square shape; no outline/stroke.
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = toggleButton

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 7)
    padding.PaddingLeft = UDim.new(0, 7)
    padding.PaddingRight = UDim.new(0, 7)
    padding.Parent = toggleButton

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(48, 48)
    sizeConstraint.MaxSize = Vector2.new(60, 60)
    sizeConstraint.Parent = toggleButton

    -- Allow the floating button to be dragged freely with mouse or touch.
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local wasDragged = false
    local dragThreshold = 6

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            wasDragged = false
            dragStart = input.Position
            startPosition = toggleButton.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart

            if math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold then
                wasDragged = true
            end

            toggleButton.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    toggleButton.Activated:Connect(function()
        -- Ignore the click generated at the end of a drag gesture.
        if wasDragged then
            wasDragged = false
            return
        end

        if not toggleButton.Parent then
            return
        end

        if window.Root and window.Root.Parent then
            -- Read the actual UI visibility instead of relying only on the
            -- Minimized flag. This keeps the floating button synchronized
            -- even if Fluent's keyboard shortcut changed the window state.
            local shouldShowWindow = not window.Root.Visible
            window.Root.Visible = shouldShowWindow
            window.Minimized = not shouldShowWindow
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

    if window then
        -- Preserve Fluent's supplied menu icons and give image icons rounded corners.
        local originalAddTab = window.AddTab

        window.AddTab = function(tabSelf, tabConfig)
            local tab = originalAddTab(tabSelf, tabConfig or {})

            if tab and tab.Frame then
                local iconImage = tab.Frame:FindFirstChildWhichIsA("ImageLabel")

                if iconImage then
                    local iconCorner = iconImage:FindFirstChildOfClass("UICorner")
                    if not iconCorner then
                        iconCorner = Instance.new("UICorner")
                        iconCorner.CornerRadius = UDim.new(0, 5)
                        iconCorner.Parent = iconImage
                    end
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
