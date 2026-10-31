# Pryvex Hub

Pryvex Hub is a Roblox Luau interface library using the Fluent UI framework as its UI core.

## Executor loader

For environments that explicitly support `loadstring` and `game:HttpGet` (using the separate Fluent build):

```lua
local URL = "https://raw.githubusercontent.com/CallMeJackTH/Pryvex-Hub/fluent-clone-integration/dist/PryvexFluent.lua"
local Pryvex = loadstring(game:HttpGet(URL))()

local Window = Pryvex.CreateWindow({
    Title = "Pryvex Hub",
    SubTitle = "Workspace",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "home"
})

MainTab:AddParagraph({
    Title = "Welcome",
    Content = "Pryvex Hub is ready."
})

MainTab:AddButton({
    Title = "Test notification",
    Description = "Check that the UI is working",
    Callback = function()
        Pryvex:Notify({
            Title = "Pryvex Hub",
            Content = "Interface loaded successfully.",
            Duration = 5
        })
    end
})
```

The separate loader exposes the Fluent API with Pryvex branding and loads Fluent from its official GitHub release at runtime. Internet access and executor support for `loadstring` are required. The Fluent source is not embedded in this loader, so it is not an offline or standalone build. The original `dist/PryvexHub.lua` remains unchanged.

## Included UI API

The upstream Fluent framework provides windows, tabs, sections, buttons, toggles, sliders, dropdowns, color pickers, text inputs, keybinds, paragraphs, notifications, dialogs, themes, and interface/save manager addons.

See the [Fluent example](https://github.com/dawid-scripts/Fluent/blob/master/Example.lua) for the complete upstream API reference.

## Credits and licenses

- UI framework: [dawid-scripts/Fluent](https://github.com/dawid-scripts/Fluent), licensed under MIT. See [LICENSE-FLUENT](LICENSE-FLUENT).
- Fluent also credits richie0866/remote-spy, violin-suzutsuki/LinoriaLib, 7kayoh/Acrylic, and Latte Softworks & Kotera in its upstream README.

## Usage note

Use UI scripts only in experiences you own or are authorized to test. This repository's UI layer does not provide gameplay exploits or player-targeting features.
