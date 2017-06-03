local _G = _G
local unpack, string = unpack, string

function MacroBox:LoadElvSkin()
	local E, L, V, P, G, _ = unpack(ElvUI)
	local S = E:GetModule("Skins")

	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.macro ~= true then return end
	S:HandleCloseButton(MacroBoxFrame.CloseButton)
	S:HandleScrollBar(MacroBoxMacroScrollFrameScrollBar)
	S:HandleScrollBar(MacroBoxDescScrollFrameScrollBar)

	MacroBoxFrame:Width(295)

	local buttons = {
		"MacroBoxGeneralAdd", "MacroBoxCharacterAdd", "MacroBoxMacroButton", "MacroBoxCloseButton", "MacroBoxOptions",
	}

	if not MacroToolkit then table.insert(buttons, "MacroBoxOpen") end

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		S:HandleButton(_G[buttons[i]])
	end

	MacroBoxFrame:StripTextures()
	MacroBoxFrame:SetTemplate("Transparent")
	MacroBox.macrolist:StripTextures()
	MacroBoxScrollBg:StripTextures()
	MacroBoxScrollBg:SetTemplate("Default")
	MacroBoxDescBg:StripTextures()
	MacroBoxDescBg:SetTemplate("Default")
	
	MacroBoxGeneralAdd:ClearAllPoints()
	MacroBoxGeneralAdd:SetPoint("TOPLEFT", "MacroBoxDescBg", "BOTTOMLEFT", 195, -3)
	MacroBoxCharacterAdd:ClearAllPoints()
	MacroBoxCharacterAdd:SetPoint("TOPLEFT", "MacroBoxDescBg", "BOTTOMLEFT", 195, -28)
	S:RegisterSkin("MacroBox", LoadSkin)
end
