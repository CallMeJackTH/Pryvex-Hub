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

return Theme
