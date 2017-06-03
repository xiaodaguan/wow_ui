local MB = MacroBox
local _G = _G
local L = MB.L
local select, string, tonumber, format = select, string, tonumber, format
local GetSpellInfo, GetItemInfo = GetSpellInfo, GetItemInfo

MB.defaults = {
	profile = {
		x = (UIParent:GetWidth() - 300) / 2,
		y = (UIParent:GetHeight() - 424) / 2,
		scale = UIParent:GetScale(),
		shorten = false,
		usemtscale = false,
	},
}

function MB:EventHandler(this, event, arg1, ...)
	if event == "ADDON_LOADED" then
		if arg1 == "MacroToolkit_MacroBox" then
			_G.SLASH_MACROBOX_CMD1 = format("%smb", MB.slash)
			_G.SLASH_MACROBOX_CMD2 = format("%smacrobox", MB.slash)
			_G.SLASH_MACROBOX_CMD3 = format("%smbox", MB.slash)
			_G.SLASH_MACROBOXENCODE_CMD1 = "/mbencode"
			SlashCmdList["MACROBOX_CMD"] = function() MacroBoxFrame:Show() end
			SlashCmdList["MACROBOXENCODE_CMD"] = function() MB:MakeEncoded() end
			MB.db = MB.LS("AceDB-3.0"):New("MacroBoxDB", MB.defaults, "profile")
			if MacroToolkit then MB.MT = true end
			if not IsAddOnLoaded("Blizzard_MacroUI") then LoadAddOn("Blizzard_MacroUI") end
		elseif arg1 == "Blizzard_MacroUI" and not MacroToolkit then
			local mtbutton = CreateFrame("Button", "MacroBoxOpen", MacroFrame, "UIPanelButtonTemplate")
			mtbutton:SetText("MacroBox")
			mtbutton:SetSize(94, 22)
			mtbutton:SetPoint("LEFT", MacroDeleteButton, "RIGHT")
			mtbutton:SetScript("OnClick",
				function()
					HideUIPanel(MacroFrame)
					MacroBoxFrame:Show()
				end)
		end
	elseif event == "PLAYER_LOGIN" then
		MB:GenerateMacros()
		MB:CreateMBFrame()
		MB:CreateOptions()
		if MB.lazymacros then MB:AddLazyMacros() end
		--local tm = 0
		--for c, m in pairs(MB.Macros) do tm = tm + #m end
		--print("total macros:", tm)
		if IsAddOnLoaded("ElvUI") then MB:LoadElvSkin() end
	end
end

function MB:DisplayMacros(category)
	print(category)
end

function MB:DecodeMacro(macro)
	local macrotext = macro
	local em
	macrotext = string.gsub(macrotext, "//999", "#showtooltip")
	macrotext = string.gsub(macrotext, "//998", "#show")
	for i = #MB.MacroCommands, 1, -1 do
		local scglobal = format("SLASH_%s1", MB.MacroCommands[i])
		local sc = _G[scglobal]
		if MB.MT then
			scglobal = string.sub(scglobal, 1, string.len(scglobal) - 1)
			sc = MacroToolkit:FindShortest(scglobal)
		end
		macrotext = string.gsub(macrotext, format("//%d+", i), sc)
	end
	--for i = #MB.MacroCommands, 1, -1 do macrotext = string.gsub(macrotext, format("//%d+", i), MB.MacroCommands[i]) end
	local s = select(3, string.find(macrotext, "(::%d+)"))
	while s do
		local sid = tonumber(string.sub(s, 3))
		if sid > 1000000 then
			sid = sid - 1000000
			em = true
		else em = false end
		local spell = GetSpellInfo(sid) or _G.UNKNOWN
		macrotext = string.gsub(macrotext, s, format(" %s%s", em and "!" or "", spell))
		s = select(3, string.find(macrotext, "(::%d+)"))
	end
	local i = select(3, string.find(macrotext, "($%d+)"))
	while i do
		local iid = tonumber(string.sub(i, 2))
		local item = GetItemInfo(iid) or _G.UNKNOWN
		macrotext = string.gsub(macrotext, i, format(" %s", item))
		i = select(3, string.find(macrotext, "($%d+)"))
	end
	local e = select(3, string.find(macrotext, "(*%d+)"))
	while e do
		local eid = tonumber(string.sub(e, 2))
		local emote = _G[format("EMOTE%d_CMD1", eid)]
		macrotext = string.gsub(macrotext, e, format("%s", emote))
		e = select(3, string.find(macrotext, "(*%d+)"))
	end
	macrotext = string.gsub(macrotext, "&", "\n")
	return macrotext
end

local function findEmote(emote)
	local upos, digits
	local token = format("%s%s", MB.slash, emote)
	for k, v in pairs(_G) do
		if type(v) == "string" then
			if string.sub(k, 1, 5) == "EMOTE" then
				if string.sub(v, 2) == emote then
					upos = string.find(k, "_")
					digits = tonumber(string.sub(k, 6, upos - 1))
					token = format("*%d", digits)
					break
				end
			end
		end
	end
	return token
end

local function findToken(command)
	local token
	local foundtoken = false
	if command == "showtooltip" then
		token = "//999"
		foundtoken = true
	elseif command == "show" then
		token = "//998"
		foundtoken = true
	else
		for i, c in ipairs(MB.MacroCommands) do
			local sc = string.sub(_G[format("SLASH_%s1", c)], 2)
			if sc == command then
				token = format("//%d", i)
				foundtoken = true
				break
			end
		end
	end
	if not foundtoken then token = findEmote(command) end
	return token
end

function MB:EncodeMacro(macro)
	local lines = {strsplit("\n", macro)}
	local macrotext = ""
	local spos, command
	for _, line in ipairs(lines) do
		spos = string.find(line, " ")
		if spos then
			command = string.sub(line, 2, spos - 1)
			macrotext = format("%s%s%s", (macrotext == "") and "" or format("%s&", macrotext), findToken(command), string.sub(line, spos))
		else
			command = string.sub(line, 2)
			macrotext = format("%s%s", (macrotext == "") and "" or format("%s&", macrotext), findToken(command))
		end
	end
	return macrotext
end

local function checkCategory(category)
	local checked = "general"
	local lcat = string.lower(category)
	local cats = {"general","raid","deathknight","druid","hunter","mage","monk","paladin","priest","rogue","shaman","warlock","warrior"}
	for _, c in ipairs(cats) do
		if lcat == c then
			checked = lcat
			break
		end
	end
	return checked
end

function MB:MakeEncoded()
	if not MB.toencode then
		print("Macro Box: Nothing found to encode! Aborting.")
		return
	end
	local LM = MacroBox_LazyMacros
	if not LM then
		print("Macro Box: Plugin not found! Aborting.")
		return
	end
	local count = 0
	local idx = 0
	local desc
	LM.encoded = {}
	for _, m in ipairs(MB.toencode) do
		if not m.index then idx = idx + 1 else idx = m.index end
		table.insert(LM.encoded, {desc = desc, category = checkCategory(m.category), index = idx, body = MB:EncodeMacro(m.body)})
		count = count + 1
	end
	print(format("Macro Box: %d macros encoded", count))
end

function MB:AddLazyMacros()
	for _, m in ipairs(MB.lazymacros) do
		local cat = checkCategory(m.category)
		table.insert(MB.Macros[cat], {m.body, m.desc, format("lm%d", m.index or 0)})
	end
end
