--!strict
-- Pryvex Hub UI starter. Client-side UI only.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Theme)
local UI = require(script.Components)

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

    local windowSize = options.Size or Theme.Dimensions.Window
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

    UI.Label(sidebar, options.Subtitle or "CONTROL CENTER",
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

    function window:AddTab(name: string): TabApi
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

        function tab:AddButton(text: string, callback: (() -> ())?): TextButton
            local button = UI.Button(page, text, UDim2.new(1, -4, 0, 36), callback)
            return button
        end

        function tab:AddToggle(text: string, default: boolean, callback: ((boolean) -> ())?): TextButton
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

    function window:Notify(title: string, message: string)
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
        task.delay(3, function()
            if toast.Parent then
                toast:Destroy()
            end
        end)
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

return PryvexHub
