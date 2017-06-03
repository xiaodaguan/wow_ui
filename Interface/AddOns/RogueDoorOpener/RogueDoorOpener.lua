local gossipEventFrame = CreateFrame("frame") -- event listener for npc interaction events
gossipEventFrame:RegisterEvent("GOSSIP_SHOW")

local function GetCurrentNPC_ID()
	local guid = UnitGUID("npc")
	if not guid then return nil end
	return tonumber(string.match(guid, "Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)"))
end

local function handle_NPC_Interaction(self, event)
	if IsControlKeyDown() then return end
	local class, classFileName = UnitClass("player")
	if classFileName ~= "ROGUE" then return end
	if GetNumGossipOptions() ~= 2 then return end
	local text, gossipType = GetGossipOptions()
	if gossipType ~= "gossip" then return end
	
	local NPC_ID = GetCurrentNPC_ID()
	if NPC_ID == 97004 or NPC_ID == 96782 or NPC_ID == 93188 then
		if IsShiftKeyDown() then SelectGossipOption(2) else SelectGossipOption(1) end
	end
end
gossipEventFrame:SetScript("OnEvent", handle_NPC_Interaction)

SLASH_ROGUEDOOROPENER1, SLASH_ROGUEDOOROPENER2 = "/roguedoor", "/rdo"
SlashCmdList["ROGUEDOOROPENER"] = function(msg)
	print("RogueDoorOpener: Hold Shift to use the NPC as a vendor.")
	print("RogueDoorOpener: Hold Control to see all options.")
end