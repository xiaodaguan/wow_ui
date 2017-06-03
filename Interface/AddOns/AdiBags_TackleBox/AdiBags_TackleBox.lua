--[[ 
AdiBags - Tackle Box v1.0.2 [5.25.2017]
Adds filters and groupings for the Fishing profession to AdiBags.
]]--

local addonName, addon = ...
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local L = addon.L
local MatchIDs
local Tooltip
local Result = {}

local function AddToSet(Set, List)
	for _, v in ipairs(List) do
		Set[v] = true
	end
end
-- Item tables
local FishingPoles = {
	6256,	-- Fishing Pole
	6365,	-- Strong Fishing Pole
	6366,	-- Darkwood Fishing Pole
	6367,	-- Big Iron Fishing Pole
	19022,	-- Nat Pagle's Extreme Angler FC-5000
	19970,	-- Arcanite Fishing Pole
	25978,	-- Seth's Graphite Fishing Pole
	44050,	-- Mastercraft Kalu'ak Fishing Pole
	45858,	-- Nat's Lucky Fishing Pole
	45991,	-- Bone Fishing Pole
	45992,	-- Jeweled Fishing Pole	
	46337,	-- Staats' Fishing Pole
	84660,	-- Pandaren Fishing Pole
	84661,	-- Dragon Fishing Pole
	88535,	-- Sharpened Tuskarr Spear
	116825,	-- Savage Fishing Pole
	116826,	-- Draenic Fishing Pole
	118381,	-- Ephemeral Fishing Pole
	120163,	-- Thruk's Fishing Rod
	133755,	-- Underlight Angler
}
local FishingBags = {
	60218,	-- Lure Master Tackle Box
}
local FishingAttire = {
	19969,	-- Nat Pagle's Extreme Anglin' Boots
	19972,	-- Lucky Fishing Hat
	33820,	-- Weather-Beaten Fishing Hat
	50287,	-- Boots of the Bay
	88710,	-- Nat's Hat
	93732,	-- Darkmoon Fishing Cap
	117405,	-- Nat's Drinking Hat
	118380,	-- Hightfish Cap
	118393,	-- Tentacled Hat
}
local MiscAttire = {
	7052,	-- Azure Silk Belt
	10506,	-- Deepdive Helmet
	57429,	-- Fisherman's Belt
	57481,	-- Fisherman's Gloves
}
local FishingHooks = {
	122742,	-- Bladebone Hook
}
local FishingLines = {
	19971,	-- High Test Eternium Fishing Line
	34836,	-- Spun Truesilver Fishing Line
	68796,	-- Reinforced Fishing Line
	116117,	-- Rook's Lucky Fishin' Line
}
local FishingLures = {
	6529,	-- Shiny Bauble
	6530,	-- Nightcrawlers
	6532,	-- Bright Baubles
	6533,	-- Aquadynamic Fish Attractor
	6811,	-- Aquadynamic Fish Lens
	7307,	-- Flesh Eating Worm
	34861,	-- Sharpened Fish Hook
	46006,	-- Glow Worm
	62673,	-- Feathered Lure
	67404,	-- Glass Fishing Bobber
	68049,	-- Heat-Treated Spinning Lure
	118391,	-- Worm Supreme
	124674,	-- Day-Old Darkmoon Doughnut
	138956,	-- Hypermagnetic Lure
	139175,	-- Arcane Lure
}
local FishingSmears = {
	138961,	-- Alchemical Bonding Agent
}
local FishingBobbers = {
	136373,	-- Can O' Worms Bobber
	136374,	-- Toy Cat Head Bobber
	136375,	-- Squeaky Duck Bobber
	136376,	-- Murloc Bobber
	136377,	-- Oversized Bobber
	133688,	-- Tugboat Bobber
	142528,	-- Crate of Bobbers: Can of Worms
	142529,	-- Crate of Bobbers: Cat Head
	142530,	-- Crate of Bobbers: Tugboat
	142531,	-- Crate of Bobbers: Squeaky Duck
	142532,	-- Crate of Bobbers: Murloc Head
	143662,	-- Crate of Bobbers: Wooden Pepe
}
local DraenorBait = {
	110274,	-- Jawless Skulker Bait
	110289,	-- Fat Sleeper Bait
	110290,	-- Blind Lake Sturgeon Bait
	110291,	-- Fire Ammonite Bait
	110292,	-- Sea Scorpion Bait
	110293,	-- Abyssal Gulper Eel Bait
	110294,	-- Blackwater Whiptail Bait
	128229,	-- Felmouth Frenzy Bait
}
local LegionBait = {
	133701, -- Skrog Toenail
	133702, -- Aromatic Murloc Slime
	133703, -- Pearlescent Conch
	133704, -- Rusty Queenfish Brooch
	133705,	-- Rotten Fishbone
	133706,	-- Mossgill Bait
	133707,	-- Nightmare Nightcrawler
	133708,	-- Drowned Thistleleaf
	133709, -- Funky Sea Snail
	133710, -- Salmon Lure
	133711, -- Swollen Murloc Egg
	133712, -- Frost Worm
	133713, -- Moosehorn Hook
	133714, -- Silverscale Minnow
	133715, -- Ancient Vrykul Ring
	133716, -- Soggy Drakescale
	133717, -- Enchanted Lure
	133719, -- Sleeping Murloc
	133720, -- Demonic Detritus
	133721, -- Message in a Beer Bottle
	133722, -- Axefish Lure
	133723, -- Stunned, Angry Shark
	133724, -- Decayed Whale Blubber
	133795, -- Ravenous Fly
}
local FishingProvisions = {
	34832,	-- Captain Rumsey's Lager
	110508,	-- "Fragrant" Pheromone Fish
}
local FishingPotions = {
	5996,	-- Elixir of Water Breathing
	6372,	-- Swim Speed Potion
	8827,	-- Elixir of Water Walking
	18294,	-- Elixir of Greater Water Breathing
	44012,	-- Underbelly Elixir
	76096,	-- Darkwater Potion
	116271,	-- Draenic Water Breathing Elixir
	118711,	-- Draenic Water Walking Elixir
}
local FishingChairs = {
	33223,	-- Fishing Chair
	70161,	-- Mushroom Chair
	85500,	-- Anglers Fishing Raft
	86596,	-- Nat's Fishing Chair
}
local FishingCharms = {
	19979,	-- Hook of the Master Angler
	85973,	-- Ancient Pandaren Fishing Charm
}
local FishingToys = {
	44430,	-- Titanium Seal of Dalaran
	86582,	-- Aqua Jewel
}
local FishingBooks = {
	18229,	-- Nat Pagle's Guide to Extreme Anglin'
	18365,	-- A Thoroughly Read Copy of "Nat Pagle's Guide to Extreme Anglin'."
	34109,	-- Weather-Beaten Journal
	88563,	-- Nat's Fishing Journal
	117401,	-- Nat's Draenic Fishing Journal
	139620,	-- A Complete Copy of "Nat Pagle's Guide to Extreme Anglin'."
}
local DalaranCoins = {
	-- Copper
	43702, 	-- Alonsus Faol's Copper Coin
	43703, 	-- Ansirem's Copper Coin
	43704, 	-- Attumen's Copper Coin
	43705, 	-- Danath's Copper Coin
	43706, 	-- Dornaa's Shiny Copper Coin
	43707, 	-- Eitrigg's Copper Coin
	43708, 	-- Elling Trias' Copper Coin
	43709, 	-- Falstad Wildhammer's Copper Coin
	43710, 	-- Genn's Copper Coin
	43711, 	-- Inigo's Copper Coin
	43712, 	-- Krasus' Copper Coin
	43713, 	-- Kryll's Copper Coin
	43714, 	-- Landro Longshot's Copper Coin
	43715, 	-- Molok's Copper Coin
	43716, 	-- Murky's Copper Coin
	43717, 	-- Princess Calia Menethil's Copper Coin
	43718, 	-- Private Marcus Jonathan's Copper Coin
	43719, 	-- Salandria's Shiny Copper Coin
	43720, 	-- Squire Rowe's Copper Coin
	43721, 	-- Stalvan's Copper Coin
	43722, 	-- Vareesa's Copper Coin
	43723, 	-- Vargoth's Copper Coin
	-- Silver
	43643, 	-- Prince Magni Bronzebeard's Silver Coin
	43644, 	-- A Peasant's Silver Coin
	43675, 	-- Fandral Staghelm's Silver Coin
	43676,	-- Arcanist Doan's Silver Coin
	43677, 	-- High Tinker Mekkatorque's Silver Coin
	43678, 	-- Antonidas' Silver Coin
	43679, 	-- Muradin Bronzebeard's Silver Coin
	43680, 	-- King Varian Wrynn's Silver Coin
	43681,	-- King Terenas Menethil's Silver Coin
	43682, 	-- King Anasterian Sunstrider's Silver Coin
	43683, 	-- Khadgar's Silver Coin
	43684, 	-- Medivh's Silver Coin
	43685,	-- Maiev Shadowsong's Silver Coin
	43686, 	-- Alleria's Silver Coin
	43687, 	-- Aegwynn's Silver Coin
	-- Gold
	43627, 	-- Thrall's Gold Coin
	43628, 	-- Lady Jaina Proudmoore's Gold Coin
	43629, 	-- Uther Lightbringer's Gold Coin
	43630, 	-- Tirion Fordring's Gold Coin
	43631, 	-- Teron's Gold Coin
	43632, 	-- Sylvanas Windrunner's Gold Coin
	43633, 	-- Prince Kael'thas Sunstrider's Gold Coin
	43634, 	-- Lady Katrana Prestor's Gold Coin
	43635, 	-- Kel'Thuzad's Gold Coin
	43636, 	-- Chromie's Gold Coin
	43637, 	-- Brann Bronzebeard's Gold Coin
	43638, 	-- Arugal's Gold Coin
	43639, 	-- Arthas' Gold Coin
	43640, 	-- Archimonde's Gold Coin
	43641, 	-- Anduin Wrynn's Gold Coin
	-- Broken Isles
	138892, -- Prince Farondis' Royal Seal
	138893, -- Runas' Last Copper
	138894, -- Stellagosa's Silver Coin
	138895, -- Senegos' Ancient Coin
	138896, -- Okuna Longtusk's Doubloon
	138897, -- Ooker's Dookat
	138898, -- Coin of Golk the Rumble
	138899, -- Daglop's Infernal Copper Coin
	138901, -- Tyrande's Coin
	138902, -- Malfurion's Coin
	138903, -- Kur'talos Ravencrest's Spectral Coin
	138904, -- Jarod Shadowsong's Coin
	138905, -- Penelope Heathrow's Allowance
	138906, -- Remulos' Sigil
	138907, -- Elothir's Golden Leaf
	138908, -- Koda's Sigil
	138909, -- King Mrgl-Mrgl's Coin
	138910, -- Hemet Nesingwary's Bullet
	138911, -- Murky's Coin
	138912, -- Spiritwalker Ebonhorn's Coin
	138913, -- Addie Fizzlebog's Coin
	138914, -- Boomboom Brullingsworth's Coin
	138915, -- The Candleking's Candlecoin
	138916, -- Torok Bloodtotem's Coin
	138917, -- God-King Skovald's Fel-Tainted Coin
	138918, -- Genn Greymane's Coin
	138919, -- Nathanos Blightcaller's Coin
	138920, -- Helya's Coin
	138921, -- Sir Finley Mrrgglton's Coin
	138922, -- Havi's Coin
	138923, -- Vydhar's Wooden Nickel
	138924, -- Rax Sixtrigger's Gold-Painted Copper Coin
	138925, -- First Arcanist Thalyssra's Coin
	138926, -- Magistrix Elisande's Coin
	138927, -- Oculeth's Vanishing Coin
	138928, -- Ly'leth Lunastre's Family Crest
	138929, -- Pearlhunter Phin's Soggy Coin
	138930, -- Advisor Vandros' Coin
	138931, -- Gul'dan's Coin
	138932, -- Yowlon's Mark
	138933, -- Allari the Souleater's Coin
	138934, -- Altruis the Sufferer's Coin
	138935, -- Cyana Nightglaive's Coin
	138936, -- Falara Nightsong's Coin
	138937, -- Izal Whitemoon's Coin
	138938, -- Jace Darkweaver's Coin
	138939, -- Kayn Sunfury's Coin
	138940, -- Korvas Bloodthorn's Coin
	138941, -- The Coin
	138942, -- Blingtron's Botcoin
	138943, -- Lady Liadrin's Coin
	138944, -- Lunara's Coin
	138945, -- Illidan's Coin
	138946, -- Queen Azshara's Royal Seal
	138947, -- Gallywix's Coin-on-a-String
	138948, -- Li Li's Coin
}
local LuckyCoin = {
	117397,	-- Nat's Lucky Coin
}
-- Fish
local RareFish= {
	133725, -- Leyshimmer Blenny
	133726, -- Nar'thalas Hermit
	133727, -- Ghostly Queenfish
	133728, -- Terrorfin
	133729, -- Thorned Flounder
	133730, -- Ancient Mossgill
	133731, -- Mountain Puffer
	133732, -- Coldriver Carp
	133733, -- Ancient Highmountain Salmon
	133734, -- Oodelfjisk
	133735, -- Graybelly Lobster
	133736, -- Thundering Stormray
	133737, -- Magic-Eater Frog
	133738, -- Seerspine Puffer
	133739, -- Tainted Runescale Koi
	133740, -- Axefish
	133741, -- Seabottom Squid
	133742, -- Ancient Black Barracuda
	139652, -- Leyshimmer Blenny
	139653, -- Nar'thalas Hermit
	139654, -- Ghostly Queenfish
	139655, -- Terrorfin
	139656, -- Thorned Flounder
	139657, -- Ancient Mossgill
	139658, -- Mountain Puffer
	139659, -- Coldriver Carp
	139660, -- Ancient Highmountain Salmon
	139661, -- Oodelfjisk
	139662, -- Graybelly Lobster
	139663, -- Thundering Stormray
	139664, -- Magic-Eater Frog
	139665, -- Seerspine Puffer
	139666, -- Tainted Runescale Koi
	139667, -- Axefish
	139668, -- Seabottom Squid
	139669, -- Ancient Black Barracuda
}
local SocialFish = {
	118414,	-- Awesomefish
	118511, -- Tyfish
	110508, -- "Fragrant" Pheromone Fish
	118415, -- Grieferfish
}
local TrophyFish = {
	6360,	-- Steelscale Crushfish
	19808,	-- Rockhide Strongfish
	44703,	-- Dark Herring
	34486,	-- Old Crafty
	34484,	-- Old Ironjaw
}
local PagleFish = {
	86542,	-- Flying Tiger Gourami
	86545,	-- Mimic Octopus
	86544,	-- Spinefish Alpha
}
local function MatchIDs_Init(self)
	wipe(Result)
	
	if self.db.profile.cueFishingPoles then
	AddToSet(Result,FishingPoles)
	end	
	if self.db.profile.cueFishingBags then
	AddToSet(Result,FishingBags)
	end
	if self.db.profile.cueFishingAttire then
	AddToSet(Result,FishingAttire)
	end
	if self.db.profile.cueMiscAttire then
	AddToSet(Result,MiscAttire)
	end
	if self.db.profile.cueFishingHooks then
	AddToSet(Result,FishingHooks)
	end
	if self.db.profile.cueFishingLines then
	AddToSet(Result,FishingLines)
	end
	if self.db.profile.cueFishingLures then
	AddToSet(Result,FishingLures)
	end
	if self.db.profile.cueFishingSmears then
	AddToSet(Result,FishingSmears)
	end	
	if self.db.profile.cueFishingBobbers then
	AddToSet(Result,FishingBobbers)
	end
	if self.db.profile.cueDraenorBait then
	AddToSet(Result,DraenorBait)
	end
	if self.db.profile.cueLegionBait then
	AddToSet(Result,LegionBait)
	end
	if self.db.profile.cueFishingProvisions then
	AddToSet(Result,FishingProvisions)
	end
	if self.db.profile.cueFishingPotions then
	AddToSet(Result,FishingPotions)
	end
	if self.db.profile.cueFishingChairs then
	AddToSet(Result,FishingChairs)
	end
	if self.db.profile.cueFishingCharms then
	AddToSet(Result,FishingCharms)
	end
	if self.db.profile.cueFishingToys then
	AddToSet(Result,FishingToys)
	end
	if self.db.profile.cueFishingBooks then
	AddToSet(Result,FishingBooks)
	end
	if self.db.profile.cueDalaranCoins then
	AddToSet(Result,DalaranCoins)
	end
	if self.db.profile.cueLuckyCoin then
	AddToSet(Result,LuckyCoin)
	end
	if self.db.profile.cueRareFish then
	AddToSet(Result,RareFish)
	end
	if self.db.profile.cueSocialFish then
	AddToSet(Result,SocialFish)
	end
	if self.db.profile.cueTrophyFish then
	AddToSet(Result,TrophyFish)
	end
	if self.db.profile.cuePagleFish then
	AddToSet(Result,PagleFish)
	end
	
	return Result
