--!strict
-- Pryvex Hub v2.1.0 single-file distribution.
-- Fluent-inspired graphite glass UI with working common controls.

-- Theme
--!strict
-- Pryvex Hub theme: Fluent-inspired graphite glass.
local Theme = {
    Colors = {
        Background = Color3.fromRGB(31, 32, 34),
        Sidebar = Color3.fromRGB(36, 37, 39),
        Surface = Color3.fromRGB(58, 59, 61),
        SurfaceHover = Color3.fromRGB(72, 73, 76),
        Border = Color3.fromRGB(115, 116, 119),
        Accent = Color3.fromRGB(82, 205, 245),
        AccentDark = Color3.fromRGB(42, 145, 185),
        Text = Color3.fromRGB(242, 242, 244),
        Muted = Color3.fromRGB(174, 174, 177),
        Success = Color3.fromRGB(112, 225, 177),
        Danger = Color3.fromRGB(255, 125, 142),
    },
    Transparency = { Window = 0.16, Sidebar = 0.12, Surface = 0.20, SurfaceHover = 0.10, Button = 0.22, Stroke = 0.72 },
    Animation = { Fast = 0.14, Normal = 0.22, Slow = 0.32 },
    Fonts = { Heading = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium },
    Dimensions = { Window = Vector2.new(780, 510), MinimumWindow = Vector2.new(620, 420), SidebarWidth = 174, CornerRadius = UDim.new(0, 9) },
}


-- Components
--!strict
local TweenService = game:GetService("TweenService")

local Components = {}

function Components.Create(className: string, properties: {[string]: any}?, parent: Instance?): Instance
    local object = Instance.new(className)

    if properties then
        for property, value in pairs(properties) do
            (object :: any)[property] = value
        end
    end

    object.Parent = parent
    return object
end

function Components.Round(parent: Instance, radius: number?)
    return Components.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
    }, parent)
end

function Components.Stroke(parent: Instance, color: Color3?, transparency: number?)
    return Components.Create("UIStroke", {
        Color = color or Theme.Colors.Border,
        Transparency = transparency or Theme.Transparency.Stroke,
        Thickness = 1,
    }, parent)
end

function Components.Label(parent: Instance, text: string, size: UDim2, position: UDim2, options: {[string]: any}?)
    options = options or {}

    return Components.Create("TextLabel", {
        Name = options.Name or "Label",
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Font = options.Font or Theme.Fonts.Body,
        Text = text,
        TextColor3 = options.Color or Theme.Colors.Text,
        TextSize = options.TextSize or 13,
        TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center,
        TextWrapped = options.TextWrapped or false,
    }, parent)
end

function Components.Button(parent: Instance, text: string, size: UDim2, callback: (() -> ())?)
    local button = Components.Create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Colors.Surface,
        BackgroundTransparency = Theme.Transparency.Button,
        BorderSizePixel = 0,
        Size = size,
        Font = Theme.Fonts.Medium,
        Text = text,
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
    }, parent)

    Components.Round(button, 9)
    local stroke = Components.Stroke(button)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Colors.SurfaceHover, BackgroundTransparency = Theme.Transparency.SurfaceHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), {Transparency = 0.18}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Colors.Surface, BackgroundTransparency = Theme.Transparency.Button}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.22), {Transparency = Theme.Transparency.Stroke}):Play()
    end)

    if callback then
        button.Activated:Connect(callback)
    end

    return button
end



-- Main library
local UI = Components
--!strict
-- Pryvex Hub v2.1.0 | Fluent-inspired graphite interface
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


local PryvexHub = {}

local function tw(obj, duration, props)
    local t = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end
local function round(parent, radius) UI.Round(parent, radius or 8) end
local function label(parent, text, size, pos, opts) return UI.Label(parent, text, size, pos, opts) end
local function stroke(parent, transparency)
    UI.Stroke(parent, Color3.fromRGB(125, 126, 129), transparency or 0.78)
end

