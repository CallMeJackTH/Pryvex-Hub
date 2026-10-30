--!strict
-- Example settings tab. Add your own client-side preferences here.
local Settings = {}

function Settings.Build(tab, window)
    tab:AddSection("INTERFACE")
    tab:AddToggle("Show interface", true, function(enabled)
        window:SetVisible(enabled)
    end)
    tab:AddButton("Test notification", function()
        window:Notify("Pryvex Hub", "Notifications are working.")
    end)
end

return Settings
