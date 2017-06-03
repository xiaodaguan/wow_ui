local _G = _G
local MB = MacroBox
local CreateFrame, UIParent = CreateFrame, UIParent
local L = MB.L
local AceGUI = MB.LS("AceGUI-3.0")

local function checkstate()
	local gm, cm = GetNumMacros()
	MacroBoxGeneralLabel:SetFormattedText(MB.MACRONUM, _G.GENERAL, gm, _G.MAX_ACCOUNT_MACROS)
	MacroBoxCharacterLabel:SetFormattedText(MB.MACRONUM, _G.CHARACTER, cm, _G.MAX_CHARACTER_MACROS)
	if gm < _G.MAX_ACCOUNT_MACROS and MacroBoxFrame.selectedMacro then MacroBoxGeneralAdd:Enable() else MacroBoxGeneralAdd:Disable() end
	if cm < _G.MAX_CHARACTER_MACROS and MacroBoxFrame.selectedMacro then MacroBoxCharacterAdd:Enable() else MacroBoxCharacterAdd:Disable() end
end
			
function MB:CreateMBFrame()
	local mbframe = CreateFrame("Frame", "MacroBoxFrame", UIParent, "BasicFrameTemplate")

	local function frameMouseUp()
		mbframe:StopMovingOrSizing()
		MB.db.profile.x = mbframe:GetLeft()
		MB.db.profile.y = mbframe:GetBottom()
	end

	mbframe:SetScale(MB.db.profile.scale)
	mbframe:SetSize(300, 450)
	mbframe:SetMovable(true)
	mbframe:EnableMouse(true)
	mbframe:SetPoint("BOTTOMLEFT", MB.db.profile.x, MB.db.profile.y)
	mbframe:SetScript("OnMouseDown", function() mbframe:StartMoving() end)
	mbframe:SetScript("OnMouseUp", frameMouseUp)
	mbframe.TitleText:SetText("Macro Toolkit - Macro Box")
	mbframe:Hide()

	local category = AceGUI:Create("Dropdown")
	local categories = {["general"] = _G.GENERAL, ["raid"] = _G.RAID, ["deathknight"] = L["Death Knight"], ["druid"] = L["Druid"],
		["hunter"] = L["Hunter"], ["mage"] = L["Mage"], ["monk"] = L["Monk"], ["paladin"] = L["Paladin"], ["priest"] = L["Priest"],
		["rogue"] = L["Rogue"], ["shaman"] = L["Shaman"], ["warrior"] = L["Warrior"], ["warlock"] = L["Warlock"], ["demonhunter"] = L["Demon Hunter"]}
	category.frame:SetParent(mbframe)
	category:SetList(categories)
	category:SetWidth(150)
	category:SetLabel(_G.CATEGORY)
	category:SetPoint("TOPLEFT", 10, -30)

	local macrolabel = mbframe:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	macrolabel:SetText(_G.MACROS)
	macrolabel:SetPoint("TOPLEFT", category.frame, "BOTTOMLEFT", 0, -5)
	
	local scrollbg = CreateFrame("Frame", "MacroBoxScrollBg", mbframe)
	scrollbg:SetSize(275, 150)
	scrollbg:SetPoint("TOPLEFT", macrolabel, "BOTTOMLEFT", 0, -5)
	scrollbg:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, tileSize = 16, tile = true, insets = {left = 5, right = 5, top = 5, bottom = 5}})
	scrollbg:SetBackdropBorderColor(_G.TOOLTIP_DEFAULT_COLOR.r, _G.TOOLTIP_DEFAULT_COLOR.g, _G.TOOLTIP_DEFAULT_COLOR.b)
	scrollbg:SetBackdropColor(_G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
	
	local macroscroll = CreateFrame("ScrollFrame", "MacroBoxMacroScrollFrame", mbframe, "UIPanelScrollFrameTemplate")
	macroscroll:SetSize(240, 140)
	macroscroll:SetPoint("TOPLEFT", scrollbg, "TOPLEFT", 8, -5)
	local macrolist = AceGUI:Create("SimpleGroup")
	macrolist:SetLayout("List")
	MB.macrolist = macrolist.frame
	macroscroll:SetScrollChild(macrolist.frame)

	local function updatemacrolist()
		macrolist:ReleaseChildren()
		local macroindex = 1
		for cat, macros in pairs(MB.Macros) do
			if cat == mbframe.filter then
				--table.sort(macros, function(a,b) return (a[2] or "") < (b[2] or "") end)
				table.sort(macros,
					function(a,b)
						local macronamea = (type(a[2] == "number")) and MB:gsi(a[2]) or a[2]
						local macronameb = (type(b[2] == "number")) and MB:gsi(b[2]) or b[2]
						return (macronamea or "") < (macronameb or "")
					end)
				for idx, m in ipairs(macros) do
					local l = AceGUI:Create("InteractiveLabel")
					local t = MB.textures[cat]
					local macroname = (type(m[2] == "number")) and MB:gsi(m[2]) or m[2]
					if macroname ~= "_removed_" then
						l:SetWidth(255)
						if strlenutf8(MB:DecodeMacro(m[1])) > 255 then l:SetText(format("%s*", macroname))
						else l:SetText(macroname) end
						l:SetHighlight(0.4,0.4,0.4,1)
						l:SetColor(0.7, 0.7, 0.4)
						l:SetImage(t[1], t[2], t[3], t[4], t[5])
						l:SetImageSize(16, 16)
						l:SetCallback("OnClick",
							function()
								mbframe.selectedMacro = idx
								MB:DecodeMacro(MB.Macros[mbframe.filter][idx][1])
								local decoded = MB:DecodeMacro(MB.Macros[mbframe.filter][idx][1])
								if MB.MT then decoded = MacroToolkit:ShortenMacro(decoded) end
								if strlenutf8(decoded) > 255 then
									if not IsAddOnLoaded("MacroToolkit") then
										MacroBoxGeneralAdd:Hide()
										MacroBoxCharacterAdd:Hide()
										MacroBoxRMT:Show()
									end
								else
									MacroBoxRMT:Hide()
									MacroBoxGeneralAdd:Show()
									MacroBoxCharacterAdd:Show()
								end
								if MacroToolkit then
									if MB.db.profile.shorten then decoded = MacroToolkit:ShortenMacro(decoded) end
									decoded = MacroToolkit:FormatMacro(decoded)
								end
								MacroBoxDesc:SetText(decoded)
								MacroBoxId:SetFormattedText("#%s", tostring(macroindex))
								checkstate()
							end)
						macrolist:AddChild(l)
						macroindex = macroindex + 1
					end
				end
			end
		end
	end
	
	category:SetCallback("OnValueChanged",
		function(info, name, key)
			mbframe.filter = key
			mbframe.selectedMacro = nil
			MacroBoxGeneralAdd:Disable()
			MacroBoxCharacterAdd:Disable()
			MacroBoxDesc:SetText("")
			MacroBoxId:SetText("")
			updatemacrolist()
		end)
	
	local desclabel = mbframe:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	desclabel:SetText(L["Macro commands"])
	desclabel:SetPoint("TOPLEFT", scrollbg, "BOTTOMLEFT", 0, -5)
	
	local mtlabel = mbframe:CreateFontString("MacroBoxRMT", "ARTWORK", "GameFontHighlightSmall")
	mtlabel:SetFormattedText("(%s)", L["Requires Macro Toolkit"])
	mtlabel:SetPoint("LEFT", desclabel, "RIGHT", 5, 0)
	mtlabel:Hide()

	local descbg = CreateFrame("Frame", "MacroBoxDescBg", mbframe)
	descbg:SetSize(275, 100)
	descbg:SetPoint("TOPLEFT", desclabel, "BOTTOMLEFT", 0, -5)
	descbg:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, tileSize = 16, tile = true, insets = {left = 5, right = 5, top = 5, bottom = 5}})
	descbg:SetBackdropBorderColor(_G.TOOLTIP_DEFAULT_COLOR.r, _G.TOOLTIP_DEFAULT_COLOR.g, _G.TOOLTIP_DEFAULT_COLOR.b)
	descbg:SetBackdropColor(_G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

	local idno = mbframe:CreateFontString("MacroBoxId", "BACKGROUND") --, "GameFontNormalSmall")
	idno:SetFont("Fonts\\FRIZQT__.TTF", 9)
	idno:SetTextColor(1, 1, 1, 0.6)
	idno:SetPoint("BOTTOMRIGHT", descbg, "TOPRIGHT", -5, 0)

	local descscroll = CreateFrame("ScrollFrame", "MacroBoxDescScrollFrame", mbframe, "UIPanelScrollFrameTemplate")
	descscroll:SetSize(240, 90)
	descscroll:SetPoint("TOPLEFT", descbg, "TOPLEFT", 8, -5)
	local descscrollchild = CreateFrame("EditBox", "MacroBoxDesc", desccroll)
	descscrollchild:SetMultiLine(true)
	descscrollchild:SetAutoFocus(false)
	descscrollchild:SetEnabled(false)
	descscrollchild:SetSize(239, 90)
	descscrollchild:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
	descscrollchild:SetScript("OnUpdate", function(this, elapsed) ScrollingEdit_OnUpdate(this, elapsed, this:GetParent()) end)
	descscrollchild:SetFontObject("GameFontHighlightSmall")
	descscroll:SetScrollChild(descscrollchild)

	local function addmacro(character)
		local macrocode = MB.Macros[mbframe.filter][mbframe.selectedMacro]
		local macrotext = MB:DecodeMacro(macrocode[1])
		local m
		if strlenutf8(macrotext) > 255 then
			if IsAddOnLoaded("MacroToolkit") then
				m = CreateMacro(MB:gsi(macrocode[2]), "INV_MISC_QUESTIONMARK", "MBOX", character)
				MacroToolkit:ExtendMacro(false, macrotext, m)
			end
		else
			if IsAddOnLoaded("MacroToolkit") then macrotext = MacroToolkit:ShortenMacro(macrotext) end
			m = CreateMacro(MB:gsi(macrocode[2]), "INV_MISC_QUESTIONMARK", macrotext, character)
		end
		if m then PlaySoundFile("Sound/Character/footsteps/mFootHugeDirtA.ogg")
		else PlaySoundFile("Sound/INTERFACE/igQuestFailed.ogg") end
		checkstate()
	end
	
	local generallabel = mbframe:CreateFontString("MacroBoxGeneralLabel", "ARTWORK", "GameFontHighlight")
	generallabel:SetPoint("TOPLEFT", descbg, "BOTTOMLEFT", 0, -5)
	
	local addgeneral = CreateFrame("Button", "MacroBoxGeneralAdd", mbframe, "UIPanelButtonTemplate")
	addgeneral:SetText(_G.ADD)
	addgeneral:SetSize(80, 22)
	addgeneral:SetPoint("TOPLEFT", descbg, "BOTTOMLEFT", 200, -3)
	addgeneral:SetScript("OnClick", function() addmacro(nil) end)
	
	local characterlabel = mbframe:CreateFontString("MacroBoxCharacterLabel", "ARTWORK", "GameFontHighlight")
	characterlabel:SetPoint("TOPLEFT", generallabel, "BOTTOMLEFT", 0, -15)
	
	local addcharacter = CreateFrame("Button", "MacroBoxCharacterAdd", mbframe, "UIPanelButtonTemplate")
	addcharacter:SetText(_G.ADD)
	addcharacter:SetSize(80, 22)
	addcharacter:SetPoint("TOPLEFT", descbg, "BOTTOMLEFT", 200, -28)
	addcharacter:SetScript("OnClick", function() addmacro(true) end)
	
	local macrobutton = CreateFrame("Button", "MacroBoxMacroButton", mbframe, "UIPanelButtonTemplate")
	macrobutton:SetSize(80, 22)
	local buttontext
	if MB.MT then
		local l = MB.LS("AceLocale-3.0"):GetLocale("MacroToolkit")
		buttontext = l["Toolkit"]
	else buttontext = _G.MACROS end
	macrobutton:SetText(buttontext)
	macrobutton:SetPoint("BOTTOMLEFT", 5, 5)
	macrobutton:SetScript("OnClick", 
		function()
			if MB.MT then MacroToolkitFrame:Show()
			else ShowUIPanel(MacroFrame) end
			mbframe:Hide()
		end)

	local optionsbutton = CreateFrame("Button", "MacroBoxOptions", mbframe, "UIPanelButtonTemplate")
	optionsbutton:SetSize(80, 22)
	optionsbutton:SetText(_G.MAIN_MENU)
	optionsbutton:SetPoint("LEFT", macrobutton, "RIGHT", 10, 0)
	optionsbutton:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(MB.mainPanel) InterfaceOptionsFrame_OpenToCategory(MB.mainPanel) end)

	local closebutton = CreateFrame("Button", "MacroBoxCloseButton", mbframe, "UIPanelButtonTemplate")
	closebutton:SetSize(80, 22)
	closebutton:SetText(_G.CLOSE)
	closebutton:SetPoint("BOTTOMRIGHT", -10, 5)
	closebutton:SetScript("OnClick", function() mbframe:Hide() end)

	mbframe:SetScript("OnShow",
		function()
			PlaySound("igCharacterInfoOpen")
			checkstate()
			updatemacrolist()
		end)

	mbframe:SetScript("OnHide", function() PlaySound("igCharacterInfoClose") end)
end
