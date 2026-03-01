-- PinDrop.lua
-- Broadcasts target info (name, type, HP%, coords, map pin) to a chat channel.
-- Usage: /pindrop <channel>
--   <channel> can be a number (custom channel), or a chat type keyword:
--   say, yell, party, raid, guild, instance
--
-- Example: /pindrop say
--          /pindrop raid
--          /pindrop 3

local ADDON_NAME = "PinDrop"
local VERSION = "1.0.0"

-- Friendly display names for UnitClassification return values
local CLASSIFICATION_LABELS = {
    ["normal"]    = "Normal",
    ["elite"]     = "Elite",
    ["rare"]      = "Rare",
    ["rareelite"] = "Rare Elite",
    ["worldboss"] = "World Boss",
    ["trivial"]   = "Trivial",
    ["minus"]     = "Minor",
}

-- Valid named chat channels and their SendChatMessage types
local NAMED_CHANNELS = {
    ["say"]      = "SAY",
    ["yell"]     = "YELL",
    ["party"]    = "PARTY",
    ["raid"]     = "RAID",
    ["guild"]    = "GUILD",
    ["instance"] = "INSTANCE_CHAT",
}

-- Print a message to the default chat frame, prefixed with the addon name
local function PDPrint(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[PinDrop]|r " .. msg)
end

-- Core function: gather data and broadcast to the chosen channel
local function BroadcastTargetInfo(input)
    -- Validate target
    if not UnitExists("target") then
        PDPrint("No target selected.")
        return
    end

    if UnitIsPlayer("target") then
        PDPrint("Target is a player. PinDrop only works on NPCs/mobs.")
        return
    end

    -- Target name
    local targetName = UnitName("target") or "Unknown"

    -- Target classification
    local classRaw = UnitClassification("target") or "normal"
    local classLabel = CLASSIFICATION_LABELS[classRaw] or classRaw

    -- Target HP percentage
    local hpMax = UnitHealthMax("target")
    local hpPct
    if hpMax and hpMax > 0 then
        hpPct = math.floor((UnitHealth("target") / hpMax) * 100)
    else
        hpPct = 0
    end

    -- Player coordinates and zone
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        PDPrint("Could not determine your current map. Are you in an unmapped area?")
        return
    end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        PDPrint("Could not retrieve your position on the current map.")
        return
    end

    local x = math.floor(pos.x * 10000) / 100  -- e.g. 0.4823 -> 48.23
    local y = math.floor(pos.y * 10000) / 100

    local mapInfo = C_Map.GetMapInfo(mapID)
    local zoneName = (mapInfo and mapInfo.name) or "Unknown Zone"

    -- Map pin: save existing waypoint, set ours, grab hyperlink, restore
    local previousWaypoint = C_Map.GetUserWaypoint()

    local waypointLocation = UiMapPoint.CreateFromCoordinates(mapID, pos.x, pos.y)
    C_Map.SetUserWaypoint(waypointLocation)
    local mapLink = C_Map.GetUserWaypointHyperlink()

    -- Restore the player's previous waypoint (or clear if they had none)
    if previousWaypoint then
        C_Map.SetUserWaypoint(previousWaypoint)
    else
        C_Map.ClearUserWaypoint()
    end

    -- Build the message
    -- Format: [Name] (Classification) | Zone | X, Y | HP: ##% | [Map Pin]
    local msg = string.format(
        "[%s] (%s) | %s | %.2f, %.2f | HP: %d%% | %s",
        targetName,
        classLabel,
        zoneName,
        x, y,
        hpPct,
        mapLink
    )

    -- Parse the channel argument
    input = strtrim(input or "")

    if input == "" then
        PDPrint("Usage: /pindrop <channel>")
        PDPrint("  Channel can be: say, yell, party, raid, guild, instance, or a number (e.g. 3)")
        return
    end

    local channelNum = tonumber(input)

    if channelNum then
        -- Numeric: send to a custom chat channel
        -- Verify the player is actually in that channel
        local channelName = GetChannelName(channelNum)
        if not channelName or channelName == "" then
            PDPrint("You are not in custom channel " .. channelNum .. ".")
            return
        end
        SendChatMessage(msg, "CHANNEL", nil, channelNum)
    else
        -- Named channel
        local chatType = NAMED_CHANNELS[input:lower()]
        if not chatType then
            PDPrint("Unknown channel: '" .. input .. "'.")
            PDPrint("Valid options: say, yell, party, raid, guild, instance, or a channel number.")
            return
        end
        -- Guard: party/raid/instance require group membership
        if chatType == "PARTY" and not IsInGroup() then
            PDPrint("You are not in a group.")
            return
        end
        if chatType == "RAID" and not IsInRaid() then
            PDPrint("You are not in a raid group.")
            return
        end
        if chatType == "INSTANCE_CHAT" and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            PDPrint("You are not in an instance group.")
            return
        end
        if chatType == "GUILD" and not IsInGuild() then
            PDPrint("You are not in a guild.")
            return
        end
        SendChatMessage(msg, chatType)
    end
end

-- Register the slash command
SLASH_PINDROP1 = "/pindrop"
SLASH_PINDROP2 = "/pd"         -- Convenient shorthand
SlashCmdList["PINDROP"] = BroadcastTargetInfo

-- Startup message
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    PDPrint("v" .. VERSION .. " loaded. Usage: /pindrop <channel> (or /pd)")
end)