function PryvexHub.CreateWindow(options)
    options = options or {}
    local player = Players.LocalPlayer
    assert(player, "PryvexHub must be loaded on the client")
    local playerGui = player:WaitForChild("PlayerGui")
    local previous = playerGui:FindFirstChild("PryvexHub")
    if previous then previous:Destroy() end

    local requested = options.Size or UDim2.fromOffset(780, 510)
    local width, height = math.max(620, requested.X.Offset), math.max(420, requested.Y.Offset)
    local gui = UI.Create("ScreenGui", {Name="PryvexHub", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, playerGui)
    local main = UI.Create("Frame", {
        Name="Window", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(width,height), BackgroundColor3=Theme.Colors.Background,
        BackgroundTransparency=.13, BorderSizePixel=0, ClipsDescendants=true,
    }, gui)
    round(main, 10); stroke(main, .55)
    local scale = UI.Create("UIScale", {Scale=.96}, main)
    tw(scale,.28,{Scale=1})

    -- Compact Fluent-style title bar.
    local titlebar = UI.Create("Frame", {Name="TitleBar",Size=UDim2.new(1,0,0,43),BackgroundColor3=Color3.fromRGB(43,44,46),BackgroundTransparency=.12,BorderSizePixel=0},main)
    label(titlebar, options.Title or "Pryvex Hub", UDim2.new(1,-130,1,0), UDim2.fromOffset(16,0), {TextSize=13,Color=Theme.Colors.Text})
    label(titlebar, "  by Pryvex", UDim2.fromOffset(75,43), UDim2.new(0, (options.Title and #tostring(options.Title)*7+20 or 95), 0, 0), {TextSize=12,Color=Theme.Colors.Muted})
    local function titleButton(text, x, callback)
        local b=UI.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,x,0,0),Size=UDim2.fromOffset(40,43),BackgroundTransparency=1,Text=text,TextSize=17,Font=Enum.Font.Gotham,TextColor3=Theme.Colors.Text,AutoButtonColor=false},titlebar)
        b.Activated:Connect(callback)
        b.MouseEnter:Connect(function() tw(b,.12,{BackgroundTransparency=.72,BackgroundColor3=Theme.Colors.SurfaceHover}) end)
        b.MouseLeave:Connect(function() tw(b,.12,{BackgroundTransparency=1}) end)
        return b
    end

    local sidebarWidth = 164
    local sidebar=UI.Create("Frame",{Name="Sidebar",Position=UDim2.fromOffset(0,43),Size=UDim2.new(0,sidebarWidth,1,-43),BackgroundColor3=Theme.Colors.Sidebar,BackgroundTransparency=.12,BorderSizePixel=0},main)
    local nav=UI.Create("Frame",{Position=UDim2.fromOffset(9,12),Size=UDim2.new(1,-18,1,-24),BackgroundTransparency=1},sidebar)
    UI.Create("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},nav)
    local content=UI.Create("Frame",{Name="Content",Position=UDim2.new(0,sidebarWidth,0,43),Size=UDim2.new(1,-sidebarWidth,1,-43),BackgroundTransparency=1},main)
    local pageTitle=label(content,"Main",UDim2.new(1,-40,0,35),UDim2.fromOffset(14,9),{Font=Enum.Font.GothamBold,TextSize=22,Color=Theme.Colors.Text})
    local divider=UI.Create("Frame",{Position=UDim2.new(0,0,0,42),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(115,116,119),BackgroundTransparency=.82,BorderSizePixel=0},content)

    local pages, navButtons, current = {}, {}, nil
    local window = {}
    local function selectTab(name)
        for n,p in pairs(pages) do p.Visible=(n==name) end
        for n,b in pairs(navButtons) do
            local active=n==name
            tw(b,.16,{BackgroundTransparency=active and .82 or 1,BackgroundColor3=Theme.Colors.SurfaceHover,TextColor3=active and Theme.Colors.Text or Theme.Colors.Muted})
            local marker=b:FindFirstChild("Marker")
            if marker then tw(marker,.16,{BackgroundTransparency=active and 0 or 1}) end
        end
        pageTitle.Text=name
        current=name
    end

    function window:AddTab(tabOptions)
        local name=if typeof(tabOptions)=="table" then (tabOptions.Title or "Main") else tostring(tabOptions)
        local icon=if typeof(tabOptions)=="table" then (tabOptions.Icon or "") else ""
        assert(not pages[name],"Tab already exists: "..name)
        local navButton=UI.Create("TextButton",{Name=name.."Tab",Size=UDim2.new(1,0,0,34),BackgroundColor3=Theme.Colors.SurfaceHover,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.Gotham,Text=(icon~="" and icon.."   " or "   ")..name,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Colors.Muted},nav)
        round(navButton,7)
        local marker=UI.Create("Frame",{Name="Marker",Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(3,18),BackgroundColor3=Theme.Colors.Accent,BackgroundTransparency=1,BorderSizePixel=0},navButton); round(marker,3)
        local page=UI.Create("ScrollingFrame",{Name=name.."Page",Position=UDim2.fromOffset(14,52),Size=UDim2.new(1,-28,1,-64),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Theme.Colors.Accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false},content)
        UI.Create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},page)
        pages[name]=page; navButtons[name]=navButton
        navButton.Activated:Connect(function() selectTab(name) end)

        local tab={}
        local function card(h)
            local f=UI.Create("Frame",{Size=UDim2.new(1,-2,0,h),BackgroundColor3=Theme.Colors.Surface,BackgroundTransparency=.20,BorderSizePixel=0},page)
            round(f,6); stroke(f,.86)
            return f
        end
        function tab:AddSection(text)
            local f=UI.Create("Frame",{Size=UDim2.new(1,-2,0,26),BackgroundTransparency=1},page)
            label(f,string.upper(text),UDim2.new(1,0,1,0),UDim2.fromOffset(2,0),{Font=Enum.Font.GothamBold,TextSize=10,Color=Theme.Colors.Muted})
            return f
        end
        function tab:AddLabel(text)
            local f=card(38); label(f,text,UDim2.new(1,-22,1,0),UDim2.fromOffset(12,0),{TextSize=13}); return f
        end
        function tab:AddParagraph(opts)
            opts=opts or {}; local f=card(opts.Height or 72)
            label(f,opts.Title or "Paragraph",UDim2.new(1,-20,0,22),UDim2.fromOffset(11,7),{TextSize=14})
            label(f,opts.Content or "",UDim2.new(1,-20,0,36),UDim2.fromOffset(11,27),{TextSize=12,Color=Theme.Colors.Muted,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
            return f
        end
        function tab:AddButton(opts, legacy)
            local cfg=if typeof(opts)=="table" then opts else {Title=tostring(opts),Callback=legacy}
            local f=card(cfg.Description and 54 or 42)
            local b=UI.Create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},f)
            label(f,cfg.Title or "Button",UDim2.new(1,-42,0,22),UDim2.fromOffset(11,cfg.Description and 5 or 10),{TextSize=13})
            if cfg.Description then label(f,cfg.Description,UDim2.new(1,-42,0,18),UDim2.fromOffset(11,27),{TextSize=11,Color=Theme.Colors.Muted}) end
            label(f,"›",UDim2.fromOffset(24,32),UDim2.new(1,-30,.5,-16),{TextSize=22,TextXAlignment=Enum.TextXAlignment.Center,Color=Theme.Colors.Muted})
            b.Activated:Connect(function() if cfg.Callback then cfg.Callback() end end)
            b.MouseEnter:Connect(function() tw(f,.12,{BackgroundTransparency=.06,BackgroundColor3=Theme.Colors.SurfaceHover}) end)
            b.MouseLeave:Connect(function() tw(f,.16,{BackgroundTransparency=.20,BackgroundColor3=Theme.Colors.Surface}) end)
            return b
        end
        function tab:AddToggle(nameOrOptions, opts, legacy)
            local cfg=if typeof(nameOrOptions)=="table" then nameOrOptions else (typeof(opts)=="table" and opts or {})
            local name=if typeof(nameOrOptions)=="table" then (cfg.Title or "Toggle") else tostring(nameOrOptions)
            local value=cfg.Default==true or opts==true
            local callback=cfg.Callback or legacy
            local f=card(42)
            label(f,name,UDim2.new(1,-72,1,0),UDim2.fromOffset(11,0),{TextSize=13})
            local track=UI.Create("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(38,20),BackgroundColor3=Color3.fromRGB(91,92,95),BorderSizePixel=0},f); round(track,12)
            local knob=UI.Create("Frame",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.fromRGB(225,225,227),BorderSizePixel=0},track); round(knob,10)
            local hit=UI.Create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},f)
            local function refresh()
                tw(track,.16,{BackgroundColor3=value and Theme.Colors.AccentDark or Color3.fromRGB(91,92,95)})
                tw(knob,.16,{Position=value and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)})
            end
            refresh()
            hit.Activated:Connect(function() value=not value; refresh(); if callback then callback(value) end end)
            return {SetValue=function(_,v) value=not not v; refresh(); if callback then callback(value) end end,GetValue=function() return value end,Instance=f}
        end
        function tab:AddSlider(nameOrOptions, opts)
            local cfg=if typeof(nameOrOptions)=="table" then nameOrOptions else (opts or {})
            local name=if typeof(nameOrOptions)=="table" then (cfg.Title or "Slider") else tostring(nameOrOptions)
            local min,max=cfg.Min or 0,cfg.Max or 100
            local value=math.clamp(cfg.Default or min,min,max)
            local f=card(58)
            label(f,name,UDim2.new(.48,0,0,22),UDim2.fromOffset(11,5),{TextSize=13})
            local valueText=label(f,tostring(value),UDim2.fromOffset(36,22),UDim2.new(1,-166,0,5),{TextSize=12,Color=Theme.Colors.Muted,TextXAlignment=Enum.TextXAlignment.Right})
            local bar=UI.Create("Frame",{Position=UDim2.new(1,-151,0,25),Size=UDim2.fromOffset(132,4),BackgroundColor3=Color3.fromRGB(105,106,109),BorderSizePixel=0},f); round(bar,4)
            local fill=UI.Create("Frame",{Size=UDim2.new((value-min)/math.max(1,max-min),0,1,0),BackgroundColor3=Theme.Colors.Accent,BorderSizePixel=0},bar); round(fill,4)
            local knob=UI.Create("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((value-min)/math.max(1,max-min),0,.5,0),Size=UDim2.fromOffset(13,13),BackgroundColor3=Theme.Colors.Accent,BorderSizePixel=0},bar); round(knob,10)
            local hit=UI.Create("TextButton",{Position=UDim2.new(1,-155,0,12),Size=UDim2.fromOffset(140,30),BackgroundTransparency=1,Text="",TextSize=1},f)
            local dragging=false
            local function setFromX(x)
                local alpha=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                value=math.floor((min+(max-min)*alpha)+.5)
                fill.Size=UDim2.new(alpha,0,1,0); knob.Position=UDim2.new(alpha,0,.5,0); valueText.Text=tostring(value)
                if cfg.Callback then cfg.Callback(value) end
            end
            hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(input.Position.X) end end)
            hit.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then setFromX(input.Position.X) end end)
            return {GetValue=function() return value end,SetValue=function(_,v) value=math.clamp(v,min,max); local a=(value-min)/math.max(1,max-min); fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0); valueText.Text=tostring(value) end,Instance=f}
        end
        function tab:AddDropdown(nameOrOptions, opts)
            local cfg=if typeof(nameOrOptions)=="table" then nameOrOptions else (opts or {})
            local name=if typeof(nameOrOptions)=="table" then (cfg.Title or "Dropdown") else tostring(nameOrOptions)
            local items=cfg.Values or cfg.Options or {}
            local selected=cfg.Default or items[1]
            local f=card(44)
            label(f,name,UDim2.new(.42,0,1,0),UDim2.fromOffset(11,0),{TextSize=13})
            local choice=UI.Create("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-9,.5,0),Size=UDim2.new(.52,0,0,31),BackgroundColor3=Color3.fromRGB(77,78,81),BackgroundTransparency=.18,BorderSizePixel=0,Text=tostring(selected or "Select"),TextColor3=Theme.Colors.Text,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false},f); round(choice,6); stroke(choice,.9)
            local opened=false
            choice.Activated:Connect(function()
                if opened then return end; opened=true
                local menu=UI.Create("Frame",{Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,math.min(#items,5)*29+8),BackgroundColor3=Color3.fromRGB(52,53,55),BorderSizePixel=0,ZIndex=8},choice); round(menu,6); stroke(menu,.7)
                UI.Create("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},menu)
                for _,item in ipairs(items) do
                    local opt=UI.Create("TextButton",{Size=UDim2.new(1,-8,0,27),BackgroundTransparency=1,Text=tostring(item),TextColor3=Theme.Colors.Text,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false,ZIndex=9},menu)
                    opt.Activated:Connect(function() selected=item; choice.Text=tostring(item); menu:Destroy(); opened=false; if cfg.Callback then cfg.Callback(item) end end)
                end
                if #items==0 then menu:Destroy(); opened=false end
            end)
            return {GetValue=function() return selected end,SetValue=function(_,v) selected=v; choice.Text=tostring(v) end,Instance=f}
        end
        function tab:AddMultiDropdown(nameOrOptions, opts)
            local cfg=if typeof(nameOrOptions)=="table" then nameOrOptions else (opts or {})
            local name=if typeof(nameOrOptions)=="table" then (cfg.Title or "Multi-select") else tostring(nameOrOptions)
            local values=cfg.Values or cfg.Options or {}; local selected={}
            for _,v in ipairs(cfg.Default or {}) do selected[v]=true end
            local f=card(44); label(f,name,UDim2.new(.42,0,1,0),UDim2.fromOffset(11,0),{TextSize=13})
            local choice=UI.Create("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-9,.5,0),Size=UDim2.new(.52,0,0,31),BackgroundColor3=Color3.fromRGB(77,78,81),BackgroundTransparency=.18,BorderSizePixel=0,Text="Select values  ⌄",TextColor3=Theme.Colors.Text,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false},f); round(choice,6)
            local opened=false
            local function updateText()
                local names={}; for _,v in ipairs(values) do if selected[v] then table.insert(names,tostring(v)) end end
                choice.Text=#names>0 and table.concat(names,", ") or "Select values  ⌄"
            end
            choice.Activated:Connect(function()
                if opened then return end; opened=true
                local menu=UI.Create("Frame",{Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,math.min(#values,5)*29+8),BackgroundColor3=Color3.fromRGB(52,53,55),BorderSizePixel=0,ZIndex=8},choice); round(menu,6)
                UI.Create("UIListLayout",{Padding=UDim.new(0,2)},menu)
                for _,v in ipairs(values) do
                    local opt=UI.Create("TextButton",{Size=UDim2.new(1,-8,0,27),BackgroundTransparency=1,Text=(selected[v] and "☑  " or "□  ")..tostring(v),TextColor3=Theme.Colors.Text,TextSize=12,ZIndex=9,AutoButtonColor=false},menu)
                    opt.Activated:Connect(function() selected[v]=not selected[v]; opt.Text=(selected[v] and "☑  " or "□  ")..tostring(v); updateText(); if cfg.Callback then local out={}; for _,item in ipairs(values) do if selected[item] then table.insert(out,item) end end; cfg.Callback(out) end end)
                end
                local close=UI.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,-24),Size=UDim2.fromOffset(55,22),BackgroundTransparency=1,Text="Done",TextColor3=Theme.Colors.Accent,TextSize=11,ZIndex=10},menu)
                close.Activated:Connect(function() menu:Destroy(); opened=false end)
            end)
            return {GetValue=function() local out={}; for _,v in ipairs(values) do if selected[v] then table.insert(out,v) end end; return out end,Instance=f}
        end
        if not current then selectTab(name) end
        return tab
    end

    function window:Notify(opts, legacyMessage)
        local cfg=if typeof(opts)=="table" then opts else {Title=tostring(opts),Content=legacyMessage or ""}
        local toast=UI.Create("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,320,1,-18),Size=UDim2.fromOffset(290,72),BackgroundColor3=Color3.fromRGB(48,49,51),BackgroundTransparency=.05,BorderSizePixel=0},gui)
        round(toast,8); stroke(toast,.55)
        label(toast,cfg.Title or "Pryvex Hub",UDim2.new(1,-24,0,22),UDim2.fromOffset(13,8),{TextSize=13})
        label(toast,cfg.Content or "",UDim2.new(1,-24,0,30),UDim2.fromOffset(13,33),{TextSize=11,Color=Theme.Colors.Muted,TextWrapped=true})
        tw(toast,.24,{Position=UDim2.new(1,-16,1,-16)})
        task.delay(cfg.Duration or 3,function() if toast.Parent then tw(toast,.2,{Position=UDim2.new(1,320,1,-16),BackgroundTransparency=1}); task.wait(.22); if toast.Parent then toast:Destroy() end end end)
    end
    function window:Dialog(opts)
        opts=opts or {}
        local overlay=UI.Create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.4,ZIndex=20},gui)
        local box=UI.Create("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.53),Size=UDim2.fromOffset(350,180),BackgroundColor3=Color3.fromRGB(49,50,52),BorderSizePixel=0,ZIndex=21},overlay); round(box,9); stroke(box,.5)
        label(box,opts.Title or "Pryvex Hub",UDim2.new(1,-28,0,26),UDim2.fromOffset(14,12),{TextSize=15})
        label(box,opts.Content or "",UDim2.new(1,-28,0,75),UDim2.fromOffset(14,45),{TextSize=12,Color=Theme.Colors.Muted,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        for i,item in ipairs(opts.Buttons or {{Title="OK"}}) do
            local b=UI.Button(box,item.Title or "OK",UDim2.fromOffset(125,30),function() overlay:Destroy(); if item.Callback then item.Callback() end end)
            b.Position=UDim2.new(1,-137-(i-1)*132,1,-42); b.ZIndex=22
        end
        tw(box,.2,{Position=UDim2.fromScale(.5,.5)})
    end
    function window:SetVisible(value) main.Visible=value end
    function window:Destroy() gui:Destroy() end

    titleButton("×",-0,function() gui:Destroy() end).Position=UDim2.new(1,0,0,0)
    titleButton("—",-40,function() main.Visible=false end).Position=UDim2.new(1,-40,0,0)
    titleButton("□",-80,function() main.Size=main.Size==UDim2.fromOffset(width,height) and UDim2.new(1,-40,1,-40) or UDim2.fromOffset(width,height) end).Position=UDim2.new(1,-80,0,0)

    local dragging, dragStart, startPos = false, nil, nil
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; startPos=main.Position end
    end)
    local moveConnection=UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and startPos and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    local endConnection=UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    local oldDestroy=window.Destroy
    function window:Destroy() moveConnection:Disconnect(); endConnection:Disconnect(); gui:Destroy() end
    return window
end

local createWindow=PryvexHub.CreateWindow
function PryvexHub.CreateWindow(selfOrOptions,maybeOptions)
    return createWindow(if selfOrOptions==PryvexHub then maybeOptions else selfOrOptions)
end
PryvexHub.Version="2.1.0"
PryvexHub.Themes={"Graphite"}
PryvexHub.Theme="Graphite"
PryvexHub.Options={}
return PryvexHub
