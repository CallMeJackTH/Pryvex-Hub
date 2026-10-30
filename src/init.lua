--!strict
-- Pryvex Hub - custom Fluent-inspired interface.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.Components)
local PryvexHub = {}

local function tween(object: Instance, duration: number, props: {[string]: any})
    local t = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function corner(parent: Instance, radius: number?)
    UI.Round(parent, radius or 10)
end

local function label(parent: Instance, text: string, size: UDim2, pos: UDim2, opts: {[string]: any}?)
    return UI.Label(parent, text, size, pos, opts)
end

function PryvexHub.CreateWindow(options: {[string]: any}?)
    options = options or {}
    local player = Players.LocalPlayer
    assert(player, "PryvexHub must be loaded on the client")
    local playerGui = player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("PryvexHub")
    if old then old:Destroy() end

    local gui = UI.Create("ScreenGui", {Name="PryvexHub", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, playerGui)
    local requested = options.Size or UDim2.fromOffset(780, 510)
    local width = math.max(620, requested.X.Offset)
    local height = math.max(420, requested.Y.Offset)

    local main = UI.Create("Frame", {
        Name="Window", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(width,height), BackgroundColor3=Color3.fromRGB(17,25,39),
        BackgroundTransparency=.12, BorderSizePixel=0, ClipsDescendants=true,
    }, gui)
    corner(main,14)
    UI.Stroke(main, Color3.fromRGB(116,170,210), .48)
    local scale=UI.Create("UIScale",{Scale=.94},main)
    tween(scale,.32,{Scale=1})

    -- Slim brand rail and navigation.
    local sidebar=UI.Create("Frame",{Name="Sidebar",Size=UDim2.new(0,196,1,0),BackgroundColor3=Color3.fromRGB(12,21,34),BackgroundTransparency=.12,BorderSizePixel=0},main)
    label(sidebar, "PRYVEX", UDim2.new(1,-72,0,24), UDim2.fromOffset(62,18), {Font=Enum.Font.GothamBold,TextSize=16,Color=Color3.fromRGB(130,207,255)})
    label(sidebar, "HUB  /  CONTROL CENTER", UDim2.new(1,-72,0,16), UDim2.fromOffset(62,42), {TextSize=8,Color=Color3.fromRGB(132,158,184)})
    local logo=UI.Create("ImageLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(17,18),Size=UDim2.fromOffset(34,34),Image="rbxassetid://127972121421541",ScaleType=Enum.ScaleType.Fit},sidebar)
    UI.Create("Frame",{Position=UDim2.fromOffset(16,70),Size=UDim2.new(1,-32,0,1),BackgroundColor3=Color3.fromRGB(83,119,151),BackgroundTransparency=.65,BorderSizePixel=0},sidebar)
    label(sidebar,"WORKSPACE",UDim2.new(1,-28,0,18),UDim2.fromOffset(16,88),{Font=Enum.Font.GothamBold,TextSize=9,Color=Color3.fromRGB(116,148,178)})

    local nav=UI.Create("Frame",{Position=UDim2.fromOffset(10,114),Size=UDim2.new(1,-20,1,-176),BackgroundTransparency=1},sidebar)
    UI.Create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},nav)
    local foot=UI.Create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,-12),Size=UDim2.new(1,-24,0,42),BackgroundColor3=Color3.fromRGB(36,57,75),BackgroundTransparency=.25,BorderSizePixel=0},sidebar)
    corner(foot,9)
    local dot=UI.Create("Frame",{Position=UDim2.fromOffset(12,17),Size=UDim2.fromOffset(8,8),BackgroundColor3=Color3.fromRGB(104,224,177),BorderSizePixel=0},foot); corner(dot,8)
    label(foot,"ALL SYSTEMS NORMAL",UDim2.new(1,-32,1,0),UDim2.fromOffset(27,0),{Font=Enum.Font.GothamMedium,TextSize=8,Color=Color3.fromRGB(176,202,220)})

    local content=UI.Create("Frame",{Name="Content",Position=UDim2.new(0,196,0,0),Size=UDim2.new(1,-196,1,0),BackgroundTransparency=1},main)
    local top=UI.Create("Frame",{Size=UDim2.new(1,0,0,76),BackgroundTransparency=1},content)
    local title=label(top,"Home",UDim2.new(1,-210,0,27),UDim2.fromOffset(26,14),{Font=Enum.Font.GothamBold,TextSize=20,Color=Color3.fromRGB(239,247,255)})
    label(top,"Your workspace at a glance",UDim2.new(1,-210,0,18),UDim2.fromOffset(27,43),{TextSize=10,Color=Color3.fromRGB(143,168,193)})
    local status=UI.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-22,0,22),Size=UDim2.fromOffset(112,27),BackgroundColor3=Color3.fromRGB(43,85,105),BackgroundTransparency=.42,BorderSizePixel=0},top); corner(status,14)
    label(status,"●  VERSION 1.0",UDim2.new(1,-12,1,0),UDim2.fromOffset(8,0),{Font=Enum.Font.GothamMedium,TextSize=8,Color=Color3.fromRGB(160,222,255)})
    UI.Create("Frame",{Position=UDim2.new(0,24,0,75),Size=UDim2.new(1,-48,0,1),BackgroundColor3=Color3.fromRGB(102,139,170),BackgroundTransparency=.72,BorderSizePixel=0},content)

    local pages={}, buttons={}, activeTab=nil
    local function selectTab(name)
        for tabName,page in pairs(pages) do page.Visible=(tabName==name) end
        for tabName,button in pairs(buttons) do
            local selected=(tabName==name)
            local marker=button:FindFirstChild("SelectedMarker")
            tween(button,.2,{BackgroundTransparency=selected and .16 or 1,BackgroundColor3=selected and Color3.fromRGB(45,103,139) or Color3.fromRGB(20,34,50),TextColor3=selected and Color3.fromRGB(240,249,255) or Color3.fromRGB(151,175,197)})
            if marker then tween(marker,.2,{BackgroundTransparency=selected and 0 or 1}) end
        end
        title.Text=name
        activeTab=name
    end

    local window={}
    function window:AddTab(tabOptions)
        local name=if typeof(tabOptions)=="table" then (tabOptions.Title or "Tab") else tostring(tabOptions)
        assert(not pages[name],"Tab already exists: "..name)
        local icon=if typeof(tabOptions)=="table" then (tabOptions.Icon or "◇") else "◇"
        local navButton=UI.Create("TextButton",{Name=name.."Navigation",Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(20,34,50),BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamMedium,Text="     "..icon.."     "..name,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(151,175,197)},nav)
        corner(navButton,8)
        local marker=UI.Create("Frame",{Name="SelectedMarker",Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(3,24),BackgroundColor3=Color3.fromRGB(123,207,255),BackgroundTransparency=1,BorderSizePixel=0},navButton); corner(marker,3)
        local page=UI.Create("ScrollingFrame",{Name=name.."Page",Position=UDim2.fromOffset(25,94),Size=UDim2.new(1,-50,1,-112),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(106,188,238),AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false},content)
        local layout=UI.Create("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},page)
        buttons[name]=navButton; pages[name]=page
        navButton.Activated:Connect(function() selectTab(name) end)
        local tab={}
        local function card(h)
            local frame=UI.Create("Frame",{Size=UDim2.new(1,-4,0,h),BackgroundColor3=Color3.fromRGB(36,54,73),BackgroundTransparency=.30,BorderSizePixel=0},page)
            corner(frame,10); UI.Stroke(frame,Color3.fromRGB(116,157,190),.78)
            return frame
        end
        function tab:AddSection(text)
            local holder=UI.Create("Frame",{Size=UDim2.new(1,-4,0,27),BackgroundTransparency=1},page)
            label(holder,string.upper(text),UDim2.new(1,0,1,0),UDim2.new(),{Font=Enum.Font.GothamBold,TextSize=9,Color=Color3.fromRGB(124,190,226)})
        end
        function tab:AddLabel(text)
            local holder=card(38); label(holder,text,UDim2.new(1,-24,1,0),UDim2.fromOffset(13,0),{TextSize=11,Color=Color3.fromRGB(195,213,229)}); return holder
        end
        function tab:AddParagraph(opts)
            opts=opts or {}; local holder=card(78)
            label(holder,opts.Title or "Information",UDim2.new(1,-24,0,25),UDim2.fromOffset(14,9),{Font=Enum.Font.GothamBold,TextSize=12})
            label(holder,opts.Content or "",UDim2.new(1,-24,0,34),UDim2.fromOffset(14,36),{TextSize=10,Color=Color3.fromRGB(164,188,209),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
            return holder
        end
        function tab:AddButton(opts,legacy)
            local text=if typeof(opts)=="table" then (opts.Title or "Button") else tostring(opts)
            local desc=if typeof(opts)=="table" then opts.Description else nil
            local callback=if typeof(opts)=="table" then opts.Callback else legacy
            local h=desc and 60 or 43
            local holder=card(h)
            local button=UI.Create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},holder)
            label(holder,text,UDim2.new(1,-68,0,22),UDim2.fromOffset(14,desc and 7 or 10),{Font=Enum.Font.GothamMedium,TextSize=11})
            if desc then label(holder,desc,UDim2.new(1,-68,0,17),UDim2.fromOffset(14,31),{TextSize=9,Color=Color3.fromRGB(155,180,202)}) end
            local arrow=label(holder,"›",UDim2.fromOffset(22,30),UDim2.new(1,-36,.5,-15),{TextSize=23,Color=Color3.fromRGB(129,204,245),TextXAlignment=Enum.TextXAlignment.Center})
            button.MouseEnter:Connect(function() tween(holder,.16,{BackgroundTransparency=.12,BackgroundColor3=Color3.fromRGB(54,82,107)}); tween(arrow,.16,{Position=UDim2.new(1,-31,.5,-15)}) end)
            button.MouseLeave:Connect(function() tween(holder,.18,{BackgroundTransparency=.30,BackgroundColor3=Color3.fromRGB(36,54,73)}); tween(arrow,.18,{Position=UDim2.new(1,-36,.5,-15)}) end)
            button.Activated:Connect(function() if callback then callback() end end)
            return button
        end
        function tab:AddToggle(toggleName,opts,legacy)
            local cfg=if typeof(opts)=="table" then opts else {}
            local text=cfg.Title or toggleName
            local enabled=if typeof(opts)=="boolean" then opts else (cfg.Default==true)
            local callback=cfg.Callback or legacy
            local holder=card(52)
            label(holder,text,UDim2.new(1,-90,1,0),UDim2.fromOffset(14,0),{Font=Enum.Font.GothamMedium,TextSize=11})
            local track=UI.Create("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.fromOffset(40,22),BackgroundColor3=Color3.fromRGB(83,105,124),BorderSizePixel=0},holder); corner(track,12)
            local knob=UI.Create("Frame",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(230,241,250),BorderSizePixel=0},track); corner(knob,10)
            local hit=UI.Create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},holder)
            local function refresh()
                tween(track,.18,{BackgroundColor3=enabled and Color3.fromRGB(65,166,218) or Color3.fromRGB(83,105,124)})
                tween(knob,.18,{Position=enabled and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)})
            end
            refresh()
            hit.Activated:Connect(function() enabled=not enabled; refresh(); if callback then callback(enabled) end end)
            return hit
        end
        if not activeTab then selectTab(name) end
        return tab
    end

    function window:Notify(opts,legacyMessage)
        local titleText=if typeof(opts)=="table" then (opts.Title or "Pryvex Hub") else tostring(opts)
        local message=if typeof(opts)=="table" then (opts.Content or "") else (legacyMessage or "")
        local duration=if typeof(opts)=="table" then (opts.Duration or 3) else 3
        local toast=UI.Create("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,310,1,-20),Size=UDim2.fromOffset(286,76),BackgroundColor3=Color3.fromRGB(27,44,62),BackgroundTransparency=.08,BorderSizePixel=0},gui)
        corner(toast,11); UI.Stroke(toast,Color3.fromRGB(113,194,240),.4)
        local accent=UI.Create("Frame",{Size=UDim2.new(0,3,1,-20),Position=UDim2.fromOffset(0,10),BackgroundColor3=Color3.fromRGB(112,204,255),BorderSizePixel=0},toast); corner(accent,3)
        label(toast,titleText,UDim2.new(1,-28,0,23),UDim2.fromOffset(15,10),{Font=Enum.Font.GothamBold,TextSize=12})
        label(toast,message,UDim2.new(1,-28,0,29),UDim2.fromOffset(15,36),{TextSize=10,Color=Color3.fromRGB(164,188,209),TextWrapped=true})
        tween(toast,.28,{Position=UDim2.new(1,-18,1,-18)})
        task.delay(duration,function() if toast.Parent then tween(toast,.2,{Position=UDim2.new(1,310,1,-18),BackgroundTransparency=1}); task.wait(.22); if toast.Parent then toast:Destroy() end end end)
    end
    function window:Dialog(opts)
        opts=opts or {}; local overlay=UI.Create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(4,10,18),BackgroundTransparency=.35,ZIndex=20},gui)
        local card=UI.Create("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.53),Size=UDim2.fromOffset(360,190),BackgroundColor3=Color3.fromRGB(28,44,62),BackgroundTransparency=.04,BorderSizePixel=0,ZIndex=21},overlay)
        corner(card,13); UI.Stroke(card,Color3.fromRGB(116,185,225),.45)
        label(card,opts.Title or "Pryvex Hub",UDim2.new(1,-30,0,28),UDim2.fromOffset(16,14),{Font=Enum.Font.GothamBold,TextSize=15})
        label(card,opts.Content or "",UDim2.new(1,-30,0,80),UDim2.fromOffset(16,49),{TextSize=11,Color=Color3.fromRGB(172,195,214),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        for i,item in ipairs(opts.Buttons or {{Title="OK"}}) do
            local btn=UI.Button(card,item.Title or "OK",UDim2.fromOffset(140,32),function() overlay:Destroy(); if item.Callback then item.Callback() end end)
            btn.Position=UDim2.new(1,-154-(i-1)*148,1,-46); btn.ZIndex=22
        end
        tween(card,.22,{Position=UDim2.fromScale(.5,.5)})
    end
    function window:SetVisible(visible) main.Visible=visible end
    function window:Destroy() gui:Destroy() end

    -- Drag window from the brand header area.
    local dragging=false; local dragStart=nil; local startPos=nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; startPos=main.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and startPos and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    return window
end

local createWindow=PryvexHub.CreateWindow
function PryvexHub.CreateWindow(selfOrOptions,maybeOptions)
    return createWindow(if selfOrOptions==PryvexHub then maybeOptions else selfOrOptions)
end
PryvexHub.Version="2.0.0"
PryvexHub.Themes={"Pryvex"}
PryvexHub.Theme="Pryvex"
PryvexHub.Options={}
return PryvexHub
