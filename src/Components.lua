--!strict
local Theme = require(script.Parent.Theme)

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

return Components
