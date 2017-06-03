
local L_XP, L_RESTED, L_LEVEL_UP = XP, TUTORIAL_TITLE26, PLAYER_LEVEL_UP
local XP = CreateFrame("Frame", "StatBlock_XP")
XP.obj = LibStub("LibDataBroker-1.1"):NewDataObject("XP", {type = "data source", text = "0%", icon = "Interface\\Icons\\achievement_bg_winbyten"})

function XP.obj.OnTooltipShow(tooltip)
	if not tooltip or not tooltip.AddLine or not tooltip.AddDoubleLine then return end

	local rested = GetXPExhaustion() or 0
	local xp = UnitXP"player"
	local max = UnitXPMax"player"
	local remaining = max - xp
	tooltip:AddDoubleLine(L_LEVEL_UP, remaining, 0, 1, 1, 0, 1, 0)
	tooltip:AddDoubleLine(" ", " ", 0, 1, 1, 0, 1, 0)
	tooltip:AddDoubleLine(L_RESTED, rested, 0, 1, 1, 0, 1, 0)
	tooltip:AddDoubleLine(L_XP, ("%d/%d"):format(xp, max), 0, 1, 1, 0, 1, 0)
end

XP:SetScript("OnEvent", function(self, _, unit)
	if (unit and unit == "player") or not unit then
		local xp = UnitXP"player" / UnitXPMax"player" * 100
		self.obj.text = ("%.0f%%"):format(xp)
	end
end)
XP:RegisterEvent("PLAYER_XP_UPDATE")
XP:RegisterEvent("PLAYER_LEVEL_UP")
XP:RegisterEvent("PLAYER_LOGIN")

