local addonName, addon = ...

local adibags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})
local mod = adibags:NewModule('ArmourType', 'ABEvent-1.0')

do -- Localization
	L['Armour Type'] = 'Armour Type'
	L['Display the armour type of armour items.'] = 'Display the armour type of armour items.'
    L['Only equippable items'] = 'Only equippable items'
	L['Do not show duplicates of items that cannot be equipped.'] = 'Do not show duplicates of items that cannot be equipped.'
	L['Ignore low quality items'] = 'Ignore low quality items'
	L['Do not show duplicates of poor quality items.'] = 'Do not show duplicates of poor quality items.'
	L['Ignore heirloom items'] = 'Ignore heirloom items'
	L['Do not show duplicates of heirloom items.'] = 'Do not show duplicates of heirloom items.'
	L['Mininum level'] = 'Mininum level'
	L['Do not show levels under this threshold.'] = 'Do not show levels under this threshold.'
	L['Text location'] = 'Text location'
    L['Which corner of the button to show the armour indicator'] = 'Which corner of the button to show the armour indicator'
    L['Top left'] = 'Top left'
    L['Top right'] = 'Top right'
    L['Bottom right'] = 'Bottom right'
    L['Bottom left'] =  'Bottom left'

  local locale = GetLocale()
  if locale == "frFR" then

  elseif locale == "deDE" then
	
  elseif locale == "esMX" then
	
  elseif locale == "ruRU" then
	
  elseif locale == "esES" then
	
  elseif locale == "zhTW" then
	
  elseif locale == "zhCN" then
	
  elseif locale == "koKR" then
	
  end
end

mod.uiName = L['Armour Type']
mod.uiDesc = L['Display the armour type of armour items.']

function mod:OnInitialize()
	self.db = adibags.db:RegisterNamespace(self.moduleName, {
		profile = {
			minLevel = 1,
			equippableOnly = false,
			ignoreJunk = true,
			ignoreHeirloom = true,
            textLocation = 'tr'
		},
	})
end

--options:
	--minLevel
	--ignoreJunk
	--ignoreHeirloom
	--corner
function mod:GetOptions()
	return {
		minLevel = {
			name = L['Mininum level'],
			desc = L['Do not show levels under this threshold.'],
			type = 'range',
			min = 1,
			max = 600,
			step = 1,
			bigStep = 5,
			order = 30
		},
		equippableOnly = {
			name = L['Only equippable items'],
			desc = L['Do not show duplicates of items that cannot be equipped.'],
			type = 'toggle',
			order = 10,
		},
		ignoreJunk = {
			name = L['Ignore low quality items'],
			desc = L['Do not show duplicates of poor quality items.'],
			type = 'toggle',
			order = 40,
		},
		ignoreHeirloom = {
			name = L['Ignore heirloom items'],
			desc = L['Do not show duplicates of heirloom items.'],
			type = 'toggle',
			order = 50,
		},
        textLocation = {
            name = L['Text location'],
            desc = L['Which corner of the button to show the armour indicator'],
            type = 'select',
            order = 60,
            values = {
                tl = L['Top left'],
                tr = L['Top right'],
                br = L['Bottom right'],
                bl = L['Bottom left']
            }
        }
	}, adibags:GetOptionHandler(self)
end

local texts = {}
local textLocation = {
    tl = {
        anchor = 'TOPLEFT',
        x = 3,
        y = -1
    },
    tr = {
        anchor = 'TOPRIGHT',
        x = 3,
        y = -1
    },
    bl = {
        anchor = 'BOTTOMLEFT',
        x = 3,
        y = 1
    },
    br = {
        anchor = 'BOTTOMRIGHT',
        x = -1,
        y = 1
    }
}

function mod:OnEnable()
	self:RegisterMessage('AdiBags_UpdateButton', 'UpdateButton')
	self:SendMessage('AdiBags_UpdateAllButtons')
end

function mod:OnDisable()
	self:UnregisterMessage('AdiBags_UpdateButton')
	for _, text in pairs(texts) do
		text:Hide()
	end
end

local function CreateText(button, settings)
    if texts[button] then
        return texts[button]
    end
    
    local textLocation = textLocation[settings.textLocation]
	local text = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	text:SetPoint(textLocation.anchor, button, textLocation.x, textLocation.y)
	text:Hide()
	texts[button] = text
	return text
end

local subClassText = {
    Plate = 'P',
    Mail = 'M',
    Leather = 'L',
    Cloth = 'C'
}

function mod:UpdateButton(event, button)
	local settings = self.db.profile
	local link = button:GetItemLink()
    local text = CreateText(button, settings)
	
	if link then
		local itemName, _, quality, _, reqLevel, class, subClass = GetItemInfo(link)

        if class == 'Armor' and subClassText[subClass] ~= nil then
            text:SetText(subClassText[subClass])
            text:SetTextColor(1.00, 1.00, 1.00)
            return text:Show()
        end
	end
end
