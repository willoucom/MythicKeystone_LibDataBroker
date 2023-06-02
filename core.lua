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
    if Addon.Mykey["current_key"] > 0 then
        local keystoneMapName = Addon.Mykey["current_key"] and C_ChallengeMode.GetMapUIInfo(Addon.Mykey["current_key"]) or " "
        dataobj.text = Addon.Mykey["current_keylevel"] .. " ".. keystoneMapName
    else
        dataobj.text = "..."
    end
end)
-- In the data source addon...
function dataobj:OnTooltipShow()
	self:AddLine("Alts")
    if Addon.AltKeys then
        for key in pairs(Addon.AltKeys) do
            local text = ""
            local name = Addon.AltKeys[key]["fullname"] or ""
            if string.find(name, "-") then
                name,_ = string.split("-", name)
            end
            name = string.sub(name, 1, 12) -- cut long name
            local padding = 12 - string.len(name) 
            local pad = string.rep(" ",padding)
            local color = "|cFFFFFFF"
            if Addon.AltKeys[key]["class"] then
                color = C_ClassColor.GetClassColor(Addon.AltKeys[key]["class"]):GenerateHexColorMarkup()
            end
            
            local keylevel = Addon.AltKeys[key]["current_keylevel"]
            
            local keystoneMapName = ""
            if Addon.AltKeys[key]["current_key"] then
                keystoneMapName = Addon.AltKeys[key]["current_key"] and C_ChallengeMode.GetMapUIInfo(Addon.AltKeys[key]["current_key"]) or " "
            end
            if string.len(keystoneMapName) > 25 then
                keystoneMapName = string.sub(keystoneMapName or "", 1, 25) .. "..."
            end
    
            text = string.format("%s %2s |r%s %s",color, name, keylevel, keystoneMapName)
            self:AddLine(text)
        end
    end

end
