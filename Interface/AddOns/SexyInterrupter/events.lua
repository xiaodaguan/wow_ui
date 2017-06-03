local LSM = LibStub("LibSharedMedia-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("SexyInterrupter", false);

function SexyInterrupter:UNIT_FLAGS() 
	SexyInterrupter:GROUP_ROSTER_UPDATE();
end

function SexyInterrupter:GROUP_ROSTER_UPDATE()
	SexyInterrupter:UpdateInterrupters();
	SexyInterrupter:UpdateUI();
	SexyInterrupter:UpdateInterrupterStatus();

	SexyInterrupter:UpdateInterrupterSettings();
end

function SexyInterrupter:COMBAT_LOG_EVENT_UNFILTERED(...)
	local event = select(3, ...)
    local sourceGUID = select(5, ...)
    local sourceName = select(6, ...)
	local destName = select(10, ...)
    local spellId = select(13, ...)
    local spellName = select(14, ...)
	local spells = self.interruptSpells;

    if event == "SPELL_CAST_SUCCESS" then
        if (tContains(spells, spellId)) then
			local cooldown = GetSpellBaseCooldown(spellId);

			SexyInterrupter:InterruptUsed(sourceName, cooldown / 1000);
        end
    elseif event == 'SPELL_INTERRUPT' then
		spellId = select(16, ...);
		spellName = select(17, ...);

		if self.db.profile.notification.interruptmessage and (sourceGUID == UnitGUID('player') or sourceGUID == UnitGUID('pet')) then
			SexyInterrupter:ShowInterruptMessage(destName, spellId, spellName);
		end
	end
end

--function SexyInterrupter:PARTY_MEMBERS_CHANGED() 
	--print('PARTY_MEMBERS_CHANGED', ...);
--end

function SexyInterrupter:UPDATE_INSTANCE_INFO() 
	local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo();
	local isInstance, instanceType = IsInInstance();

	if isInstance then
		--print('UPDATE_INSTANCE_INFO', name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize);
		--print('UPDATE_INSTANCE_INFO', isInstance, instanceType);
	end
end

function SexyInterrupter:UNIT_SPELLCAST_START(...)
	local unit = select(2, ...)

	if (unit == "target" and SI_Globals.numInterrupters > 0) then
        local startTime, endTime, _, _, interruptImmune = select(5, UnitCastingInfo("target"));

		if not interruptImmune and UnitCanAttack('player', 'target') then
			local name, realm = UnitName('player');
			local fullname = name;

			if realm ~= nil then
				fullname = name .. '-' .. realm;
			end

			local interrupter = SexyInterrupter:GetInterrupter(fullname);

			if interrupter.sortpos == 1 then
				local timeVisible = 10;

                if (startTime and endTime and endTime/1000 - startTime/1000 < 10) then
                    timeVisible = endTime - startTime
                end

				local tName = UnitName('target');

				if self.db.profile.notification.message then
					local text = L["Interrupt now"] .. ' |cFFFF0000' .. tName .. '|r !!';
					SexyInterrupterInterruptNowText:AddMessage(text, 1,1,1);
					SexyInterrupterInterruptNowText:SetTimeVisible(timeVisible);
					SexyInterrupterInterruptNowText.text = text;
				end

				if self.db.profile.notification.sound then
					PlaySoundFile("Sound\\Spells\\PVPFlagTaken.ogg");
				end

				if self.db.profile.notification.flash then
					SexyInterrupterBlueWarningFrame:Show();
				end
			end
		end
	end
end

function SexyInterrupter:UNIT_SPELLCAST_STOP(...)
	local unit = select(2, ...)

    if unit == "target" and SexyInterrupterInterruptNowText:IsVisible() then
        SexyInterrupterInterruptNowText:SetTimeVisible(0);

		SexyInterrupterBlueWarningFrame:Hide();
	end
end

function SexyInterrupter:PLAYER_TARGET_CHANGED()
	local targetName = UnitName("target");
	
	if targetName then
		local encounterId = self:GetEntcounterId(targetName);
		
		--print('PLAYER_TARGET_CHANGED', encounterId);
	end

    if SexyInterrupterInterruptNowText:IsVisible() then
        SexyInterrupterInterruptNowText:SetTimeVisible(0);
		
		SexyInterrupterBlueWarningFrame:Hide();
    end
end

function SexyInterrupter:PLAYER_REGEN_DISABLED() 
	if self.db.profile.general.modeincombat then
		SexyInterrupterAnchor:Show();
	end
end

function SexyInterrupter:PLAYER_REGEN_ENABLED() 
	if self.db.profile.general.modeincombat then
		SexyInterrupterAnchor:Hide();
	end
end

function SexyInterrupter:CHAT_MSG_ADDON(...)
	local prefix = select(2, ...)
	local msg, _, sender, noRealmNameSender = select(3, ...);

    if prefix == "SexyInterrupter" and not strfind(sender, UnitName("player")) then
        SexyInterrupter:AddonMessageReceived(...)
    end
end

function SexyInterrupter:OnUpdate()
	local currentplayer = SexyInterrupter:GetInterrupter(select(1, UnitName("player")));

	for cx, value in pairs(SexyInterrupter:GetCurrentInterrupters()) do
		if currentplayer and currentplayer.sortpos > SexyInterrupter.db.profile.general.maxrows and SexyInterrupter.db.profile.general.maxrows == cx then
			value = currentplayer;
		end

        if value.readyTime > 0 then
			local bar = _G["SexyInterrupterStatusBar" .. cx];

			if bar then			
				if (value.readyTime - GetTime() <= 0) then
					bar.cooldownText:SetText('');
					value.readyTime = 0;
					bar:SetValue(0);
					return;
				end

				bar:SetValue(value.readyTime - GetTime());
				bar.cooldownText:SetText(string.format('%.1f', value.readyTime - GetTime()));
			end
		end
	end
end
