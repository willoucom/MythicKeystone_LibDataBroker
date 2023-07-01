local myname, Addon = ...

local lib = LibStub("LibMythicKeystone-1.0")
if not lib then return end

local L = LibStub("AceLocale-3.0"):GetLocale(myname)

Addon.Mykey = {}
Addon.AltKeys = {}

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject('LibMythicKeystone', {
    type = 'data source',
    label = 'MythicKeystone',
    text = "",
    icon = "Interface\\Icons\\Inv_relics_hourglass",
    OnClick = function()
        if PVEFrame:IsShown() then
            HideUIPanel(PVEFrame)
        else
            PVEFrame_ShowFrame()
        end
    end,
    
})

AddonCompartmentFrame:RegisterAddon({
    text = 'MythicKeystone',
    icon = "Interface\\Icons\\Inv_relics_hourglass",
    registerForAnyClick = true,
    notCheckable = true,
    func = function(btn)
        if PVEFrame:IsShown() then
            HideUIPanel(PVEFrame)
        else
            PVEFrame_ShowFrame()
        end
    end,
    funcOnEnter = function()
        GameTooltip:SetOwner(AddonCompartmentFrame, "ANCHOR_TOPRIGHT", -100 )
        GameTooltip:ClearLines()
        dataobj.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    end,
})

local f = CreateFrame("frame")
f:SetScript("OnUpdate", function(self, elap)
    Addon.Mykey = lib.getMyKeystone()
    if Addon.Mykey["current_key"] > 0 then
        local keystoneMapName = Addon.Mykey["current_key"] and C_ChallengeMode.GetMapUIInfo(Addon.Mykey["current_key"]) or
            " "
        dataobj.text = Addon.Mykey["current_keylevel"] .. " " .. keystoneMapName
    else
        dataobj.text = ""
    end
end)

local function formatText(obj, type)
    local name = obj["name"] or ""
    name = string.sub(name, 1, 14) -- cut long name
    local weeklybest = obj["weeklybest"] or ""
    local weeklycount = obj["weeklycount"] or ""
    if type == "alts" then
        if weeklybest ~= "" and weeklybest > 0 then
            weeklybest = "|cFFFFFFFFWeek: Runs("..weeklycount..") Best("..  weeklybest ..")|r"
        else
            weeklybest = "|cFFFF0000No Weekly Best|r"
        end
    else
        weeklybest = ""
    end

    local color = "|cFFFFFFFF"
    if obj["class"] ~= "" then
        color = C_ClassColor.GetClassColor(obj["class"]):GenerateHexColorMarkup()
        name = color .. name .. "|r"
    end

    local keylevel = obj["current_keylevel"]
    if keylevel < 10 then
        keylevel = "     " .. keylevel
    else
        keylevel = "   " .. keylevel
    end

    return string.format("%s %s", keylevel, name) , string.format("%s", weeklybest)
end

local function tableGroupByKeyLevel(obj)
    local keys = {}
    for _, key in pairs(obj) do
        keys[key["current_key"]] = keys[key["current_key"]] or {}
        local tmp = { key["fullname"], key["current_keylevel"] }
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
    Addon.AltKeys = lib.getAltsKeystone()
    Addon.GuildKeys = lib.getGuildKeystone()
    self:AddLine(L["AddonName"])
    if Addon.AltKeys then
        self:AddLine(" ")
        self:AddLine(L["Alts"])
        local keys = tableGroupByKeyLevel(Addon.AltKeys) or {}
        for keyid in pairs(keys) do
            local keystoneMapName = keyid and C_ChallengeMode.GetMapUIInfo(keyid) or " "
            self:AddLine("  " .. keystoneMapName)
            for char in pairs(keys[keyid]) do
                char = keys[keyid][char][1]
                self:AddDoubleLine(formatText(Addon.AltKeys[char], "alts"))
            end
        end
    end

    if Addon.GuildKeys then
        self:AddLine(" ")
        self:AddLine(L["Guild"])
        local keys = tableGroupByKeyLevel(Addon.GuildKeys) or {}
        for keyid in pairs(keys) do
            local keystoneMapName = keyid and C_ChallengeMode.GetMapUIInfo(keyid) or " "
            self:AddLine("  " .. keystoneMapName)
            for char in pairs(keys[keyid]) do
                char = keys[keyid][char][1]
                self:AddLine("  " .. formatText(Addon.GuildKeys[char], "guild"))
            end
        end
    end
end
