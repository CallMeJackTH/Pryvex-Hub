--!strict
-- Example content builder. Pass the tab returned by window:AddTab("Home").
local Home = {}

function Home.Build(tab)
    tab:AddSection("OVERVIEW")
    tab:AddLabel("Welcome to Pryvex Hub.")
    tab:AddLabel("A clean, modular interface for your Roblox projects.")
    tab:AddSection("QUICK ACTIONS")
    tab:AddButton("Show welcome message", function()
        print("[Pryvex Hub] UI is ready.")
    end)
end

return Home
