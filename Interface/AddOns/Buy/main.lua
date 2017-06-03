--[[
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

-- utility functions
local tonumber, select, strsplit, floor, lower, sub =
	tonumber, select, strsplit, math.floor, string.lower, string.sub
local function trim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

-- WoW API
local BuyMerchantItem, GetMerchantNumItems, GetMerchantItemInfo, GetMerchantItemMaxStack =
	BuyMerchantItem, GetMerchantNumItems, GetMerchantItemInfo, GetMerchantItemMaxStack

-- register slash command
SLASH_BUY1 = '/buy'
function SlashCmdList.BUY(msg, editbox)
	-- quick cancel is purchase in progress
	if buyIndex then
		cancel_buy()
		return
	end
	
	-- parse arguments
	local name, amount, too_many = strsplit(",", msg, 3)
	if too_many ~= nil then
		print("bad usage for /buy: too many arguments")
		print("example usage: /buy Starlight Rose")
		print("example usage: /buy Starlight Rose, 5")
		return
	end
	
	-- validate arguments
	name = trim(name)
	if name == "" then
		print("bad usage for /buy: need an item name")
		return
	end
	amount = tonumber(amount or 1)
	if amount == nil or amount <= 0 or amount ~= floor(amount) then
		print("bad usage for /buy: bad buy amount")
		print("please provide a positive integer or omit the amount to buy one")
		return
	end
	
	-- check if vendor is available
	local n = GetMerchantNumItems()
	if n == 0 then
		print("bad usage for /buy: must be at a vendor")
		return
	end
	
	-- find item(s)
	local search = lower(name)
	local index = 0
	for i = 1, n do
		-- if itemName is a case-insensitive, prefix-match
		if lower(sub(GetMerchantItemInfo(i), 1, #search)) == search then
			if index == 0 then
				-- first match, remember it
				index = i
			else
				-- multiple matches, quick abort
				index = -1
				break
			end
		end
	end
	
	if index >= 1 then
		local stackSize, maxStack, buyAmount
		maxStack = GetMerchantItemMaxStack(index)
		if GetMerchantItemCostInfo(index) > 0 then
			-- uses alternate currency; buy per stack
			stackSize = select(4, GetMerchantItemInfo(index))
			maxStack = maxStack - (maxStack % stackSize)
			amount = amount * stackSize
			amount = amount - (amount % stackSize)
			while amount > 0 do
				buyAmount = min(amount, maxStack)
				BuyMerchantItem(index, buyAmount)
				amount = amount - buyAmount
			end
		else
			while amount > 0 do
				buyAmount = min(amount, maxStack)
				BuyMerchantItem(index, buyAmount)
				amount = amount - buyAmount
			end
		end
	elseif index == 0 then
		print("error with /buy: item " .. name .. " not found")
	elseif index == -1 then
		print("error with /buy: multiple matches for " .. name)
	end
end
