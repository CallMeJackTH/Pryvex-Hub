--[[
    Pryvex Hub - Fluent UI distribution
    UI framework: Fluent by dawid-scripts
    โลโก้ใหญ่ด้านบน tabs + title bar logo + floating toggle
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

-- ปุ่มลอย show/hide
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
    button.ScaleType = Enum.ScaleType.Fit
    button.ImageTransparency = 0
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.Active = true
    button.ZIndex = 1000
    button.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = button

    local iconPad = Instance.new("UIPadding")
    iconPad.PaddingTop = UDim.new(0, 8)
    iconPad.PaddingBottom = UDim.new(0, 8)
    iconPad.PaddingLeft = UDim.new(0, 8)
    iconPad.PaddingRight = UDim.new(0, 8)
    iconPad.Parent = button

    local dragging, dragInput, dragStart, startPosition, moved = false, nil, nil, nil, false

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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

-- หา container ของแท็บ (sidebar) แล้วใส่โลโก้ใหญ่ด้านบน
local function addSidebarLogo(window)
    if not window or not window.Root then return end

    -- Fluent โครงสร้างโดยทั่วไป: Root > ... > TabContainer / Sidebar
    local root = window.Root

    -- ลองหา frame ที่เป็นแถบแท็บซ้าย
    local candidates = {}

    local function scan(obj, depth)
        if depth > 6 then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                -- sidebar มักแคบและมีปุ่มแท็บ
                local size = child.AbsoluteSize
                if size.X > 80 and size.X < 220 and size.Y > 150 then
                    table.insert(candidates, child)
                end
                scan(child, depth + 1)
            end
        end
    end

    -- รอ 1 frame ให้ UI สร้างเสร็จ
    task.defer(function()
        task.wait(0.15)
        if not root or not root.Parent then return end

        scan(root, 0)

        -- เลือก candidate ที่สูงที่สุด (น่าจะเป็น sidebar)
        local sidebar = nil
        local bestH = 0
        for _, c in ipairs(candidates) do
            if c.AbsoluteSize.Y > bestH then
                bestH = c.AbsoluteSize.Y
                sidebar = c
            end
        end

        -- fallback: ใช้ TabHolder ถ้า Fluent มี
        if not sidebar then
            sidebar = root:FindFirstChild("TabHolder", true)
                or root:FindFirstChild("Tabs", true)
                or root:FindFirstChild("Sidebar", true)
        end

        if not sidebar then return end
        if sidebar:FindFirstChild("PryvexSidebarLogo") then return end

        -- ใส่ UIListLayout ถ้ายังไม่มี เพื่อเรียงโลโก้ไว้บนสุด
        local layout = sidebar:FindFirstChildWhichIsA("UIListLayout")
        if not layout then
            layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.Parent = sidebar
        else
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        end

        -- ดันลูกเดิมให้ LayoutOrder สูงขึ้น
        for _, child in ipairs(sidebar:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "PryvexSidebarLogo" then
                if child.LayoutOrder < 10 then
                    child.LayoutOrder = child.LayoutOrder + 10
                end
            end
        end

        -- กรอบโลโก้ใหญ่
        local holder = Instance.new("Frame")
        holder.Name = "PryvexSidebarLogo"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 72)
        holder.LayoutOrder = 0
        holder.ZIndex = 5
        holder.Parent = sidebar

        local logo = Instance.new("ImageLabel")
        logo.Name = "Icon"
        logo.BackgroundTransparency = 1
        logo.AnchorPoint = Vector2.new(0.5, 0.5)
        logo.Position = UDim2.fromScale(0.5, 0.5)
        logo.Size = UDim2.fromOffset(52, 52) -- ใหญ่ชัด
        logo.Image = PRYVEX_ICON
        logo.ScaleType = Enum.ScaleType.Fit
        logo.ImageTransparency = 0
        logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
        logo.ZIndex = 6
        logo.Parent = holder
    end)
end

-- โลโก้เล็กบน title bar (คงไว้)
local function addTitleLogo(window)
    if not window or not window.TitleBar or not window.TitleBar.Frame then return end

    local titleContent = window.TitleBar.Frame:FindFirstChildWhichIsA("Frame")
    if not titleContent then return end

    local old = titleContent:FindFirstChild("PryvexLogo")
    if old then old:Destroy() end

    local layout = titleContent:FindFirstChildWhichIsA("UIListLayout")
    if layout then
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
    end

    local titleLabel, subtitleLabel
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
    logo.Size = UDim2.fromOffset(18, 18)
    logo.Image = PRYVEX_ICON
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ImageTransparency = 0
    logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    logo.LayoutOrder = 0
    logo.Parent = titleContent

    if titleLabel then titleLabel.LayoutOrder = 1 end
    if subtitleLabel then subtitleLabel.LayoutOrder = 2 end
end

local originalCreateWindow = Fluent.CreateWindow

Fluent.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)

    addTitleLogo(window)
    addSidebarLogo(window)   -- ไอคอนใหญ่เหนือ tabs
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
