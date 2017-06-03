
local Money = CreateFrame("Frame", "StatBlock_Money")
Money.obj = LibStub("LibDataBroker-1.1"):NewDataObject("Money", {type = "data source", text = "0"})

local L_GOLD = GOLD_AMOUNT_SYMBOL
local L_SILVER = SILVER_AMOUNT_SYMBOL
local L_COPPER = COPPER_AMOUNT_SYMBOL

Money:SetScript("OnEvent", function(self)
	local current = GetMoney()
	local gold = floor(current / 10000)
	local silver = floor((current - (gold * 10000)) / 100)
	local copper = mod(current, 100)

	self.obj.text = format("%i|cffffd700%s|r %i|cffc7c7cf%s|r %i|cffeda55f%s|r", gold, L_GOLD, silver, L_SILVER, copper, L_COPPER)
end)

Money:RegisterEvent("PLAYER_MONEY")
Money:RegisterEvent("PLAYER_TRADE_MONEY")
Money:RegisterEvent("TRADE_MONEY_CHANGED")
Money:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
Money:RegisterEvent("SEND_MAIL_COD_CHANGED")
Money:RegisterEvent("PLAYER_LOGIN")

