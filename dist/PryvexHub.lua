--!strict
-- Pryvex Hub single-file distribution.
-- Generated from src/Theme.lua, src/Components.lua, and src/init.lua.
-- UI framework only. No game automation or exploit functionality.

-- Theme
--!strict
-- Shared visual tokens for Pryvex Hub.

local Theme = {
    Colors = {
        Background = Color3.fromRGB(9, 15, 27),
        Sidebar = Color3.fromRGB(12, 21, 36),
        Surface = Color3.fromRGB(17, 29, 47),
        SurfaceHover = Color3.fromRGB(23, 40, 62),
        Border = Color3.fromRGB(37, 57, 79),
        Accent = Color3.fromRGB(85, 191, 255),
        AccentDark = Color3.fromRGB(37, 135, 196),
        Text = Color3.fromRGB(235, 244, 255),
        Muted = Color3.fromRGB(141, 165, 193),
        Success = Color3.fromRGB(94, 214, 158),
        Danger = Color3.fromRGB(245, 105, 119),
    },

    Fonts = {
        Heading = Enum.Font.GothamBold,
        Body = Enum.Font.Gotham,
        Medium = Enum.Font.GothamMedium,
    },

    Dimensions = {
        Window = Vector2.new(680, 460),
        MinimumWindow = Vector2.new(520, 360),
        SidebarWidth = 158,
        CornerRadius = UDim.new(0, 10),
    },
}



-- UI components
--!strict

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
        Transparency = transparency or 0,
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
        BorderSizePixel = 0,
        Size = size,
        Font = Theme.Fonts.Medium,
        Text = text,
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
    }, parent)

    Components.Round(button, 8)
    Components.Stroke(button)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.Colors.SurfaceHover
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Colors.Surface
    end)

    if callback then
        button.Activated:Connect(callback)
    end

    return button
end



-- Main library
--!strict
-- Pryvex Hub UI starter. Client-side UI only.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")


local PryvexHub = {}

type TabApi = {
    AddSection: (self: TabApi, title: string) -> (),
    AddLabel: (self: TabApi, text: string) -> TextLabel,
    AddButton: (self: TabApi, text: string, callback: (() -> ())?) -> TextButton,
    AddToggle: (self: TabApi, text: string, default: boolean, callback: ((boolean) -> ())?) -> TextButton,
}

type WindowApi = {
    AddTab: (self: WindowApi, name: string) -> TabApi,
    Notify: (self: WindowApi, title: string, message: string) -> (),
    SetVisible: (self: WindowApi, visible: boolean) -> (),
    Destroy: (self: WindowApi) -> (),
}

