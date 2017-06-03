local AddonName, AddonTable = ...
local L = AddonTable.L
local DEBUG = false
--[===[@debug@
local DEBUG = true
--@end-debug@]===]
local function DebugPrint(errorMessage)
   if DEBUG then
      print(RED_FONT_COLOR_CODE..AddonName..":"..errorMessage)
   end
end

--Lookup table to convert internal item tables to a visible section name
local tableToContainer = {
   ["ArtifactItems"] = L["Artifact Power"],
   ["AncientManaItems"] = L["Ancient Mana"],
   ["ChampionUpgradeTokens"] = L["Champion Upgrades"],
   ["ChampionEquipment"] = L["Champion Equipment"],
   ["Bait"] = L["Bait"],
   ["RareFish"] = L["Rare Fish"],
   ["Reputation"] = L["Reputation"],
   ["BrokenShore"] = L["Broken Shore"],
}

--AdiBags filters 
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local legionFilter = AdiBags:RegisterFilter(L["Legion"], 91)
legionFilter.uiName = L["Legion"]
legionFilter.uiDesc = L["Put items from Legion in their own sections."]

function legionFilter:Filter(slotData)
   for tableName,tableDescription in pairs(tableToContainer) do
      if legionFilter.db.profile[tableName] then --option for the table is enabled
         if AddonTable.ItemTables[tableName][slotData.itemId] then
            return tableDescription
         end
      end
   end
   --Artifact Relics
   if self.db.profile.ArtifactRelics then
      local itemSubType,_,_,_,_,itemClassID, itemSubClassID = select(7,GetItemInfo(slotData.itemId))
      if itemClassID==3 and itemSubClassID==11 then --Class Gem Subtype Artifact Relic
         return itemSubType
      end
   end
   --7.2 Workaround
   if legionFilter.db.profile["ArtifactItems"] then
      if IsArtifactPowerItem(slotData.itemId) then
         return L["Artifact Power"]
      end
   end
end

function legionFilter:OnInitialize()
   self.db = AdiBags.db:RegisterNamespace(L["Legion"], { profile = { 
      ArtifactItems = true,
      AncientManaItems = true,
      ArtifactRelics = true,
      ChampionUpgradeTokens = true,
      ChampionEquipment = true,
      MergeChampionItems = true,
      Bait = true,
      RareFish = true,
      MergeFishBait = true,
      Reputation = true,
      BrokenShore = true,
      }})
   if self.db.profile.MergeChampionItems then
      tableToContainer["ChampionEquipment"] = L["Champion Upgrades"] --Remap to champion upgrade section
   end
   if self.db.profile.MergeFishBait then
      tableToContainer["Bait"] = L["Fish Bait"] --Remap to combined container Fish Bait
      tableToContainer["RareFish"] = L["Fish Bait"] --Remap to combined container Fish Bait
   end
end

function legionFilter:GetOptions()
   return {
      ArtifactItems = {
         name = L["Artifact Power"],
         desc = L['Create a section for Artifact Power items.'],
         type = 'toggle',
         order = 10,
      },
      AncientManaItems = {
         name = L["Ancient Mana"],
         desc = L['Create a section for Ancient Mana items.'],
         type = 'toggle',
         order = 20,
      },
      ArtifactRelics = {
         name = L['Artifact Relics'],
         desc = L['Create a section for Artifact Relics.'],
         type = 'toggle',
         order = 30,
      },
      MergeChampionItems = {
         name = L["Merge Champion Items"],
         desc = L['Put Champion Equipment and Upgrades in one section.'],
         type = 'toggle',
         order = 40,
         set = function(info,val) 
            if val then
               self.db.profile.ChampionUpgradeTokens = true
               self.db.profile.ChampionEquipment = true
               tableToContainer["ChampionEquipment"] = L["Champion Upgrades"] --Remap to champion upgrade section
            else
               tableToContainer["ChampionEquipment"] = L["Champion Equipment"] --Restore default mapping
            end
            self.db.profile.MergeChampionItems = val
            self:SendMessage('AdiBags_FiltersChanged', true)
         end,
      },
      ChampionUpgradeTokens = {
         name = L["Champion Upgrades"],
         desc = L['Create a section for Champion Upgrades items.'],
         type = 'toggle',
         order = 41,
         disabled = function() return self.db.profile.MergeChampionItems end,
      },
      ChampionEquipment = {
         name = L["Champion Equipment"],
         desc = L['Create a section for Champion Equipment.'],
         type = 'toggle',
         order = 42,
         disabled = function() return self.db.profile.MergeChampionItems end,
      },
      MergeFishBait = {
         name = L["Merge Bait and Fish"],
         desc = L['Put Fish Bait and Rare Fish in one section.'],
         type = 'toggle',
         order = 50,
         set = function(info,val) 
            if val then
               self.db.profile.Bait = true
               self.db.profile.RareFish = true
               tableToContainer["Bait"] = L["Fish Bait"] --Remap to combined container Fish Bait
               tableToContainer["RareFish"] = L["Fish Bait"] --Remap to combined container Fish Bait
            else
               tableToContainer["Bait"] = L["Bait"] 
               tableToContainer["RareFish"] = L["Rare Fish"]
            end
            self.db.profile.MergeFishBait = val 
            self:SendMessage('AdiBags_FiltersChanged', true)
         end,
      },
      Bait = {
         name = L['Bait'],
         desc = L['Create a section for Bait.'],
         type = 'toggle',
         order = 51,
         disabled = function() return self.db.profile.MergeFishBait end,
      },
      RareFish = {
         name = L['Rare Fish'],
         desc = L['Create a section for Rare Fish.'],
         type = 'toggle',
         order = 52,
         disabled = function() return self.db.profile.MergeFishBait end,
      },
      Reputation = {
         name = L["Reputation"],
         desc = L['Create a section for Reputation items.'],
         type = 'toggle',
         order = 60,
      },
      BrokenShore = {
         name = L["Broken Shore"],
         desc = L['Create a section for Broken Shore items.'],
         type = 'toggle',
         order = 70,
      },
   }, AdiBags:GetOptionHandler(self, true)
end
