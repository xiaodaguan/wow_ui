------------------------------------------------------------------
-- Panel Helpers (Used to create interface panels)
------------------------------------------------------------------

local PanelHelperFunctions = {}

function PanelHelperFunctions:CreatePanelFrame(reference, title)
	local panelframe = CreateFrame( "Frame", reference, UIParent);
	panelframe.name = title
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title.." Options")
	return panelframe
end

function PanelHelperFunctions:CreateCheckButton(reference, parent, label)
	local checkbutton = CreateFrame( "CheckButton", reference, parent, "InterfaceOptionsCheckButtonTemplate" )
	_G[reference.."Text"]:SetText(label)
	return checkbutton
end

function PanelHelperFunctions:CreateRadioButtons(reference, parent, numberOfButtons, defaultButton, spacing, list)
	local index
	local radioButtonSet = {}

	for index = 1, numberOfButtons do
		radioButtonSet[index] = CreateFrame( "CheckButton", reference..index, parent, "UIRadioButtonTemplate" )
		radioButtonSet[index].Label = _G[reference..index.."Text"]
		radioButtonSet[index].Label:SetText(list[index] or " ")
		radioButtonSet[index].Label:SetWidth(250)
		radioButtonSet[index].Label:SetJustifyH("LEFT")

		if index > 1 then
			radioButtonSet[index]:SetPoint("TOP", radioButtonSet[index-1], "BOTTOM", 0, -(spacing or 10))
		end

		radioButtonSet[index]:SetScript("OnClick", function (self)
			local button
			for button = 1, numberOfButtons do radioButtonSet[button]:SetChecked(false) end
			self:SetChecked(true)
		end)
	end

	radioButtonSet.GetChecked = function()
		local index
		for index = 1, numberOfButtons do
			if radioButtonSet[index]:GetChecked() then return index end
		end
	end

	radioButtonSet.SetChecked = function(self, number)
		local index
		for index = 1, numberOfButtons do radioButtonSet[index]:SetChecked(false) end
		radioButtonSet[number]:SetChecked(true)
	end


	radioButtonSet[defaultButton]:SetChecked(true)
	return radioButtonSet
end

function PanelHelperFunctions:CreateSliderFrame(reference, parent)
	local slider = CreateFrame("Slider", reference, parent, 'OptionsSliderTemplate')
	slider:SetWidth(100)
	slider:SetHeight(15)
	--slider.tooltipText =
	slider.Label = _G[reference..'Text']
	slider.Low = _G[reference.."Low"]
	slider.High = _G[reference.."High"]
	slider:SetMinMaxValues(1, 10)
	slider:SetValueStep(1)
	slider:SetOrientation("HORIZONTAL")
	return slider
end

function PanelHelperFunctions:CreateDropdownFrame(reference, parent, menu, default)
	local dropdown = CreateFrame("Frame", reference, parent, "UIDropDownMenuTemplate" )
	local index, item
	dropdown.Label = _G[reference.."Text"]
	dropdown.Label:SetText(menu[default].text)
	dropdown.Value = default
	dropdown.initialize = function(self, level)
		if not level == 1 then return end
		for index, item in pairs(menu) do
			item.func = function(self) dropdown.Label:SetText(item.text); dropdown.Value = index  end
			UIDropDownMenu_AddButton(item, level)
		end end
	dropdown.SetValue = function (self, value) dropdown.Label:SetText(menu[value].text); dropdown.Value = value end
	return dropdown
end
-- <--------------------------------------------------------------------------------------------- *
-- <--------------------------------------------------------------------------------------------- *

local TidyThreatSkins = {
			"Interface\\Addons\\TidyThreat\\media\\Thermo",
			"Interface\\Addons\\TidyThreat\\media\\Pill",
			"Interface\\Addons\\TidyThreat\\media\\Block"}

function SetInteractive(frame, allow)
	frame:EnableMouse(allow)

	if allow then
		frame:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then self:StartMoving() else InterfaceOptionsFrame_OpenToCategory("Tidy Threat") end end)
		frame:SetScript("OnMouseUp", function(self, button) if button == "LeftButton" then self:StopMovingOrSizing()  end end)
	else
		frame:SetScript("OnMouseDown", nil)
		frame:SetScript("OnMouseUp", nil)
	end
end

local function ApplyOptions()
	local frame = TidyThreat
	frame.Border:SetTexture(TidyThreatSkins[TidyThreatOptions.Skin].."_Border")
	frame.Glow:SetTexture(TidyThreatSkins[TidyThreatOptions.Skin].."_Glow")
	SetInteractive(frame, TidyThreatOptions.AllowMove)
	if TidyThreatOptions.Visible then frame:Show() else frame:Hide() end
	frame:SetScale(TidyThreatOptions.Scale)
	frame:OnUpdate()
end
-- <--------------------------------------------------------------------------------------------- *
-- Main Panel
local panel = PanelHelperFunctions:CreatePanelFrame( "TidyThreatInterfaceOptions", "Tidy Threat" )

