-- WFW Addon: Warforged Watcher
-- Monitors chat loot for Warforged items and posts to World channel

local WFW = {}
local worldChannelNumber = nil
WFW.enabled = true

-- Utility: Find the channel number for 'World'
function WFW:FindWorldChannel()
    local channels = {GetChannelList()}
    for i = 1, #channels, 2 do
        local id, name = channels[i], channels[i+1]
        if name and type(name) == "string" and name:lower() == "world" then
            worldChannelNumber = id
            break
        end
    end
end

-- Utility: Check if item is Warforged using GetItemLinkTitanforge
function WFW:IsWarforged(itemLink)
    return itemLink and GetItemLinkTitanforge and GetItemLinkTitanforge(itemLink) == 2
end

-- Utility: Get forge level for an itemID
function WFW:GetForgeLevel(itemID)
    return _G.GetItemAttuneForge and _G.GetItemAttuneForge(itemID) or 0
end

-- Event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        WFW:FindWorldChannel()
    elseif event == "CHAT_MSG_LOOT" then
        if not WFW.enabled then return end
        local msg = ...
        local itemLink = msg:match("|c.-|r")
        if itemLink and worldChannelNumber then
            local titanforge = GetItemLinkTitanforge and GetItemLinkTitanforge(itemLink)
            if titanforge == 2 then
                SendChatMessage(itemLink .. " WFW!", "CHANNEL", nil, worldChannelNumber)
            end
        end
    end
end)

-- Slash command to toggle WFW
SLASH_WFW1 = "/wfw"
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
SlashCmdList["WFW"] = function(msg)
    msg = string.lower(trim(msg))
    if msg == "on" then
        WFW.enabled = true
        print("|cff00ff00[WFW]|r Enabled.")
    elseif msg == "off" then
        WFW.enabled = false
        print("|cffff0000[WFW]|r Disabled.")
    elseif msg == "debug" then
        local found = false
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    local titanforge = GetItemLinkTitanforge and GetItemLinkTitanforge(itemLink)
                    if titanforge == 2 then
                        print("[WFW Debug] Found Warforged: " .. itemLink .. " (Titanforge: 2)")
                        found = true
                    end
                end
            end
        end
        if not found then
            print("[WFW Debug] No Warforged items found in your bags.")
        end
    elseif msg:find("^forge") == 1 then
    local itemLink = msg:match("|c.-|r")
    if itemLink then
        local titanforge = GetItemLinkTitanforge and GetItemLinkTitanforge(itemLink)
        if titanforge then
            print("Titanforge value for", itemLink, "is", titanforge)
            if titanforge == 2 then
                print("This item is Warforged!")
            end
        else
            print("Could not determine Titanforge value for", itemLink)
        end
    else
        print("Usage: /wfw forge [itemlink]")
    end
else
    if WFW.enabled then
        print("|cff00ff00[WFW]|r is currently ENABLED. Use /wfw off to disable.")
    else
        print("|cffff0000[WFW]|r is currently DISABLED. Use /wfw on to enable.")
    end
    print("Use /wfw debug to scan your bags for Warforged items.")
end
end

_G.WFW = WFW
