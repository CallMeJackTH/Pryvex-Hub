# Pryvex Hub

A modular Roblox Luau interface starter with a dark navy and light-blue visual identity.

## Project structure

- `src/init.lua` — creates the window and public API
- `src/Theme.lua` — shared colors and dimensions
- `src/Components.lua` — reusable UI construction helpers
- `src/Tabs/` — example tab content
- `examples/ClientExample.client.lua` — example LocalScript usage

## Setup

1. Create a ModuleScript named `PryvexHub` in `ReplicatedStorage` and paste the contents of `src/init.lua` into it.
2. Put `Theme` and `Components` ModuleScripts beside `PryvexHub` in `ReplicatedStorage`, using `src/Theme.lua` and `src/Components.lua`.
3. Add a LocalScript under `StarterPlayerScripts`.
4. Require it with `require(game:GetService("ReplicatedStorage"):WaitForChild("PryvexHub"))`.

This is a UI framework starter, not an executor or exploit. Use it in experiences you own or are authorized to develop. Server-authoritative gameplay and permissions must be implemented on the server.

## Example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PryvexHub = require(ReplicatedStorage:WaitForChild("PryvexHub"))

local window = PryvexHub.CreateWindow({
    Title = "Pryvex Hub",
    SubTitle = "Workspace",
})

local home = window:AddTab({ Title = "Home", Icon = "home" })
home:AddParagraph({ Title = "Welcome", Content = "Pryvex Hub is ready." })
home:AddButton({ Title = "Show notification", Description = "Test the notification system", Callback = function()
    window:Notify({ Title = "Hello", Content = "Your interface is working.", Duration = 5 })
end })
```

## License

MIT — see [LICENSE](LICENSE).
