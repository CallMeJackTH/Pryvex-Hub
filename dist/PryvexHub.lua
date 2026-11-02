--[[
    Pryvex Hub - Fluent UI distribution
    UI framework: Fluent by dawid-scripts
    Upstream: https://github.com/dawid-scripts/Fluent
    License: MIT (see LICENSE-FLUENT)
    Adds Pryvex branding, a correctly aligned title-bar logo, and a draggable
    floating show/hide control. Fluent's original API remains unchanged.
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

local function addFloatingToggle(window)
    local gui = Fluent.GUI
    if not gui or gui:FindFirstChild("PryvexFloatingToggle") then
        return
    end

    local button = Instance.new("ImageButton")
    button.Name = "PryvexFloatingToggle"
    button.Size = UDim2.fromOffset(48, 48)
    button.Position = UDim2.new(0, 18, 0.5, -24)
    button.BackgroundColor3 = Color3.fromRGB(17, 22, 32)
    button.BackgroundTransparency = 0.08
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Image = PRYVEX_ICON
    button.ImageRectOffset = Vector2.new(0, 0)
    button.ImageRectSize = Vector2.new(0, 0)
    button.ScaleType = Enum.ScaleType.Fit
    button.ImageTransparency = 0
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.Active = true
    button.Draggable = false
    button.ZIndex = 1000
    button.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = button

    -- กันไอคอนเบลอ / จัดกึ่งกลางในปุ่ม
    local iconPad = Instance.new("UIPadding")
    iconPad.PaddingTop = UDim.new(0, 8)
    iconPad.PaddingBottom = UDim.new(0, 8)
    iconPad.PaddingLeft = UDim.new(0, 8)
    iconPad.PaddingRight = UDim.new(0, 8)
    iconPad.Parent = button

    local dragging = false
    local dragInput
    local dragStart
    local startPosition
    local moved = false

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPosition = button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if math.abs(delta.X) + math.abs(delta.Y) > 6 then
                moved = true
            end
            button.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    button.Activated:Connect(function()
        if moved then
            moved = false
            return
        end
        if window.Root and window.Root.Parent then
            window.Minimized = window.Root.Visible
            window.Root.Visible = not window.Root.Visible
        end
    end)
end

-- ใส่โลโก้ Pryvex ในแถบชื่อ จัด Layout ให้ถูกต้อง
local originalCreateWindow = Fluent.CreateWindow

Fluent.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)

    if window and window.TitleBar and window.TitleBar.Frame then
        local titleContent = window.TitleBar.Frame:FindFirstChildWhichIsA("Frame")

        if titleContent then
            -- ลบโลโก้เก่าถ้ามี (กันซ้ำตอนรันซ้อน)
            local oldLogo = titleContent:FindFirstChild("PryvexLogo")
            if oldLogo then
                oldLogo:Destroy()
            end

            local layout = titleContent:FindFirstChildWhichIsA("UIListLayout")
            if layout then
                layout.Padding = UDim.new(0, 8)
                layout.VerticalAlignment = Enum.VerticalAlignment.Center
                layout.SortOrder = Enum.SortOrder.LayoutOrder
            end

            local titleLabel
            local subtitleLabel
            for _, child in ipairs(titleContent:GetChildren()) do
                if child:IsA("TextLabel") then
                    if not titleLabel then
                        titleLabel = child
                    else
                        subtitleLabel = child
                    end
                end
            end

            local logo = Instance.new("ImageLabel")
            logo.Name = "PryvexLogo"
            logo.BackgroundTransparency = 1
            logo.Size = UDim2.fromOffset(20, 20)
            logo.Image = PRYVEX_ICON
            logo.ScaleType = Enum.ScaleType.Fit
            logo.ImageTransparency = 0
            logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
            logo.LayoutOrder = 0
            logo.ZIndex = (titleLabel and titleLabel.ZIndex or 1)
            logo.Parent = titleContent

            if titleLabel then
                titleLabel.LayoutOrder = 1
            end
            if subtitleLabel then
                subtitleLabel.LayoutOrder = 2
            end
        end
    end

    addFloatingToggle(window)
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
