--[[ 
AdiBags - Tackle Box v1.0.2 [5.25.2017]
Adds filters and groupings for the Fishing profession to AdiBags.
]]--

local addonName, addon = ...

local L = setmetatable({}, {
	__index = function(self, key)
		if key then
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

local locale = GetLocale()

--- CURRENTLY LOOKING FOR TRANSLATION CONTRIBUTORS ---
------------------------ frFR ------------------------
if locale == "frFR" then


------------------------ deDE ------------------------
elseif locale == "deDE" then


------------------------ esMX ------------------------
elseif locale == "esMX" then


------------------------ ruRU ------------------------
elseif locale == "ruRU" then


------------------------ esES ------------------------
elseif locale == "esES" then


------------------------ zhTW ------------------------
elseif locale == "zhTW" then


------------------------ zhCN ------------------------
elseif locale == "zhCN" then


------------------------ koKR ------------------------
elseif locale == "koKR" then


else
-------------------- enUS Default---------------------
L["AdiBags - Tackle Box v1.0.2"] = true
L["Tackle Box"] = true
L['Put equipment and items related to the Fishing profession into the "Tackle Box" section.'] = true
L["This only applies to Fishing gear and equipment; Actual fish and other fished-up items will be extrapolated into a separate module at some point in the near future."] = true
L["Catches"] = true
L["Configure filters for fish here.\n\n|cffff7700More fish (and fishable items) will be added in future updates.\n|r"] = true

L["Gear"] = true
L["Tackle"] = true
L["Bait"] = true
L["Consumables"] = true
L["Miscellaneous"] = true
L["Fish"] = true

L["Tackle Boxes"] = true
L["Poles"] = true
L["Hats and Boots"] = true
L["Other Attire"] = true
L["Lines"] = true
L["Lures"] = true
L["Smears"] = true
L["Hooks"] = true
L["Bobbers"] = true
L["Draenor Bait"] = true
L["Broken Isles Bait"] = true
L["Provisions"] = true
L["Potions and Elixirs"] = true
L["Chairs and Rafts"] = true
L["Charms"] = true
L["Other Toys"] = true
L["Books and Journals"] = true
L["Fountain Coins"] = true
L["Nat Pagle's Lucky Coin"] = true
L["Rare Broken Isles Fish"] = true
L["Social Fish"] = true
L["Trophy Fish"] = true
L["Nat Pagle Quest Fish"] = true

L["Include the Lure Master Tackle Box in your filters."] = true
L["Add a filter for your fishing poles, including the Sharpened Tuskarr Spear."] = true
L["Add a filter for fishing apparel."] = true
L["Add a filter for apparel that isn't necessarily directly related to fishing, but that some people may still find helpful (such as Azure Silk Belt or Deepdive Helmet)."] = true
L["Add a filter for trinkets that are useful for fishing."] = true
L["Add a filter for fishing lines."] = true
L["Add a filter for fishing lures."] = true
L["Add a filter for fishing smears."] = true
L["Include Bladebone Hooks in your filters."] = true
L["Add a filter for fishing bobbers. This includes crates of bobbers."] = true
L["Add a filter for bait found in and around Draenor."] = true
L["Add a filter for bait found in and around the Broken Isles."] = true
L["Add a filter for consumables directly related to fishing, such as Captain Rumsey's Lager or \"Fragrant\" Pheromone Fish."] = true
L["Add a filter for consumables such as Swim Speed Potions or Water Walking Elixirs."] = true
L["Include a filter for chairs and rafts that can be added to your Toy Box collection."] = true
L["Include a filter for other fishing-related toys that can be added to your Toy Box collection."] = true
L["Add Hook of the Master Angler and Ancient Pandaren Fishing Charm to your filters."] = true
L["Add a filter for Nat Pagle's guides and journals."] = true
L["Add a filter for coins fished out of the Dalaran fountain. This includes coins fished from Dalaran in the Broken Isles."] = true
L["Include Nat's Lucky Coin in your Tackle Box filters."] = true
L["Configure filters for fish and fished items."] = true
L["Add a filter for rare fish found in the waters around the Broken Isles."] = true
L["Add \"social\" fish that can be thrown at other players to your filters. This includes \"Fragrant\" Pheromone Fish."] = true
L["Add trophy fish that can be wielded to your filters. This includes Old Crafty and Old Ironjaw."] = true
L["Add a filter for quest fish that can be returned to Nat Pagle for friendship reputation."] = true
end

-- Replace remaining true values by their key
for k,v in pairs(L) do
	if v == true then
		L[k] = k
	end
end
