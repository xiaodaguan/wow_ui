TidyThreatOptions = {}
TidyThreatDefaultOptions  = {
		Skin 				= 1,
		Scale				= 1,
		AllowMove			= true,
		Visible				= true,
		ThreatLeadScale 	= 68,
		ShowDetailWindow	= false,
		HideOutOfCombat = false,
		PlayAlertSound = false,
}

-- Artwork and Sound
local Statusbar_Texture = "Interface\\Addons\\TidyThreat\\media\\Flat"
local Frame_Texture = "Interface\\Addons\\TidyThreat\\media\\Thermo_Border"
local Glow_Texture = "Interface\\Addons\\TidyThreat\\media\\Thermo_Glow"
local Tip_Font = "FONTS\\FRIZQT__.TTF"
local Threat_Warning_Sound
if "Alliance" == UnitFactionGroup("player") then Threat_Warning_Sound = "Sound\\Interface\\PVPFlagTakenHordeMono.wav"
else Threat_Warning_Sound = "Sound\\Interface\\PVPFlagTakenMono.wav" end

-- Colors
local CLASS_HEX_COLOR = {
	DEATHKNIGHT = "C41F3B",
	DRUID = "FF7D0A",
	HUNTER = "ABD473",
	MAGE = "69CCF0",
	PALADIN = "F58CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF569",
	SHAMAN = "2459FF",
	WARLOCK = "9482C9",
	WARRIOR = "C79C6E",
	PET = "24FF24",
}

-- Suffix Lookup Table
local NUMBER_SUFFIX = {
	"st", "nd", "rd", "th", "th", "th", "th", "th", "th",
}

local function SetFrameSize(frame, width, height)
	frame:SetHeight(height)
	frame:SetWidth(width)
end

local function SetDefaultStatusBar(statusBar)
	statusBar:SetStatusBarTexture(Statusbar_Texture)
	statusBar:SetStatusBarColor(1, 0, 0)
	statusBar:SetMinMaxValues(0,100)
	statusBar:SetValue(100)
	statusBar:SetFrameStrata("LOW")
	statusBar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 16});
	statusBar:SetBackdropColor(0,0,0,0);
	statusBar:SetOrientation("VERTICAL")
end

local function GetUnitThreatPercent(unitId)
	local isTanking, aggroStatus, scaledPercent, rawPercent, rawValue = UnitDetailedThreatSituation(unitId, "target")
	if not scaledPercent then scaledPercent = 0 end
	return scaledPercent
end

local PlayerWarned = false

local function AlertSound(frame, threat)
	if threat > 80 then
		if not PlayerWarned then
			PlaySoundFile(Threat_Warning_Sound)
			PlayerWarned = true
		end
	else
		PlayerWarned = false
	end
end

local function valueToString(value)
	if value >= 1000000 then return format('%.1fm', value / 1000000)
	elseif value >= 1000 then return format('%.1fk', value / 1000)
	else return value end
end

local function GetUnitThreatValue(unitId)
		if unitId == nil then return 0 end
		local d1, d2, d3, d4, threat = UnitDetailedThreatSituation(unitId, "target")
		if not threat then threat = 0 end
		return threat
end

local function RankToText(rank)
	local text
	local r = mod(rank,10)

	if rank == 1 then return "|cFFFF3300Tanking|r|n"
	elseif rank == 2 then color = "|cFFFFDD00"
	else color = "|cFFAAFF00" end

	if r > 0 then
	   if rank > 10 and rank < 20 then text = "th"
	   else text = NUMBER_SUFFIX[r] end
	else
	   text = "th"
	end

	return color..rank..text.."|r|n"
end


local function GetGroupInfo()
	local groupType, groupCount

	if UnitInRaid("player") then groupType = "raid"
		groupCount = GetNumGroupMembers()
			-- Unitids for raid groups go from raid1..to..raid40.  No errors.
	elseif UnitInParty("player") then groupType = "party"
		groupCount = GetNumGroupMembers() - 1
			-- WHY?  Because the range for unitids are party1..to..party4.  GetNumGroupMembers() includes the Player, causing errors.
	else return end

	return groupType, groupCount
end

