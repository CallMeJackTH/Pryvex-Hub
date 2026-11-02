-- =========================================================================
-- Pryvex Hub
-- Super Jump = Climb + Dash
-- โลโก้ใหญ่เหนือแท็บทั้งหมด
-- =========================================================================

local CoreGui     = game:GetService("CoreGui")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PRYVEX_ICON = "rbxassetid://127972121421541"

-- =========================================================================
-- 1. กันรันซ้อน
-- =========================================================================
if _G.PryvexHubInstance then
    pcall(function() _G.PryvexHubInstance:Destroy() end)
    _G.PryvexHubInstance = nil
end

if _G.SuperJumpConnection then
    pcall(function() _G.SuperJumpConnection:Disconnect() end)
    _G.SuperJumpConnection = nil
end

local function destroyOldUI(name)
    local fromCore = CoreGui:FindFirstChild(name)
    if fromCore then pcall(function() fromCore:Destroy() end) end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local fromPg = pg:FindFirstChild(name)
            if fromPg then pcall(function() fromPg:Destroy() end) end
        end
    end
end

destroyOldUI("Fluent")
destroyOldUI("Pryvex Hub")
destroyOldUI("PryvexHub")

-- =========================================================================
-- 2. Save / Load Config
-- =========================================================================
local ConfigFolder = "Pryvex_Hub"
local ConfigFile   = ConfigFolder .. "/config.json"

if type(makefolder) == "function" and not isfolder(ConfigFolder) then
    pcall(makefolder, ConfigFolder)
end

local SavedData = {}

local function SaveConfig()
    if type(writefile) ~= "function" then return end
    local ok, json = pcall(function()
        return HttpService:JSONEncode(SavedData)
    end)
    if ok and json then
        pcall(writefile, ConfigFile, json)
    end
end

local function LoadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
    if not isfile(ConfigFile) then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)
    if ok and type(data) == "table" then
        SavedData = data
        return true
    end
    return false
end

local HasOldConfig = LoadConfig()

-- =========================================================================
-- 3. โหลด UI
-- =========================================================================
local URL = "https://raw.githubusercontent.com/CallMeJackTH/Pryvex-Hub/fluent-clone-integration/dist/PryvexHub.lua"
local Pryvex = loadstring(game:HttpGet(URL))()

local Window = Pryvex:CreateWindow({
    Title       = "Pryvex Hub",
    SubTitle    = "Workspace",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

_G.PryvexHubInstance = Window

-- =========================================================================
-- 4. ใส่โลโก้ใหญ่เหนือแท็บ (ทำงานหลัง UI สร้างเสร็จ)
-- =========================================================================
task.spawn(function()
    task.wait(0.25) -- รอ Fluent สร้าง DOM

    local root = Window.Root
    if not root then
        warn("[Pryvex] Window.Root not found")
        return
    end

    -- หา sidebar: frame แคบด้านซ้ายที่มีความสูงเยอะ
    local sidebar = nil
    local bestScore = 0

    local function consider(frame)
        if not frame:IsA("Frame") and not frame:IsA("ScrollingFrame") then return end
        local s = frame.AbsoluteSize
        if s.X < 90 or s.X > 200 then return end
        if s.Y < 120 then return end
        local score = s.Y - (s.X * 0.5)
        if score > bestScore then
            bestScore = score
            sidebar = frame
        end
    end

    local function walk(obj, depth)
        if depth > 7 then return end
        for _, child in ipairs(obj:GetChildren()) do
            consider(child)
            walk(child, depth + 1)
        end
    end

    walk(root, 0)

    -- ชื่อที่ Fluent ใช้บ่อย
    if not sidebar then
        sidebar = root:FindFirstChild("TabHolder", true)
            or root:FindFirstChild("Tabs", true)
            or root:FindFirstChild("Sidebar", true)
            or root:FindFirstChild("TabContainer", true)
    end

    if not sidebar then
        warn("[Pryvex] Sidebar not found — logo skipped")
        return
    end

    if sidebar:FindFirstChild("PryvexSidebarLogo") then
        return
    end

    -- Layout
    local layout = sidebar:FindFirstChildWhichIsA("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Parent = sidebar
    end
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 6)

    -- ดันลูกเดิมลง
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "PryvexSidebarLogo" then
            child.LayoutOrder = math.max(child.LayoutOrder, 0) + 20
        end
    end

    -- โลโก้ใหญ่
    local holder = Instance.new("Frame")
    holder.Name = "PryvexSidebarLogo"
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, -8, 0, 80)
    holder.LayoutOrder = 0
    holder.ZIndex = 10
    holder.Parent = sidebar

    local logo = Instance.new("ImageLabel")
    logo.Name = "Icon"
    logo.BackgroundTransparency = 1
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.5)
    logo.Size = UDim2.fromOffset(56, 56)
    logo.Image = PRYVEX_ICON
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ImageTransparency = 0
    logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    logo.ZIndex = 11
    logo.Parent = holder

    print("[Pryvex] Sidebar logo added")
end)