end

-- Tooltip
local function Tooltip_Init()
	local tipResult, leftside = CreateFrame("GameTooltip"), {}
	for i = 1,6 do
		local L,R = tipResult:CreateFontString(), tipResult:CreateFontString()
		L:SetFontObject(GameFontNormal)
		R:SetFontObject(GameFontNormal)
		tipResult:AddFontStrings(L,R)
		leftside[i] = L
	end
	tipResult.leftside = leftside
	return tipResult
end

-- Filters
local fishingFilter = AdiBags:RegisterFilter(L["Tackle Box"],89,"ABEvent-1.0")
	fishingFilter.uiName = L["Tackle Box"]
	fishingFilter.uiDesc = L['Put equipment and items related to the Fishing profession into the "Tackle Box" section.']
		..'\n'..L[""]
		..'\n|cffff7700'..L["This only applies to Fishing gear and equipment; Actual fish and other fished-up items will be extrapolated into a separate module at some point in the near future."]..'|r'
		..'\n'..L[""]
		
function fishingFilter:OnInitialize()
	self.db = AdiBags.db:RegisterNamespace("Tackle Box", {
		profile = {
			cueFishingPoles = true,			
			cueFishingBags = true,
			cueFishingAttire = true,
			cueMiscAttire = true,
			cueFishingHooks = true,
			cueFishingLines = true,
			cueFishingLures = true,
			cueFishingSmears = true,			
			cueFishingBobbers = true,
			cueDraenorBait = true,
			cueLegionBait = true,
			cueFishingProvisions = true,
			cueFishingPotions = true,
			cueFishingChairs = true,
			cueFishingCharms = true,
			cueFishingToys = true,
			cueFishingBooks = true,
			cueDalaranCoins = true,
			cueLuckyCoin = true,
			cueRareFish = true,
			cueSocialFish = true,
			cueTrophyFish = true,
			cuePagleFish = true,
		},
	})