function PryvexHub.CreateWindow(options: {[string]: any}?): WindowApi
    options = options or {}

    local player = Players.LocalPlayer
    assert(player, "PryvexHub must be required from a LocalScript")

    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = UI.Create("ScreenGui", {
        Name = "PryvexHub",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local requestedSize = options.Size or UDim2.fromOffset(580, 460)
    local windowSize = Vector2.new(requestedSize.X.Offset, requestedSize.Y.Offset)
    local main = UI.Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(windowSize.X, windowSize.Y),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
    }, screenGui)
    UI.Round(main, 12)
    UI.Stroke(main, Theme.Colors.Border)

    local sidebar = UI.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, Theme.Dimensions.SidebarWidth, 1, 0),
        BackgroundColor3 = Theme.Colors.Sidebar,
        BorderSizePixel = 0,
    }, main)
    UI.Round(sidebar, 12)

    UI.Label(sidebar, options.Title or "Pryvex Hub",
        UDim2.new(1, -24, 0, 28), UDim2.fromOffset(14, 16),
        {Font = Theme.Fonts.Heading, TextSize = 17, Color = Theme.Colors.Accent})

    UI.Label(sidebar, options.SubTitle or options.Subtitle or "CONTROL CENTER",
        UDim2.new(1, -24, 0, 18), UDim2.fromOffset(14, 44),
        {TextSize = 9, Color = Theme.Colors.Muted})

    local tabList = UI.Create("ScrollingFrame", {
        Name = "TabList",
        Position = UDim2.fromOffset(8, 78),
        Size = UDim2.new(1, -16, 1, -88),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
    }, sidebar)

    UI.Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)

    local content = UI.Create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, Theme.Dimensions.SidebarWidth + 1, 0, 0),
        Size = UDim2.new(1, -Theme.Dimensions.SidebarWidth - 1, 1, 0),
        BackgroundTransparency = 1,
    }, main)

    local pageTitle = UI.Label(content, "Home",
        UDim2.new(1, -40, 0, 34), UDim2.fromOffset(20, 16),
        {Font = Theme.Fonts.Heading, TextSize = 20})

    local pages: {[string]: ScrollingFrame} = {}
    local tabButtons: {[string]: TextButton} = {}
    local tabCount = 0

    local function selectTab(name: string)
        for tabName, page in pairs(pages) do
            page.Visible = tabName == name
        end
        for tabName, button in pairs(tabButtons) do
            button.BackgroundColor3 = if tabName == name then Theme.Colors.AccentDark else Theme.Colors.Sidebar
            button.TextColor3 = if tabName == name then Theme.Colors.Text else Theme.Colors.Muted
        end
        pageTitle.Text = name
    end

    local window = {} :: any

    function window:AddTab(tabOptions: any): TabApi
        local name = if typeof(tabOptions) == "table" then (tabOptions.Title or "Tab") else tostring(tabOptions)
        assert(not pages[name], "Tab already exists: " .. name)
        tabCount += 1

        local tabButton = UI.Create("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Colors.Sidebar,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Theme.Fonts.Medium,
            Text = "  " .. name,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.Colors.Muted,
            LayoutOrder = tabCount,
        }, tabList)
        UI.Round(tabButton, 7)

        local page = UI.Create("ScrollingFrame", {
            Name = name .. "Page",
            Position = UDim2.fromOffset(20, 60),
            Size = UDim2.new(1, -40, 1, -78),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Colors.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            Visible = false,
        }, content)

        local layout = UI.Create("UIListLayout", {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        tabButtons[name] = tabButton
        pages[name] = page
        tabButton.Activated:Connect(function()
            selectTab(name)
        end)

        local tab = {} :: any

        function tab:AddSection(title: string)
            local section = UI.Create("Frame", {
                Name = "Section",
                Size = UDim2.new(1, -4, 0, 34),
                BackgroundTransparency = 1,
            }, page)
            UI.Label(section, title, UDim2.new(1, 0, 1, 0), UDim2.new(),
                {Font = Theme.Fonts.Heading, TextSize = 13, Color = Theme.Colors.Accent})
        end

        function tab:AddLabel(text: string): TextLabel
            local holder = UI.Create("Frame", {
                Size = UDim2.new(1, -4, 0, 38),
                BackgroundColor3 = Theme.Colors.Surface,
                BorderSizePixel = 0,
            }, page)
            UI.Round(holder, 8)
            UI.Label(holder, text, UDim2.new(1, -20, 1, 0), UDim2.fromOffset(10, 0),
                {TextSize = 12, Color = Theme.Colors.Muted})
            return holder :: any
        end

        function tab:AddParagraph(options: any)
            options = options or {}
            local holder = UI.Create("Frame", {
                Size = UDim2.new(1, -4, 0, 64),
                BackgroundColor3 = Theme.Colors.Surface,
                BorderSizePixel = 0,
            }, page)
            UI.Round(holder, 8)
            UI.Label(holder, options.Title or "Paragraph", UDim2.new(1, -20, 0, 22),
                UDim2.fromOffset(10, 5), {Font = Theme.Fonts.Heading, TextSize = 13})
            UI.Label(holder, options.Content or "", UDim2.new(1, -20, 0, 30),
                UDim2.fromOffset(10, 28), {TextSize = 11, Color = Theme.Colors.Muted, TextWrapped = true})
            return holder
        end

        function tab:AddButton(buttonOptions: any, legacyCallback: (() -> ())?): TextButton
            local text = if typeof(buttonOptions) == "table" then (buttonOptions.Title or "Button") else tostring(buttonOptions)
            local callback = if typeof(buttonOptions) == "table" then buttonOptions.Callback else legacyCallback
            local description = if typeof(buttonOptions) == "table" then buttonOptions.Description else nil
            local height = if description then 52 else 36
            local button = UI.Button(page, text, UDim2.new(1, -4, 0, height), callback)
            if description then
                button.Text = text .. "\\n" .. description
                button.TextWrapped = true
            end
            return button
        end

        function tab:AddToggle(toggleName: string, toggleOptions: any, legacyCallback: ((boolean) -> ())?): TextButton
            local config = if typeof(toggleOptions) == "table" then toggleOptions else {}
            local text = config.Title or toggleName
            local default = if typeof(toggleOptions) == "boolean" then toggleOptions else (config.Default or false)
            local callback = config.Callback or legacyCallback
            local enabled = default
            local button = UI.Button(page, "", UDim2.new(1, -4, 0, 38), nil)
            local function refresh()
                button.Text = string.format("%s                         %s", text, if enabled then "ON" else "OFF")
                button.TextColor3 = if enabled then Theme.Colors.Accent else Theme.Colors.Muted
            end
            refresh()
            button.Activated:Connect(function()
                enabled = not enabled
                refresh()
                if callback then
                    callback(enabled)
                end
            end)
            return button
        end

        if tabCount == 1 then
            selectTab(name)
        end

        return tab
    end

    function window:Notify(notification: any, legacyMessage: string?)
        local title = if typeof(notification) == "table" then (notification.Title or "Pryvex Hub") else tostring(notification)
        local message = if typeof(notification) == "table" then (notification.Content or "") else (legacyMessage or "")
        local duration = if typeof(notification) == "table" then (notification.Duration or 3) else 3
        local toast = UI.Create("Frame", {
            Name = "Notification",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.fromOffset(270, 68),
            BackgroundColor3 = Theme.Colors.Surface,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, screenGui)
        UI.Round(toast, 9)
        UI.Stroke(toast, Theme.Colors.Accent)
        UI.Label(toast, title, UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 5),
            {Font = Theme.Fonts.Heading, TextSize = 13, Color = Theme.Colors.Accent})
        UI.Label(toast, message, UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 31),
            {TextSize = 11, Color = Theme.Colors.Muted})
        task.delay(duration, function()
            if toast.Parent then
                toast:Destroy()
            end
        end)
    end

    function window:Dialog(dialogOptions: any)
        dialogOptions = dialogOptions or {}
        local buttons = dialogOptions.Buttons or {}
        local overlay = UI.Create("Frame", {
            Name = "DialogOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.35,
            ZIndex = 20,
        }, screenGui)
        local card = UI.Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(320, 170),
            BackgroundColor3 = Theme.Colors.Surface,
            BorderSizePixel = 0,
            ZIndex = 21,
        }, overlay)
        UI.Round(card, 10)
        UI.Stroke(card, Theme.Colors.Border)
        UI.Label(card, dialogOptions.Title or "Dialog", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 10),
            {Font = Theme.Fonts.Heading, TextSize = 15})
        UI.Label(card, dialogOptions.Content or "", UDim2.new(1, -24, 0, 75), UDim2.fromOffset(12, 42),
            {TextSize = 12, Color = Theme.Colors.Muted, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
        for index, item in ipairs(buttons) do
            local button = UI.Button(card, item.Title or "OK", UDim2.fromOffset(130, 30), function()
                overlay:Destroy()
                if item.Callback then item.Callback() end
            end)
            button.Position = UDim2.new(1, -142 - ((index - 1) * 138), 1, -42)
            button.ZIndex = 22
        end
    end

    function window:SetVisible(visible: boolean)
        main.Visible = visible
    end

    function window:Destroy()
        screenGui:Destroy()
    end

    -- Drag the window from its sidebar/header region.
    local dragging = false
    local dragStart: Vector2?
    local startPosition: UDim2?

    sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and startPosition
            and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return window
end

-- Keep both dot and colon calling styles working.
local createWindow = PryvexHub.CreateWindow

function PryvexHub.CreateWindow(selfOrOptions: any, maybeOptions: {[string]: any}?)
    local options = if selfOrOptions == PryvexHub then maybeOptions else selfOrOptions
    return createWindow(options)
end

PryvexHub.Version = "1.0.1"
PryvexHub.Themes = {"Dark"}
PryvexHub.Theme = "Dark"
PryvexHub.Options = {}

return PryvexHub
