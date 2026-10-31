# Pryvex Hub

Pryvex Hub now uses the original **Fluent UI framework by dawid-scripts** as its UI system. The previous custom Pryvex UI implementation has been replaced. The existing Pryvex logo asset is retained: `rbxassetid://127972121421541`.

## Executor loader

For executor environments that support `loadstring` and `game:HttpGet`:

```lua
local URL = "https://raw.githubusercontent.com/CallMeJackTH/Pryvex-Hub/fluent-clone-integration/dist/PryvexHub.lua"
local Pryvex = loadstring(game:HttpGet(URL))()

local Window = Pryvex:CreateWindow({
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

The loader downloads the official Fluent release at runtime. Internet access and executor support for `loadstring` are required; this is not an offline/standalone bundle. The returned library keeps Fluent's API, with Pryvex branding and the original logo added to the Fluent title bar.

## Fluent API

Use the upstream Fluent API and its colon-call style, including `Pryvex:CreateWindow(...)`, `Window:AddTab(...)`, tab elements, notifications, dialogs, themes, and the upstream addons.

See the [Fluent example](https://github.com/dawid-scripts/Fluent/blob/master/Example.lua) for usage details.

## Credits and licenses

- UI framework: [dawid-scripts/Fluent](https://github.com/dawid-scripts/Fluent), licensed under MIT. See [LICENSE-FLUENT](LICENSE-FLUENT).
- Fluent also credits richie0866/remote-spy, violin-suzutsuki/LinoriaLib, 7kayoh/Acrylic, and Latte Softworks & Kotera in its upstream README.

Use scripts only in experiences you own or are authorized to test.