-- =========================================================================
-- 5. Super Jump = Climb + Dash
-- =========================================================================
local SuperJumpActive = false

local CLIMB_IDS = {
    "rbxassetid://180436334",
    "180436334",
}

local DASH_IDS = {
    "rbxassetid://10480793962",
    "10480793962",
}

local function animMatches(animId, list)
    if not animId or type(animId) ~= "string" then return false end
    for _, id in ipairs(list) do
        if animId == id or animId:find(id, 1, true) then
            return true
        end
    end
    return false
end

_G.SuperJumpConnection = RunService.Heartbeat:Connect(function()
    if not SuperJumpActive then return end

    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp      = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    local hasClimb, hasDash = false, false

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local anim = track.Animation
        if anim and anim.AnimationId then
            local id = anim.AnimationId
            if animMatches(id, CLIMB_IDS) then
                hasClimb = true
            elseif animMatches(id, DASH_IDS) then
                hasDash = true
            end
        end
    end

    if hasClimb and hasDash then
        hrp.AssemblyLinearVelocity = Vector3.new(
            hrp.AssemblyLinearVelocity.X,
            180,
            hrp.AssemblyLinearVelocity.Z
        )
    end
end)

-- =========================================================================
-- 6. แท็บ UI
-- =========================================================================
local MainTab     = Window:AddTab({ Title = "Main",     Icon = "home" })
local FunTab      = Window:AddTab({ Title = "Fun",      Icon = "smile" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

MainTab:AddParagraph({
    Title   = "Welcome",
    Content = "Pryvex Hub is ready."
})

local AutoFarmToggle = MainTab:AddToggle("AutoFarmToggle", {
    Title   = "Auto Farm",
    Default = SavedData["AutoFarm"] == true
})

AutoFarmToggle:OnChanged(function(Value)
    SavedData["AutoFarm"] = Value
    SaveConfig()
    print("[Pryvex] Auto Farm " .. (Value and "ON" or "OFF"))
end)

MainTab:AddButton({
    Title       = "Test notification",
    Description = "Check that the UI is working",
    Callback = function()
        Pryvex:Notify({
            Title    = "Pryvex Hub",
            Content  = "Interface loaded successfully.",
            Duration = 5
        })
    end
})

FunTab:AddParagraph({
    Title   = "Fun",
    Content = "Super Jump: แอนิเมชันปีน + Dash พร้อมกัน = พุ่งขึ้นฟ้า"
})

local SuperJumpToggle = FunTab:AddToggle("SuperJumpToggle", {
    Title       = "Super Jump (Climb + Dash)",
    Description = "ปีนค้าง + Dash = พุ่งขึ้น",
    Default     = SavedData["SuperJump"] == true
})

SuperJumpToggle:OnChanged(function(Value)
    SavedData["SuperJump"] = Value
    SaveConfig()
    SuperJumpActive = Value
    print("[Pryvex] Super Jump " .. (Value and "ON" or "OFF"))
end)

SettingsTab:AddParagraph({
    Title   = "Config",
    Content = "บันทึก/ลบการตั้งค่าบนเครื่อง"
})

SettingsTab:AddButton({
    Title       = "Manual Save Config",
    Description = "บันทึกการตั้งค่าปัจจุบัน",
    Callback = function()
        SaveConfig()
        Pryvex:Notify({ Title = "Config", Content = "บันทึกเรียบร้อย", Duration = 3 })
    end
})

SettingsTab:AddButton({
    Title       = "Reset / Delete Config",
    Description = "ลบไฟล์ config",
    Callback = function()
        if type(delfile) == "function" and type(isfile) == "function" and isfile(ConfigFile) then
            pcall(delfile, ConfigFile)
            SavedData = {}
            Pryvex:Notify({
                Title    = "Config",
                Content  = "ลบแล้ว — รันสคริปต์ใหม่",
                Duration = 4
            })
        else
            Pryvex:Notify({
                Title    = "Config",
                Content  = "ไม่มีไฟล์ หรือไม่รองรับ delfile",
                Duration = 3
            })
        end
    end
})

if HasOldConfig then
    SuperJumpActive = SavedData["SuperJump"] == true
    Pryvex:Notify({
        Title    = "Pryvex Hub",
        Content  = "โหลดการตั้งค่าล่าสุดแล้ว",
        Duration = 4
    })
else
    Pryvex:Notify({
        Title    = "Pryvex Hub",
        Content  = "พร้อมใช้งาน",
        Duration = 3
    })
end

print("[Pryvex Hub] Loaded — sidebar logo inject + Climb/Dash Super Jump")