local function GetThreatProperties(target)
		local playerThreat = 0
		local playerRank = 1
		local partyHighUnit = nil
		local partyThreat = 0
		local unit = nil
		local unitThreat = 0
		local partyThreatVal, playerThreatVal
		local fadedThreat

		-- Check Player's Threat
		playerThreat = GetUnitThreatPercent("player")

		-- Group Threat
		if HasPetUI() then					-- Check Pet's Threat
				unit = "pet"
				unitThreat = GetUnitThreatPercent("pet")
				if unitThreat > partyThreat then
					partyThreat = unitThreat
					partyHighUnit = "pet"
					if unitThreat > playerThreat then playerRank = playerRank + 1 end
				end
		end

		local groupType, groupCount = GetGroupInfo()

		if groupType == "raid" then 		-- Check in Raid
			--local n = GetNumRaidMembers()

			for i = 1, groupCount do

				if not UnitIsUnit("raid"..i, "player") then
					unitThreat = GetUnitThreatPercent("raid"..i)
					if unitThreat > partyThreat then
						partyThreat = unitThreat
						partyHighUnit = "raid"..i
						if unitThreat > playerThreat then playerRank = playerRank + 1 end
					end

					unitThreat = GetUnitThreatPercent("raidpet"..i)
					if unitThreat > partyThreat then
						partyThreat = unitThreat
						partyHighUnit = "raidpet"..i
						if unitThreat > playerThreat then playerRank = playerRank + 1 end
					end

				end

			end 							-- Check in Party
		elseif groupType == "party" then
			for i = 1, groupCount-1 do
				unitThreat = GetUnitThreatPercent("party"..i)
				if unitThreat > partyThreat then
					partyThreat = unitThreat
					partyHighUnit = "party"..i
					if unitThreat > playerThreat then playerRank = playerRank + 1 end
				end

				unitThreat = GetUnitThreatPercent("partypet"..i)
				if unitThreat > partyThreat then
					partyThreat = unitThreat
					partyHighUnit = "partypet"..i
					if unitThreat > playerThreat then playerRank = playerRank + 1 end
				end
			end
		end

		if partyHighUnit then
			playerThreatVal = GetUnitThreatValue("player")
			partyThreatVal = GetUnitThreatValue(partyHighUnit)

			-- Correct for Spell: Fade
			if playerThreatVal < 0 then
				-- Corrected Val
				playerThreatVal = playerThreatVal + 410065408
				-- Player Faded Threat
				fadedThreat = (playerThreatVal / partyThreatVal)*100
				if fadedThreat > 130 then
					partyThreat = fadedThreat - 130
					playerThreat = 100
				else
					partyThreat = 0
					playerThreat = fadedThreat
				end
			end
		end

		return playerThreat, playerThreatVal, playerRank, partyThreat, partyThreatVal, partyHighUnit
end

--------------------------------------------  Member Functions  --------------------------------------------

local function SetThreatBars(self, player, counter)
	if not counter then counter = 0 end
	if not player then player = 0 end
	if player < 100 then counter = 0
		self.Glow:Hide()
	else counter = player - counter
		self.Glow:Show() end

	if player > 80 then self.PlayerThreat:SetStatusBarColor(1, .36, 0)
	elseif player > 60 then self.PlayerThreat:SetStatusBarColor(1, .61, 0)
	else self.PlayerThreat:SetStatusBarColor(.85, 1, 0) end

	self.PlayerThreat:SetValue(player)
	self.CounterThreat:SetValue(counter)
end

local function SetThreatPopup(self, unitId, rank, playerThreat, groupThreat)

	local groupName = UnitName(unitId)
	local threatDifference = (playerThreat - groupThreat)/100
	local _, groupClass = UnitClass(unitId);

	local threatMessage = ""
	local hexColor = CLASS_HEX_COLOR[groupClass]
	if not hexColor then hexColor = "888888" end

	if playerThreat > 0 then
		if threatDifference > 0 then threatMessage = "|cFFFF3300+"..valueToString(threatDifference).."|r above |cFF"..hexColor..groupName
		elseif threatDifference < 0 then threatMessage = "|cFF33FF00"..valueToString(threatDifference).."|r below |cFF"..hexColor..groupName
		else threatMessage = "Your threat is equal to, |cFF"..hexColor.."0"..groupName.."'s" end
		rankMessage = RankToText(rank)
		threatMessage = rankMessage..threatMessage
	else
		threatMessage = nil
	end

	self:SetDetailText(threatMessage)
end

local function SetDetailText(self, message)
	if message and TidyThreatOptions.ShowDetailWindow then
		self.DetailWindow:Show()
		self.DetailWindow.Text:SetText(message)
		self.DetailWindow.Text:SetWidth(self.DetailWindow.Text:GetStringWidth())
		self.DetailWindow.Text:SetHeight(self.DetailWindow.Text:GetStringHeight())
	else
		self.DetailWindow:Hide()
	end
end

local function SetVisible(self, visible)
	if visible then
		self:Show()
	else
		self:Hide()
	end
end