end

function fishingFilter:Update()
	MatchIDs = nil
	self:SendMessage('AdiBags_FiltersChanged')
end

function fishingFilter:OnEnable()
	AdiBags:UpdateFilters()
end

function fishingFilter:OnDisable()
	AdiBags:UpdateFilters()
end

function fishingFilter:Filter(slotData)
	MatchIDs = MatchIDs or MatchIDs_Init(self)
		if MatchIDs[slotData.itemId] then
			return L["Tackle Box"]
		end
		Tooltip = Tooltip or Tooltip_Init()
		Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		Tooltip:ClearLines()
		if slotData.bag == BANK_CONTAINER then
			Tooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(slotData.slot, nil))
		else
			Tooltip:SetBagItem(slotData.bag, slotData.slot)
		end
	Tooltip:Hide()
end


-- Options
function fishingFilter:GetOptions()
	return {
		header = {
			name = L["AdiBags - Tackle Box v1.0.2"],
			type = 'header',
			order = 1,
		},
		gearGroup = {
			name = L["Gear"],
			type = 'group',
			order = 10,
			inline = true,
			args = {
				cueFishingPoles = {
					name = L["Poles"],
					desc = L["Add a filter for your fishing poles, including the Sharpened Tuskarr Spear."],
					type = 'toggle',
					order = 11,
				},							
				cueFishingBags = {
					name = L["Tackle Boxes"],
					desc = L["Include the Lure Master Tackle Box in your filters."],
					type = 'toggle',
					order = 12,
					width = 'double',
				},
				cueFishingAttire = {
					name = L["Hats and Boots"],
					desc = L["Add a filter for fishing apparel."],
					type = 'toggle',
					order = 13,
				},
				cueMiscAttire = {
					name = L["Other Attire"],
					desc = L["Add a filter for apparel that isn't necessarily directly related to fishing, but that some people may still find helpful (such as Azure Silk Belt or Deepdive Helmet)."],
					type = 'toggle',
					order = 14,
				},
			},
		},
		tackleGroup = {
			name = L["Tackle"],
			type = 'group',
			order = 20,
			inline = true,
			args = {			
				cueFishingHooks = {
					name = L["Hooks"],
					desc = L["Include Bladebone Hooks in your filters."],
					type = 'toggle',
					order = 21,
				},
				cueFishingLines = {
					name = L["Lines"],
					desc = L["Add a filter for fishing lines."],
					type = 'toggle',
					order = 22,
				},
				cueFishingLures = {
					name = L["Lures"],
					desc = L["Add a filter for fishing lures."],
					type = 'toggle',
					order = 23,
				},
				cueFishingSmears = {
					name = L["Smears"],
					desc = L["Add a filter for fishing smears."],
					type = 'toggle',
					order = 24,
				},
				cueFishingBobbers = {
					name = L["Bobbers"],
					desc = L["Add a filter for fishing bobbers. This includes crates of bobbers."],
					type = 'toggle',
					order = 25,
				},
			},
		},
		baitGroup = {
			name = L["Bait"],
			type = 'group',
			order = 30,
			inline = true,
			args = {
				cueDraenorBait = {
					name = L["Draenor Bait"],
					desc = L["Add a filter for bait found in and around Draenor."],
					type = 'toggle',
					order = 31,
				},
				cueLegionBait = {
					name = L["Broken Isles Bait"],
					desc = L["Add a filter for bait found in and around the Broken Isles."],
					type = 'toggle',
					order = 32,
				},
			},
		},
		consumablesGroup = {
			name = L["Consumables"],
			type = 'group',
			order = 40,
			inline = true,
			args = {
				cueFishingProvisions = {
					name = L["Provisions"],
					desc = L["Add a filter for consumables directly related to fishing, such as Captain Rumsey's Lager or \"Fragrant\" Pheromone Fish."],
					type = 'toggle',
					order = 41,
				},
				cueFishingPotions = {
					name = L["Potions and Elixirs"],
					desc = L["Add a filter for consumables such as Swim Speed Potions or Water Walking Elixirs."],
					type = 'toggle',
					order = 42,
				},
			},
		},
		miscGroup = {
			name = L["Miscellaneous"],
			type = 'group',
			order = 80,
			inline = true,
			args = {
				cueFishingChairs = {
					name = L["Chairs and Rafts"],
					desc = L["Include a filter for chairs and rafts that can be added to your Toy Box collection."],
					type = 'toggle',
					order = 81,
				},
				cueFishingCharms = {
					name = L["Charms"],
					desc = L["Add Hook of the Master Angler and Ancient Pandaren Fishing Charm to your filters."],
					type = 'toggle',
					order = 82,
				},
				cueFishingToys = {
					name = L["Other Toys"],
					desc = L["Include a filter for other fishing-related toys that can be added to your Toy Box collection."],
					type = 'toggle',
					order = 83,
				},
				cueFishingBooks = {
					name = L["Books and Journals"],
					desc = L["Add a filter for Nat Pagle's guides and journals."],
					type = 'toggle',
					order = 84,
				},
				cueDalaranCoins = {
					name = L["Fountain Coins"],
					desc = L["Add a filter for coins fished out of the Dalaran fountain. This includes coins fished from Dalaran in the Broken Isles."],
					type = 'toggle',
					order = 85,
				},
				cueLuckyCoin = {
					name = L["Nat Pagle's Lucky Coin"],
					desc = L["Include Nat's Lucky Coin in your Tackle Box filters."],
					type = 'toggle',
					order = 86,
				},
			},
		},
		fishPane = {
			name = L["Catches"],
			desc = L["Configure filters for fish and fished items."],
			type = 'group',
			order = 90,
			inline = false,
			args = {
				header = {
					name = L["AdiBags - Tackle Box v1.0.2"],
					type = 'header',
					order = 91,
				},
				_desc = {
					name = L["Configure filters for fish here.\n\n|cffff7700More fish (and fishable items) will be added in future updates.\n|r"],
					type = 'description',
					order = 92,
				},
				fishGroup = {
					name = L["Fish"],
					type = 'group',
					order = 93,
					inline = true,
					args = {
						cueTrophyFish = {
							name = L["Trophy Fish"],
							desc = L["Add trophy fish that can be wielded to your filters. This includes Old Crafty and Old Ironjaw."],
							type = 'toggle',
							order = 1,
						},
						cuePagleFish = {
							name = L["Nat Pagle Quest Fish"],
							desc = L["Add a filter for quest fish that can be returned to Nat Pagle for friendship reputation."],
							type = 'toggle',
							order = 3,
						},
						cueSocialFish = {
							name = L["Social Fish"],
							desc = L["Add \"social\" fish that can be thrown at other players to your filters. This includes \"Fragrant\" Pheromone Fish."],
							type = 'toggle',
							order = 2,
						},
						cueRareFish = {
							name = L["Rare Broken Isles Fish"],
							desc = L["Add a filter for rare fish found in the waters around the Broken Isles."],
							type = 'toggle',
							order = 4,
						},
					},
				},
			},
		},
	},
	AdiBags:GetOptionHandler(self, false, function()
		return self:Update()
	end)
end