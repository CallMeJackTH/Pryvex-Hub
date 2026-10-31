--[[
    Pryvex Fluent UI
    Fluent UI framework by dawid-scripts, MIT License.
    https://github.com/dawid-scripts/Fluent

    This compatibility loader keeps the original PryvexHub.lua untouched.
    Fluent is downloaded from its official release when this file is executed.
]]

local FluentURL = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"

local source = game:HttpGet(FluentURL)
assert(type(source) == "string" and #source > 0, "[Pryvex Fluent] Could not download Fluent.")

local compiler = loadstring
assert(type(compiler) == "function", "[Pryvex Fluent] loadstring is not available.")

local chunk, compileError = compiler(source)
assert(chunk, "[Pryvex Fluent] Compile failed: " .. tostring(compileError))

local ok, Fluent = pcall(chunk)
assert(ok and type(Fluent) == "table", "[Pryvex Fluent] Initialization failed: " .. tostring(Fluent))

Fluent.Name = "Pryvex Hub"
Fluent.Brand = "Pryvex"
Fluent.Version = "1.0.0"
Fluent.Framework = "Fluent"

-- Keep Fluent's full API intact and add a Pryvex-named window alias.
Fluent.CreatePryvexWindow = Fluent.CreateWindow

return Fluent
