--!strict
-- Pryvex Hub airy translucent theme.
local Theme = {
    Colors = {
        Background = Color3.fromRGB(15, 22, 35),
        Sidebar = Color3.fromRGB(20, 30, 46),
        Surface = Color3.fromRGB(31, 46, 66),
        SurfaceHover = Color3.fromRGB(43, 65, 90),
        Border = Color3.fromRGB(111, 151, 190),
        Accent = Color3.fromRGB(111, 199, 255),
        AccentDark = Color3.fromRGB(49, 126, 177),
        Text = Color3.fromRGB(240, 247, 255),
        Muted = Color3.fromRGB(166, 187, 211),
        Success = Color3.fromRGB(112, 225, 177),
        Danger = Color3.fromRGB(255, 125, 142),
    },
    Transparency = { Window = 0.10, Sidebar = 0.18, Surface = 0.24, SurfaceHover = 0.12, Button = 0.22, Stroke = 0.48 },
    Animation = { Fast = 0.14, Normal = 0.22, Slow = 0.32 },
    Fonts = { Heading = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium },
    Dimensions = { Window = Vector2.new(760, 500), MinimumWindow = Vector2.new(520, 360), SidebarWidth = 190, CornerRadius = UDim.new(0, 12) },
}
return Theme
