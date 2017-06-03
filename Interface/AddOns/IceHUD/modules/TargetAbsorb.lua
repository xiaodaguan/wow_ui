IceTargetAbsorb = IceCore_CreateClass(IceUnitBar)

IceTargetAbsorb.prototype.highestAbsorbSinceLastZero = 0
IceTargetAbsorb.prototype.ColorName = "TargetAbsorb"

local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function IceTargetAbsorb.prototype:init(moduleName, unit, colorName)
	if moduleName == nil or unit == nil then
		IceTargetAbsorb.super.prototype.init(self, "TargetAbsorb", "target")
	else
		IceTargetAbsorb.super.prototype.init(self, moduleName, unit)
	end

	if colorName ~= nil then
		self.ColorName = colorName
	end

	self:SetDefaultColor(self.ColorName, 0.99, 0.99, 0.99)
end

function IceTargetAbsorb.prototype:GetDefaultSettings()
	local settings = IceTargetAbsorb.super.prototype.GetDefaultSettings(self)

	settings["side"] = IceCore.Side.Right
	settings["offset"] = 3
	settings["upperText"] = "[TotalAbsorb:VeryShort]"

	return settings
end

function IceTargetAbsorb.prototype:Enable(core)
	IceTargetAbsorb.super.prototype.Enable(self, core)

	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateAbsorbAmount")
	self:MyRegisterCustomEvents()

	self:UpdateAbsorbAmount()

	self:Show(false)
end

function IceTargetAbsorb.prototype:MyRegisterCustomEvents()
end

function IceTargetAbsorb.prototype:MyUnregisterCustomEvents()
end

function IceTargetAbsorb.prototype:Update()
	self:UpdateAbsorbAmount()
end

function IceTargetAbsorb.prototype:UpdateAbsorbAmount(event, unit)
	if event == "UNIT_ABSORB_AMOUNT_CHANGED" and unit ~= self.unit then
		return
	end

	local absorbAmount = UnitGetTotalAbsorbs(self.unit) or 0

	if absorbAmount <= 0 then
		self.highestAbsorbSinceLastZero = 0
	elseif absorbAmount > self.highestAbsorbSinceLastZero then
		self.highestAbsorbSinceLastZero = absorbAmount
	end

	if absorbAmount <= 0 or self.highestAbsorbSinceLastZero <= 0 then
		self:Show(false)
	else
		self:Show(true)
		self:UpdateBar(absorbAmount / self.highestAbsorbSinceLastZero, self.ColorName)
	end
end

function IceTargetAbsorb.prototype:Disable(core)
	IceTargetAbsorb.super.prototype.Disable(self, core)

	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:MyUnregisterCustomEvents()
end

if UnitGetTotalAbsorbs ~= nil then
	IceHUD.TargetAbsorb = IceTargetAbsorb:new()
end
