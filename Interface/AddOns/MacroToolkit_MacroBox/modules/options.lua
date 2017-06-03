local _G = _G
local MB = MacroBox
local AceConfig = MB.LS("AceConfig-3.0")
local AceConfigDialog = MB.LS("AceConfigDialog-3.0")
local AceDBOptions = MB.LS("AceDBOptions-3.0")
local L = MB.L

--First visible frame
local function createMainPanel()
	local frame = CreateFrame("Frame", "MacroBoxOptionsMain")
	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	local version = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	local author = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetFormattedText("|T%s:%d|t %s", "Interface\\MacroFrame\\MacroFrame-Icon", 16, "Macro Toolkit - Macro Box")
	title:SetPoint("CENTER", frame, "CENTER", 0, 170)
	version:SetText(format("%s %s", _G.GAME_VERSION_LABEL, GetAddOnMetadata("MacroToolkit_MacroBox", "Version")))
	version:SetPoint("CENTER", frame, "CENTER", 0, 130)
	author:SetText(format("%s: Deepac", L["Author"]))
	author:SetPoint("CENTER", frame, "CENTER", 0, 100)
	return frame
end

local checkPanel = {
	order = 1,
	type = "group",
	name = _G.MAIN_MENU,
	args = {
		shorten = {
			order = 1,
			type = "toggle",
			name = L["Shorten macros"],
			width = "full",
			hidden = function() return MacroToolkit == nil end,
			get = function() return MB.db.profile.shorten end,
			set = function(info, value) MB.db.profile.shorten = value end,
		},
		mtscale = {
			order = 2,
			type = "toggle",
			name = L["Use Macro Toolkit's scale setting"],
			width = "full",
			hidden = function() return MacroToolkit == nil end,
			get = function() return MB.db.profile.usemtscale end,
			set =
				function(info, value)
					MB.db.profile.usemtscale = value
					if value then MB.db.profile.scale = MacroToolkit.db.profile.scale
					else MB.db.profile.scale = MB.defaults.profile.scale end
					MacroBoxFrame:SetScale(MB.db.profile.scale)
					MacroBoxFrame:SetSize((ElvUI and 295 or 300), 450)
				end,
		},
		scale = {
			order = 3,
			type = "range",
			name = _G.UI_SCALE,
			min = 0.25,
			max = 1.5,
			isPercent = true,
			step = 0.01,
			width = "double",
			disabled = function() return MB.db.profile.usemtscale end,
			get = function() return MB.db.profile.scale end,
			set = 
				function(info, value)
					MB.db.profile.scale = value
					MacroBoxFrame:SetScale(value)
					MacroBoxFrame:SetSize((ElvUI and 295 or 300), 450)
				end,
		},
	},
}

--Setup options
function MB:CreateOptions()
	MB.mainPanel = createMainPanel()
	MB.mainPanel.name = "Macro Box"
	InterfaceOptions_AddCategory(MB.mainPanel)
	AceConfig:RegisterOptionsTable("MacroBoxOptionsCheck", checkPanel)
	AceConfig:RegisterOptionsTable("MacroBoxOptionsProfiles", AceDBOptions:GetOptionsTable(MB.db))
	MB.OptionsFrame = AceConfigDialog:AddToBlizOptions("MacroBoxOptionsCheck", _G.MAIN_MENU, "Macro Box")
	AceConfigDialog:AddToBlizOptions("MacroBoxOptionsProfiles", L["Profiles"], "Macro Box")
end