--  [[-- Skin
panel.SkinLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
panel.SkinLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, -40)
panel.SkinLabel:SetText("Graphical Skin:")
panel.SkinImage = panel:CreateTexture(nil, 'ARTWORK')
panel.SkinImage:SetTexture("Interface\\Addons\\TidyThreat\\media\\SkinSamples")
panel.SkinImage:SetWidth(256)
panel.SkinImage:SetHeight(128)
panel.SkinImage:SetPoint("TOPLEFT", panel.SkinLabel, -45, -25)
local SkinList = {" ", " ", " ",}
panel.Skin = PanelHelperFunctions:CreateRadioButtons("TidyThreatOptions_Skin", panel, 3, 1, 2, SkinList)
panel.Skin[1]:SetPoint("TOPLEFT", panel.SkinLabel, 26, -17)
panel.Skin[2]:SetPoint("TOPLEFT", panel.Skin[1], 52, 0)
panel.Skin[3]:SetPoint("TOPLEFT", panel.Skin[2], 50, 0)

--  [[-- Visibility
panel.VisibilityLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
panel.VisibilityLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, -190)
panel.VisibilityLabel:SetText("Visibility:")
local VisibilityChoices = {
				{ text = "Shown", notCheckable = 1 },
				{ text = "Hidden", notCheckable = 1 } ,
				{ text = "Combat Only", notCheckable = 1 } ,
			}


panel.Visibility = PanelHelperFunctions:CreateDropdownFrame("TidyThreatOptions_Vis", panel, VisibilityChoices, 1)
panel.Visibility:SetPoint("TOPLEFT", panel.VisibilityLabel, 0, -17)

-- [[-- Lock Position
panel.LockPosition = PanelHelperFunctions:CreateCheckButton("TidyThreatOptions_Lock", panel, "Lock Position")
panel.LockPosition:SetPoint("TOPLEFT", 35, -260)

-- [[-- Detail Window
panel.DetailWindow = PanelHelperFunctions:CreateCheckButton("TidyThreatOptions_Detail", panel, "Show Detail Window")
panel.DetailWindow:SetPoint("TOPLEFT", panel.LockPosition, "BOTTOMLEFT", 0, -3)

-- [[-- Audio Warning
panel.PlaySounds = PanelHelperFunctions:CreateCheckButton("TidyThreatOptions_Sound", panel, "Audible Threat Warning")
panel.PlaySounds:SetPoint("TOPLEFT", panel.DetailWindow, "BOTTOMLEFT", 0, -3)

--[[-- Scale
panel.Scale = PanelHelperFunctions:CreateSliderFrame("TidyThreatOptions_Scale", panel)
panel.Scale:SetPoint("TOPLEFT", panel.PlaySounds, "BOTTOMLEFT", 0, -6)
panel.Scale:SetMinMaxValues(.5, 1.5)
panel.Scale:SetValueStep(.25)
panel.Scale:SetValue(1)
panel.Scale:Enable()
--]]

-- Functions
local VisibilityFunctions = {
	function() TidyThreatOptions.Visible = true; TidyThreatOptions.HideOutOfCombat = false end,
	function() TidyThreatOptions.Visible = false; TidyThreatOptions.HideOutOfCombat = false end,
	function() TidyThreatOptions.Visible = false; TidyThreatOptions.HideOutOfCombat = true end,
}

function panel.okay()
	TidyThreatOptions.Skin = panel.Skin:GetChecked();
	VisibilityFunctions[panel.Visibility.Value]()

	TidyThreatOptions.PlayAlertSound = panel.PlaySounds:GetChecked();
	TidyThreatOptions.ShowDetailWindow = panel.DetailWindow:GetChecked();
	TidyThreatOptions.AllowMove = not panel.LockPosition:GetChecked();
	--TidyThreatOptions.Scale = panel.Scale:GetValue()
	ApplyOptions()
end

function panel.refresh()

	panel.Skin:SetChecked(TidyThreatOptions.Skin)

	if TidyThreatOptions.HideOutOfCombat then panel.Visibility:SetValue(3)
	elseif TidyThreatOptions.Visible then panel.Visibility:SetValue(1)
	else panel.Visibility:SetValue(2) end

	panel.PlaySounds:SetChecked(TidyThreatOptions.PlayAlertSound)
	panel.DetailWindow:SetChecked(TidyThreatOptions.ShowDetailWindow)
	panel.LockPosition:SetChecked(not TidyThreatOptions.AllowMove)
	--panel.Scale
end

-- Adds the panel to the interface window
InterfaceOptions_AddCategory(panel);

local function WatcherOnEvent(event)
	for key, value in pairs(TidyThreatDefaultOptions) do
		TidyThreatOptions[key] = TidyThreatOptions[key] or value

	end
	--self:SetPoint("LEFT", UIParent, "LEFT", 300, 300)
	ApplyOptions()
end

local TidyThreatWatcher = CreateFrame("Frame")
TidyThreatWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
TidyThreatWatcher:SetScript("OnEvent", WatcherOnEvent)


local interfacePanelFixed = false

local function OpenInterfacePanel(panel)
	if not interfacePanelFixed then

		local panelName = panel.name
		if not panelName then return end

		local t = {}

		for i, p in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
			if p.name == panelName then
				t.element = p
				InterfaceOptionsListButton_ToggleSubCategories(t)
			end
		end
		interfacePanelFixed = true
	end

	InterfaceOptionsFrame_OpenToCategory(panel)
end


function slash_TidyThreat(arg)
	OpenInterfacePanel(panel)
end
SLASH_TIDYTHREAT1 = '/tidythreat'
SLASH_TIDYTHREAT2 = '/ttt'
SlashCmdList['TIDYTHREAT'] = slash_TidyThreat;

