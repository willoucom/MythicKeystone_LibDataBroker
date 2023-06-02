local ADDON, Addon = ...

local f = CreateFrame("frame")
local lib = LibStub("LibMythicKeystone-1.0")
if not lib then return end
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject('LibMythicKeystone', {type='data source', label='MythicKeystone'})

Addon.Mykey = {}
Addon.AltKeys = {}

f:SetScript("OnUpdate", function(self, elap)
    Addon.Mykey = lib.getMyKeystone()
    Addon.AltKeys = lib.getAltsKeystone()
    Addon.GuildKeys = lib.getGuildKeystone()
    if Addon.Mykey["current_key"] > 0 then
        local keystoneMapName = Addon.Mykey["current_key"] and C_ChallengeMode.GetMapUIInfo(Addon.Mykey["current_key"]) or " "
        dataobj.text = Addon.Mykey["current_keylevel"] .. " ".. keystoneMapName
    else
        dataobj.text = ""
    end
end)


local function formatText(obj)
    local name = obj["name"] or ""
    name = string.sub(name, 1, 12) -- cut long name
    local color = "|cFFFFFFF"
    if obj["class"] ~= "" then
        color = C_ClassColor.GetClassColor(obj["class"]):GenerateHexColorMarkup()
        name = color..name.."|r"
    end
    
    local keylevel = obj["current_keylevel"]

    return string.format("%5s %s",keylevel, name)
end

local function tableGroupByKeyLevel(obj)
    local keys = {}
    for _, key in pairs(obj) do
        keys[key["current_key"]] = keys[key["current_key"]] or {}
        local tmp = {key["fullname"] , key["current_keylevel"]}
        tinsert(keys[key["current_key"]], tmp)
    end

    for keyid in pairs(keys) do
        local tmptable = keys[keyid]
        table.sort(tmptable, function(a, b) return a[2] > b[2] end)
    end
    return keys
end

-- In the data source addon...
function dataobj:OnTooltipShow()
    self:AddLine("Mythic Keystones")
    if Addon.AltKeys then
        self:AddLine(" ")
        self:AddLine("Alts")
        local keys = tableGroupByKeyLevel(Addon.AltKeys) or {}
        for keyid in pairs(keys) do
            local keystoneMapName = keyid and C_ChallengeMode.GetMapUIInfo(keyid) or " "
            self:AddLine("  " .. keystoneMapName)
            for char in pairs(keys[keyid]) do
                char = keys[keyid][char][1]
                self:AddLine("  ".. formatText(Addon.AltKeys[char]))
            end
        end
    end

    if Addon.GuildKeys then
        self:AddLine(" ")
        self:AddLine("Guild")
        local keys = tableGroupByKeyLevel(Addon.GuildKeys) or {}
        for keyid in pairs(keys) do
            local keystoneMapName = keyid and C_ChallengeMode.GetMapUIInfo(keyid) or " "
            self:AddLine("  " .. keystoneMapName)
            for char in pairs(keys[keyid]) do
                char = keys[keyid][char][1]
                self:AddLine("  ".. formatText(Addon.GuildKeys[char]))
            end
        end
    end


end
