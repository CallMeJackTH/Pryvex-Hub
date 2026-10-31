--[[
    Pryvex Hub - Fluent UI integration
    Based on Fluent by dawid-scripts (MIT License).
    Upstream: https://github.com/dawid-scripts/Fluent

    This build exposes Fluent's UI API through the Pryvex namespace.
    It is a lightweight loader; Fluent's release file is fetched at runtime.
]]

local FluentURL = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"

local function loadFluent()
    local request = game.HttpGet
    assert(type(request) == "function", "[Pryvex] HttpGet is unavailable")

    local source = game:HttpGet(FluentURL)
    assert(type(source) == "string" and #source > 0, "[Pryvex] Failed to download Fluent")

    local compiler = loadstring
    assert(type(compiler) == "function", "[Pryvex] This environment does not support loadstring")

    local chunk, compileError = compiler(source)
    assert(chunk, "[Pryvex] Fluent compile error: " .. tostring(compileError))

    local ok, library = pcall(chunk)
    assert(ok and type(library) == "table", "[Pryvex] Fluent failed to initialize: " .. tostring(library))

    return library
end

local Pryvex = loadFluent()

Pryvex.Name = "Pryvex Hub"
Pryvex.Brand = "Pryvex"
Pryvex.Version = "1.0.0"
Pryvex.Framework = "Fluent"

-- Keep the original Fluent API intact for full compatibility.
-- The Pryvex alias makes the library easier to identify in scripts.
Pryvex.CreatePryvexWindow = Pryvex.CreateWindow

return Pryvex
