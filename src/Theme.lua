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
return Theme
