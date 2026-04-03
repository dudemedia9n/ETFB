local Players = game:GetService("Players")
local player = Players.LocalPlayer -- Assuming this is the local player reference

function applyAllPremiumLabels()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            -- Apply premium labels to players other than the local player
            applyPremiumLabel(p)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if p == player then return end -- Skip the local player when a new player is added
    -- Handle new player
end)

function applyPremiumLabel(targetPlayer)
    -- Removed local player check since it's already filtered out
    -- Code to apply the premium label
end