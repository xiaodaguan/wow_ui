
-- Locale
local L_CRIT = " ".. _G["CRIT_ABBR"]
local L_SPEED = " ".. _G["SPEED"]
local L_AP = " ".. _G["ATTACK_POWER_TOOLTIP"]
local L_HASTE = " ".. _G["STAT_HASTE"]

-- Create Objects
local MS = CreateFrame("Frame", "StatBlock_MeleeStats")
local LDB = LibStub("LibDataBroker-1.1")
MS.AP = LDB:NewDataObject("Melee_AP", {type = "data source", text = "0"..L_AP, value = "0", suffix = L_AP})
MS.Crit = LDB:NewDataObject("Melee_Crit", {type = "data source", text = "0%"..L_CRIT, value = "0%", suffix = L_CRIT})
MS.Speed = LDB:NewDataObject("Melee_Speed", {type = "data source", text = "0.00"..L_SPEED, value = "0.00", suffix = L_SPEED})
MS.Haste = LDB:NewDataObject("Melee_Haste", {type = "data source", text = "0%"..L_HASTE, value = "0%", suffix = L_HASTE})

-- Upvalues
local format = string.format
local UnitAttackSpeed = UnitAttackSpeed
local UnitAttackPower = UnitAttackPower
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetMeleeHaste = GetMeleeHaste
local two_fp = "%.2f%%"

-- Events
MS:RegisterEvent("UNIT_MODEL_CHANGED")
MS:RegisterEvent("PLAYER_LEVEL_UP")
MS:RegisterEvent("UNIT_AURA")
MS:RegisterEvent("PLAYER_LOGIN")

-- Calculations
MS:SetScript("OnEvent", function(self, _, unit)
	if unit and unit ~= "player" then return end

	local base, pos, neg = UnitAttackPower"player"
	local ap = format("%d", base + pos + neg)
	self.AP.text = ap..L_AP
	self.AP.value = ap

	local crit = format(two_fp, GetCritChance())
	self.Crit.text = crit..L_CRIT
	self.Crit.value = crit

	local haste = format(two_fp, GetMeleeHaste())
	self.Haste.text = haste..L_HASTE
	self.Haste.value = haste

	local mh, oh = UnitAttackSpeed"player"
	local speed
	if oh then
		speed = format("%.2f/%.2f", mh, oh)
	else
		speed = format("%.2f", mh)
	end
	self.Speed.text = speed..L_SPEED
	self.Speed.value = speed
end)