local function OnUpdate(self, event)

	--print(event, UnitThreatPercentageOfLead("player", "target"), UnitDetailedThreatSituation("player", "target"))
	local frame = TidyThreat

	if event == "PLAYER_TARGET_CHANGED" then PlayerWarned = false end

	if UnitAffectingCombat("player") then
		if not frame:IsShown() then frame:Show() end

		local playerThreat, playerThreatVal, playerRank, partyThreat, partyThreatVal, partyHighUnit = GetThreatProperties("target")

		--print(event, playerThreat)

		-- For groups
		if partyHighUnit then
			frame:SetAlpha(1)
			frame:Show()
			frame:SetThreatBars(playerThreat, partyThreat)
			if TidyThreatOptions.PlayAlertSound then frame:AlertSound(playerThreat) end
			frame:SetThreatPopup(partyHighUnit, playerRank, playerThreatVal, partyThreatVal)

		-- For Soloing/NPC Tank
		elseif playerThreat > 0 then
			frame:SetAlpha(1)
			frame:Show()
			local tankThreat = 0
			if not UnitIsUnit("player", "targettarget") then tankThreat = GetUnitThreatPercent("targettarget") - playerThreat end
			frame:SetThreatBars(playerThreat, tankThreat)
			if TidyThreatOptions.PlayAlertSound then frame:AlertSound(playerThreat) end

		-- No Threat Data to Display
		else
			frame:SetThreatBars(0, 0)
			frame.DetailWindow:Hide()
		end

	else
		if TidyThreatOptions.HideOutOfCombat then frame:Hide() end
		frame:SetThreatBars(0, 0)
		frame.DetailWindow:Hide()
	end
end

local function CreateTidyThreatFrame()
	local self = CreateFrame("Frame", "TidyThreat", UIParent)
	--local self = CreateFrame("Button", "TidyThreat", UIParent)
	self:SetWidth(35)
	self:SetHeight(88)

	self:SetPoint("CENTER")
	self:SetClampedToScreen(true)
	self:SetMovable(true)
	self:SetUserPlaced(true)
	self:EnableMouse(true)

	self.PlayerThreat = CreateFrame("StatusBar", nil, self)
	self.CounterThreat = CreateFrame("StatusBar", nil, self)
	self.DetailWindow = CreateFrame("Frame",nil,self)
	self.DetailWindow.Text = self.DetailWindow:CreateFontString(nil, "ARTWORK")
	self.Border = self:CreateTexture(nil, "OVERLAY")
	self.Glow = self:CreateTexture(nil, "OVERLAY")

	-- Set the initial properties of the Player Threat Bar
	SetFrameSize(self.PlayerThreat, 20, 53)
	SetDefaultStatusBar(self.PlayerThreat)
	self.PlayerThreat:SetPoint("BOTTOM", self, "BOTTOM", 0, 8)
	self.PlayerThreat:SetMinMaxValues(0,100)
	--self.PlayerThreat:SetBackdropColor(0,0,0,0);

	-- Set the initial properties of the Threat Lead Extension Bar
	SetFrameSize(self.CounterThreat, 20, 18)
	SetDefaultStatusBar(self.CounterThreat)
	self.CounterThreat:SetPoint("BOTTOM", self.PlayerThreat, "TOP" )
	self.CounterThreat:SetMinMaxValues(0, 68)
	--self.CounterThreat:SetBackdropColor(0,0,0,0);

	-- Set the initial properties of the Overlay
	SetFrameSize(self.Border, 64, 128)
	self.Border:SetTexture(Frame_Texture)
	self.Border:SetPoint("CENTER", 0, 3)

	-- Set the initial properties of the Threat Glow
	self.Glow:SetAllPoints(self.Border)
	self.Glow:SetTexture(Glow_Texture)
	self.Glow:SetVertexColor(1, 0, 0);
	self.Glow:Hide()

	-- Set the initial properties of the Detail popup
	self.DetailWindow:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                                            tile = true, tileSize = 16, edgeSize = 16,
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	self.DetailWindow:SetBackdropColor(0,0,0,.75);
	self.DetailWindow:SetPoint("LEFT", self.DetailWindow.Text, "LEFT", -8, 0)
	self.DetailWindow:SetPoint("RIGHT", self.DetailWindow.Text, "RIGHT", 8, 0)
	self.DetailWindow:SetPoint("TOP", self.DetailWindow.Text, "TOP", 0, 7)
	self.DetailWindow:SetPoint("BOTTOM", self.DetailWindow.Text, "BOTTOM", 0, -8)

	self.DetailWindow:SetPoint("CENTER", self.DetailWindow.Text, "CENTER")
	self.DetailWindow.Text:SetFont(Tip_Font, 10)
	self.DetailWindow.Text:SetPoint("TOP", self, "BOTTOM", 0, -15)
	self.DetailWindow.Text:SetJustifyH("CENTER")
	self.DetailWindow.Text:SetJustifyV("CENTER")
	self.DetailWindow.Text:SetText("")
	--self:SetDetailText(nil)

	self.AlertSound = AlertSound
	self.SetVisible = SetVisible
	self.SetDetailText = SetDetailText
	self.SetThreatPopup = SetThreatPopup
	self.SetThreatBars = SetThreatBars
	self.OnUpdate = OnUpdate

	return self
end

TidyThreat = CreateTidyThreatFrame()

TidyThreatEventHandler = CreateFrame("Frame", "TidyThreatEventHandler")
TidyThreatEventHandler:SetScript("OnEvent", OnUpdate)
TidyThreatEventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
TidyThreatEventHandler:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
TidyThreatEventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
TidyThreatEventHandler:RegisterEvent("UNIT_ATTACK")
TidyThreatEventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")

