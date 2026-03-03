-- PinDrop.lua
-- Broadcasts target info to a chat channel of your choice.
-- Usage: /pindrop <channel>  or  /pd <channel>
--   <channel> can be a number (custom channel), or: say, yell, party, raid, guild, instance

local ADDON_NAME = "PinDrop"
local VERSION    = "1.0.0"

local NAMED_CHANNELS = {
    ["say"]      = "SAY",
    ["yell"]     = "YELL",
    ["party"]    = "PARTY",
    ["raid"]     = "RAID",
    ["guild"]    = "GUILD",
    ["instance"] = "INSTANCE_CHAT",
}

local function PDPrint(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[PinDrop]|r " .. msg)
end

local function BroadcastTargetInfo(input)
    if not UnitExists("target") then
        PDPrint("No target selected.")
        return
    end
    if UnitIsPlayer("target") then
        PDPrint("Target is a player.")
        return
    end

    input = strtrim(input or "")
    if input == "" then
        PDPrint("Usage: /pindrop <channel>")
        return
    end

    local channelNum = tonumber(input)
    local chatType

    if channelNum then
        chatType = "CHANNEL"
    else
        chatType = NAMED_CHANNELS[input:lower()]
        if not chatType then
            PDPrint("Unknown channel: '" .. input .. "'.")
            return
        end
    end

    local msg = "TestTarget (Elite) | The Maw | 43.63, 41.54"

    if channelNum then
        C_ChatInfo.SendChatMessage(msg, "CHANNEL", nil, channelNum)
    else
        C_ChatInfo.SendChatMessage(msg, chatType)
    end
end

SLASH_PINDROP1 = "/pindrop"
SLASH_PINDROP2 = "/pd"
SlashCmdList["PINDROP"] = BroadcastTargetInfo

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    PDPrint("v" .. VERSION .. " loaded. Usage: /pindrop <channel> (or /pd)")
end)