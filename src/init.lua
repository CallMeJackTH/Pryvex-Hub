--!strict
-- Pryvex Hub v2.2.0 - compact Fluent-style layout.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.Components)
local Library = {}

local function tween(object, duration, properties)
    local animation = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    animation:Play()
    return animation
end
local function round(parent, radius)
    UI.Round(parent, radius or 7)
end
local function label(parent, text, size, position, options)
    return UI.Label(parent, text, size, position, options)
end
local function makeStroke(parent, transparency)
    UI.Stroke(parent, Color3.fromRGB(125, 126, 128), transparency or 0.82)
end

function Library.CreateWindow(options)
    options = options or {}
    local player = Players.LocalPlayer
    assert(player, "Pryvex Hub must run on the client")
    local playerGui = player:WaitForChild("PlayerGui")
    local previous = playerGui:FindFirstChild("PryvexHub")
    if previous then previous:Destroy() end

    -- Similar proportions to the supplied Fluent reference image.
    local requested = options.Size or UDim2.fromOffset(580, 460)
    local width = math.max(500, requested.X.Offset)
    local height = math.max(360, requested.Y.Offset)
    local gui = UI.Create("ScreenGui", {
        Name = "PryvexHub", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local window = UI.Create("Frame", {
        Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Color3.fromRGB(25, 29, 37), BackgroundTransparency = 0.10,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    round(window, 11)
    makeStroke(window, 0.48)
    UI.Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 51, 65)), ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 27, 34))}), Rotation = 28}, window)
    local scale = UI.Create("UIScale", {Scale = 0.96}, window)
    tween(scale, 0.25, {Scale = 1})

    -- Title bar: narrow and understated, like the reference.
    local titlebar = UI.Create("Frame", {
        Name = "TitleBar", Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = Color3.fromRGB(34, 41, 52), BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
    }, window)
    UI.Create("ImageLabel", {
        Name = "PryvexLogo", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 8), Size = UDim2.fromOffset(27, 27),
        Image = "rbxassetid://127972121421541", ScaleType = Enum.ScaleType.Fit,
    }, titlebar)
    label(titlebar, options.Title or "PRYVEX HUB", UDim2.new(0, 150, 1, 0),
        UDim2.fromOffset(48, 0), {TextSize = 13, Font = Enum.Font.GothamBold, Color = Color3.fromRGB(244, 247, 252)})
    label(titlebar, "  /  PREMIUM INTERFACE", UDim2.fromOffset(160, 43),
        UDim2.fromOffset(151, 0), {TextSize = 9, Font = Enum.Font.GothamMedium, Color = Color3.fromRGB(145, 163, 185)})

    local function titleControl(text, x, callback)
        local button = UI.Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 0),
            Size = UDim2.fromOffset(38, 43), BackgroundTransparency = 1,
            BorderSizePixel = 0, Text = text, TextSize = 16,
            Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(225, 225, 227),
            AutoButtonColor = false,
        }, titlebar)
        button.Activated:Connect(callback)
        button.MouseEnter:Connect(function()
            tween(button, 0.12, {BackgroundColor3 = Color3.fromRGB(85, 86, 88), BackgroundTransparency = 0.35})
        end)
        button.MouseLeave:Connect(function() tween(button, 0.12, {BackgroundTransparency = 1}) end)
        return button
    end

    local sidebarWidth = 172
    local sidebar = UI.Create("Frame", {
        Name = "Sidebar", Position = UDim2.fromOffset(0, 43),
        Size = UDim2.new(0, sidebarWidth, 1, -43),
        BackgroundColor3 = Color3.fromRGB(27, 33, 43), BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
    }, window)
    UI.Create("Frame", {Name = "SidebarDivider", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = Color3.fromRGB(115, 151, 190), BackgroundTransparency = 0.82, BorderSizePixel = 0}, sidebar)
    local nav = UI.Create("Frame", {
        Name = "Navigation", Position = UDim2.fromOffset(9, 12),
        Size = UDim2.new(1, -18, 1, -24), BackgroundTransparency = 1,
    }, sidebar)
    UI.Create("UIListLayout", {
        Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
    }, nav)

    local content = UI.Create("Frame", {
        Name = "Content", Position = UDim2.new(0, sidebarWidth, 0, 43),
        Size = UDim2.new(1, -sidebarWidth, 1, -43),
        BackgroundTransparency = 1,
    }, window)
    local pageTitle = label(content, "Main", UDim2.new(1, -24, 0, 38),
        UDim2.fromOffset(14, 5), {
            Font = Enum.Font.GothamBold, TextSize = 27,
            Color = Color3.fromRGB(238, 238, 240),
        })
    local pages, navButtons = {}, {}
    local api = {}

    local function selectTab(name)
        for tabName, page in pairs(pages) do page.Visible = tabName == name end
        for tabName, button in pairs(navButtons) do
            local selected = tabName == name
            tween(button, 0.16, {
                BackgroundTransparency = selected and 0.84 or 1,
                BackgroundColor3 = Color3.fromRGB(80, 81, 83),
                TextColor3 = selected and Color3.fromRGB(242, 242, 244) or Color3.fromRGB(195, 195, 198),
            })
            local marker = button:FindFirstChild("SelectedMarker")
            if marker then tween(marker, 0.16, {BackgroundTransparency = selected and 0 or 1}) end
        end
        pageTitle.Text = name
    end

    function api:AddTab(tabOptions)
        local name = if typeof(tabOptions) == "table" then (tabOptions.Title or "Main") else tostring(tabOptions)
        local icon = if typeof(tabOptions) == "table" then (tabOptions.Icon or "") else ""
        assert(not pages[name], "Tab already exists: " .. name)

        local navButton = UI.Create("TextButton", {
            Name = name .. "Navigation", Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Color3.fromRGB(80, 81, 83), BackgroundTransparency = 1,
            BorderSizePixel = 0, AutoButtonColor = false,
            Font = Enum.Font.Gotham, Text = (icon ~= "" and icon .. "   " or "   ") .. name,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(195, 195, 198),
        }, nav)
        round(navButton, 6)
        local marker = UI.Create("Frame", {
            Name = "SelectedMarker", Position = UDim2.fromOffset(0, 8),
            Size = UDim2.fromOffset(3, 18), BackgroundColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 1, BorderSizePixel = 0,
        }, navButton)
        round(marker, 3)

        local page = UI.Create("ScrollingFrame", {
            Name = name .. "Page", Position = UDim2.fromOffset(14, 51),
            Size = UDim2.new(1, -28, 1, -61), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(135, 135, 138),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
            Visible = false,
        }, content)
        UI.Create("UIListLayout", {
            Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        pages[name], navButtons[name] = page, navButton
        navButton.Activated:Connect(function() selectTab(name) end)

        local tab = {}
        local function card(height)
            local frame = UI.Create("Frame", {
                Size = UDim2.new(1, -2, 0, height),
                BackgroundColor3 = Color3.fromRGB(55, 65, 80),
                BackgroundTransparency = 0.24, BorderSizePixel = 0,
            }, page)
            round(frame, 5)
            makeStroke(frame, 0.86)
            return frame
        end

        function tab:AddSection(text)
            local holder = UI.Create("Frame", {
                Size = UDim2.new(1, -2, 0, 25), BackgroundTransparency = 1,
            }, page)
            label(holder, string.upper(text), UDim2.new(1, 0, 1, 0), UDim2.new(),
                {Font = Enum.Font.GothamMedium, TextSize = 11, Color = Theme.Colors.Muted})
            return holder
        end
        function tab:AddLabel(text)
            local holder = card(38)
            label(holder, text, UDim2.new(1, -22, 1, 0), UDim2.fromOffset(11, 0), {TextSize = 13})
            return holder
        end
        function tab:AddParagraph(options)
            options = options or {}
            local holder = card(options.Height or 72)
            label(holder, options.Title or "Paragraph", UDim2.new(1, -20, 0, 20),
                UDim2.fromOffset(10, 7), {TextSize = 14})
            label(holder, options.Content or "", UDim2.new(1, -20, 0, 34),
                UDim2.fromOffset(10, 27), {
                    TextSize = 12, Color = Color3.fromRGB(181, 181, 184),
                    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
                })
            return holder
        end
        function tab:AddButton(options, legacyCallback)
            local cfg = if typeof(options) == "table" then options else {Title = tostring(options), Callback = legacyCallback}
            local holder = card(cfg.Description and 55 or 42)
            local hit = UI.Create("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false,
            }, holder)
            label(holder, cfg.Title or "Button", UDim2.new(1, -38, 0, 21),
                UDim2.fromOffset(10, cfg.Description and 5 or 10), {TextSize = 13})
            if cfg.Description then
                label(holder, cfg.Description, UDim2.new(1, -38, 0, 18),
                    UDim2.fromOffset(10, 25), {TextSize = 11, Color = Color3.fromRGB(178, 178, 181)})
            end
            label(holder, "›", UDim2.fromOffset(18, 28), UDim2.new(1, -25, 0.5, -14),
                {TextSize = 21, TextXAlignment = Enum.TextXAlignment.Center, Color = Color3.fromRGB(220, 220, 222)})
            hit.Activated:Connect(function() if cfg.Callback then cfg.Callback() end end)
            hit.MouseEnter:Connect(function() tween(holder, 0.12, {BackgroundTransparency = 0.12, BackgroundColor3 = Color3.fromRGB(82, 83, 85)}) end)
            hit.MouseLeave:Connect(function() tween(holder, 0.15, {BackgroundTransparency = 0.25, BackgroundColor3 = Color3.fromRGB(67, 68, 70)}) end)
            return hit
        end
        function tab:AddToggle(nameOrOptions, options, legacyCallback)
            local cfg = if typeof(nameOrOptions) == "table" then nameOrOptions else (typeof(options) == "table" and options or {})
            local toggleName = if typeof(nameOrOptions) == "table" then (cfg.Title or "Toggle") else tostring(nameOrOptions)
            local value = cfg.Default == true or options == true
            local callback = cfg.Callback or legacyCallback
            local holder = card(42)
            label(holder, toggleName, UDim2.new(1, -70, 1, 0), UDim2.fromOffset(10, 0), {TextSize = 13})
            local track = UI.Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
                Size = UDim2.fromOffset(38, 20), BackgroundColor3 = Color3.fromRGB(91, 92, 94),
                BorderSizePixel = 0,
            }, holder)
            round(track, 12)
            local knob = UI.Create("Frame", {
                Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = Color3.fromRGB(225, 225, 227), BorderSizePixel = 0,
            }, track)
            round(knob, 10)
            local hit = UI.Create("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, holder)
            local function refresh()
                tween(track, 0.15, {BackgroundColor3 = value and Theme.Colors.AccentDark or Color3.fromRGB(91, 92, 94)})
                tween(knob, 0.15, {Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)})
            end
            refresh()
            hit.Activated:Connect(function() value = not value; refresh(); if callback then callback(value) end end)
            return {
                GetValue = function() return value end,
                SetValue = function(_, nextValue) value = not not nextValue; refresh(); if callback then callback(value) end end,
                Instance = holder,
            }
        end
        function tab:AddSlider(nameOrOptions, options)
            local cfg = if typeof(nameOrOptions) == "table" then nameOrOptions else (options or {})
            local sliderName = if typeof(nameOrOptions) == "table" then (cfg.Title or "Slider") else tostring(nameOrOptions)
            local minimum, maximum = cfg.Min or 0, cfg.Max or 100
            local value = math.clamp(cfg.Default or minimum, minimum, maximum)
            local holder = card(58)
            label(holder, sliderName, UDim2.new(0.48, 0, 0, 22), UDim2.fromOffset(10, 4), {TextSize = 13})
            local valueLabel = label(holder, tostring(value), UDim2.fromOffset(28, 22), UDim2.new(1, -164, 0, 4),
                {TextSize = 12, Color = Theme.Colors.Muted, TextXAlignment = Enum.TextXAlignment.Right})
            local bar = UI.Create("Frame", {
                Position = UDim2.new(1, -151, 0, 27), Size = UDim2.fromOffset(132, 4),
                BackgroundColor3 = Color3.fromRGB(120, 120, 123), BorderSizePixel = 0,
            }, holder)
            round(bar, 4)
            local fill = UI.Create("Frame", {Size = UDim2.new((value-min)/math.max(1,maximum-min),0,1,0), BackgroundColor3 = Theme.Colors.Accent, BorderSizePixel = 0}, bar)
            round(fill, 4)
            local knob = UI.Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value-min)/math.max(1,maximum-min),0,0.5,0),
                Size = UDim2.fromOffset(13, 13), BackgroundColor3 = Theme.Colors.Accent, BorderSizePixel = 0,
            }, bar)
            round(knob, 10)
            local hit = UI.Create("TextButton", {Position = UDim2.new(1,-155,0,12),Size = UDim2.fromOffset(140,34),BackgroundTransparency = 1,Text = "",AutoButtonColor = false}, holder)
            local dragging = false
            local function setX(x)
                local alpha = math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)
                value = math.floor(min+(maximum-min)*alpha+0.5)
                fill.Size = UDim2.new(alpha,0,1,0); knob.Position = UDim2.new(alpha,0,0.5,0)
                valueLabel.Text = tostring(value)
                if cfg.Callback then cfg.Callback(value) end
            end
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setX(input.Position.X) end
            end)
            hit.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            local moveConnection = UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setX(input.Position.X) end
            end)
            return {
                GetValue = function() return value end,
                SetValue = function(_, nextValue)
                    value = math.clamp(nextValue, minimum, maximum)
                    local alpha = (value-minimum)/math.max(1,maximum-minimum)
                    fill.Size = UDim2.new(alpha,0,1,0); knob.Position = UDim2.new(alpha,0,0.5,0); valueLabel.Text = tostring(value)
                end,
                Instance = holder,
            }
        end
        function tab:AddDropdown(nameOrOptions, options)
            local cfg = if typeof(nameOrOptions) == "table" then nameOrOptions else (options or {})
            local dropdownName = if typeof(nameOrOptions) == "table" then (cfg.Title or "Dropdown") else tostring(nameOrOptions)
            local items = cfg.Values or cfg.Options or {}
            local selected = cfg.Default or items[1]
            local holder = card(43)
            label(holder, dropdownName, UDim2.new(0.42,0,1,0), UDim2.fromOffset(10,0), {TextSize = 13})
            local choice = UI.Create("TextButton", {
                AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-8,0.5,0),
                Size = UDim2.new(0.52,0,0,30), BackgroundColor3 = Color3.fromRGB(82,83,85),
                BackgroundTransparency = 0.12, BorderSizePixel = 0, Text = tostring(selected or "Select"),
                TextColor3 = Theme.Colors.Text, TextSize = 12, Font = Enum.Font.Gotham,
                AutoButtonColor = false,
            }, holder)
            round(choice, 5); makeStroke(choice, 0.9)
            local opened = false
            choice.Activated:Connect(function()
                if opened then return end
                opened = true
                local menu = UI.Create("Frame", {
                    Position = UDim2.new(0,0,1,3), Size = UDim2.new(1,0,0,math.min(#items,5)*27+6),
                    BackgroundColor3 = Color3.fromRGB(54,55,57), BorderSizePixel = 0, ZIndex = 10,
                }, choice)
                round(menu,5); makeStroke(menu,0.72)
                UI.Create("UIListLayout",{Padding=UDim.new(0,1)},menu)
                for _, item in ipairs(items) do
                    local optionButton = UI.Create("TextButton", {
                        Size = UDim2.new(1,-6,0,26), BackgroundTransparency = 1,
                        Text = tostring(item), TextColor3 = Theme.Colors.Text,
                        TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false, ZIndex = 11,
                    }, menu)
                    optionButton.Activated:Connect(function()
                        selected = item; choice.Text = tostring(item); menu:Destroy(); opened = false
                        if cfg.Callback then cfg.Callback(item) end
                    end)
                end
                if #items == 0 then menu:Destroy(); opened = false end
            end)
            return {GetValue=function() return selected end, SetValue=function(_,v) selected=v; choice.Text=tostring(v) end, Instance=holder}
        end
        function tab:AddMultiDropdown(nameOrOptions, options)
            local cfg = if typeof(nameOrOptions) == "table" then nameOrOptions else (options or {})
            local dropdownName = if typeof(nameOrOptions) == "table" then (cfg.Title or "Multi-select") else tostring(nameOrOptions)
            local items = cfg.Values or cfg.Options or {}
            local selected = {}
            for _, item in ipairs(cfg.Default or {}) do selected[item] = true end
            local holder = card(43)
            label(holder, dropdownName, UDim2.new(0.42,0,1,0), UDim2.fromOffset(10,0), {TextSize = 13})
            local choice = UI.Create("TextButton", {
                AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
                Size=UDim2.new(0.52,0,0,30),BackgroundColor3=Color3.fromRGB(82,83,85),
                BackgroundTransparency=0.12,BorderSizePixel=0,Text="Select values  ⌄",
                TextColor3=Theme.Colors.Text,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false,
            },holder)
            round(choice,5); makeStroke(choice,0.9)
            local opened = false
            local function updateText()
                local names = {}
                for _, item in ipairs(items) do if selected[item] then table.insert(names,tostring(item)) end end
                choice.Text = #names > 0 and table.concat(names,", ") or "Select values  ⌄"
            end
            updateText()
            choice.Activated:Connect(function()
                if opened then return end
                opened = true
                local menu = UI.Create("Frame", {
                    Position=UDim2.new(0,0,1,3),Size=UDim2.new(1,0,0,math.min(#items,5)*27+30),
                    BackgroundColor3=Color3.fromRGB(54,55,57),BorderSizePixel=0,ZIndex=10,
                },choice)
                round(menu,5); makeStroke(menu,0.72)
                for index,item in ipairs(items) do
                    local optionButton = UI.Create("TextButton", {
                        Position=UDim2.fromOffset(3,(index-1)*27),Size=UDim2.new(1,-6,0,26),
                        BackgroundTransparency=1,Text=(selected[item] and "☑  " or "□  ")..tostring(item),
                        TextColor3=Theme.Colors.Text,TextSize=12,AutoButtonColor=false,ZIndex=11,
                    },menu)
                    optionButton.Activated:Connect(function()
                        selected[item] = not selected[item]
                        optionButton.Text = (selected[item] and "☑  " or "□  ")..tostring(item)
                        updateText()
                        if cfg.Callback then
                            local result = {}; for _,v in ipairs(items) do if selected[v] then table.insert(result,v) end end
                            cfg.Callback(result)
                        end
                    end)
                end
                local done = UI.Create("TextButton", {
                    Position=UDim2.new(0,4,0,math.min(#items,5)*27),Size=UDim2.new(1,-8,0,25),
                    BackgroundTransparency=1,Text="Done",TextColor3=Theme.Colors.Accent,
                    TextSize=11,ZIndex=11,AutoButtonColor=false,
                },menu)
                done.Activated:Connect(function() menu:Destroy(); opened=false end)
            end)
            return {GetValue=function() local result={}; for _,v in ipairs(items) do if selected[v] then table.insert(result,v) end end; return result end,Instance=holder}
        end

        if next(pages) == nil then selectTab(name) end
        return tab
    end

    function api:Notify(options, legacyMessage)
        local cfg = if typeof(options) == "table" then options else {Title=tostring(options),Content=legacyMessage or ""}
        local toast = UI.Create("Frame", {
            AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,310,1,-14),
            Size=UDim2.fromOffset(280,68),BackgroundColor3=Color3.fromRGB(53,54,56),
            BackgroundTransparency=0.05,BorderSizePixel=0,
        },gui)
        round(toast,7); makeStroke(toast,0.6)
        label(toast,cfg.Title or "Pryvex Hub",UDim2.new(1,-22,0,21),UDim2.fromOffset(11,7),{TextSize=13})
        label(toast,cfg.Content or "",UDim2.new(1,-22,0,28),UDim2.fromOffset(11,31),{TextSize=11,Color=Theme.Colors.Muted,TextWrapped=true})
        tween(toast,0.22,{Position=UDim2.new(1,-14,1,-14)})
        task.delay(cfg.Duration or 3,function()
            if toast.Parent then tween(toast,0.18,{Position=UDim2.new(1,310,1,-14),BackgroundTransparency=1}); task.wait(0.2); if toast.Parent then toast:Destroy() end end
        end)
    end
    function api:Dialog(options)
        options = options or {}
        local overlay = UI.Create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.42,ZIndex=20},gui)
        local box = UI.Create("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.53),Size=UDim2.fromOffset(340,175),BackgroundColor3=Color3.fromRGB(54,55,57),BorderSizePixel=0,ZIndex=21},overlay)
        round(box,8); makeStroke(box,0.6)
        label(box,options.Title or "Pryvex Hub",UDim2.new(1,-24,0,25),UDim2.fromOffset(12,10),{TextSize=15})
        label(box,options.Content or "",UDim2.new(1,-24,0,70),UDim2.fromOffset(12,42),{TextSize=12,Color=Theme.Colors.Muted,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        for index,item in ipairs(options.Buttons or {{Title="OK"}}) do
            local button=UI.Button(box,item.Title or "OK",UDim2.fromOffset(110,29),function()
                overlay:Destroy(); if item.Callback then item.Callback() end
            end)
            button.Position=UDim2.new(1,-122-(index-1)*116,1,-39); button.ZIndex=22
        end
        tween(box,0.18,{Position=UDim2.fromScale(.5,.5)})
    end

    titleControl("×",0,function() gui:Destroy() end)
    titleControl("—",-38,function() window.Visible=false end)
    titleControl("□",-76,function()
        window.Size = window.Size == UDim2.fromOffset(width,height) and UDim2.new(1,-40,1,-40) or UDim2.fromOffset(width,height)
    end)

    local dragging, dragStart, startPosition = false, nil, nil
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPosition=window.Position
        end
    end)
    local moveConnection=UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and startPosition and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            window.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
        end
    end)
    local endConnection=UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=false end
    end)
    function api:SetVisible(value) window.Visible=value end
    function api:Destroy() moveConnection:Disconnect(); endConnection:Disconnect(); gui:Destroy() end
    return api
end

local createWindow=Library.CreateWindow
function Library.CreateWindow(selfOrOptions, maybeOptions)
    return createWindow(if selfOrOptions == Library then maybeOptions else selfOrOptions)
end
Library.Version="2.2.0"
Library.Themes={"FluentGraphite"}
Library.Theme="FluentGraphite"
Library.Options={}
return Library
