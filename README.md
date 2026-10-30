# Pryvex Hub

A modular Roblox Luau interface starter with a dark navy and light-blue visual identity.

## Project structure

- `src/init.lua` — creates the window and public API
- `src/Theme.lua` — shared colors and dimensions
- `src/Components.lua` — reusable UI construction helpers
- `src/Tabs/` — example tab content
- `examples/ClientExample.client.lua` — example LocalScript usage

## Setup

1. Copy the `src` folder into your Roblox experience.
2. Keep the modules together in a Folder named `PryvexHub` in `ReplicatedStorage`.
3. Add a LocalScript under `StarterPlayerScripts`.
4. Use the example script as a starting point.

This is a UI framework starter, not an executor or exploit. Use it in experiences you own or are authorized to develop. Server-authoritative gameplay and permissions must be implemented on the server.

## Example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hubFolder = ReplicatedStorage:WaitForChild("PryvexHub")
local PryvexHub = require(hubFolder:WaitForChild("init"))

local window = PryvexHub.CreateWindow({
    Title = "Pryvex Hub",
    Subtitle = "Workspace",
})

local home = window:AddTab("Home")
home:AddSection("Welcome")
home:AddLabel("Pryvex Hub is ready.")
home:AddButton("Show notification", function()
    window:Notify("Hello", "Your interface is working.")
end)
```

## License

MIT — see [LICENSE](LICENSE).
