-- RaceName
if GetLocale() == "zhCN" then
	RaceNames = 
	{
		[2] = "����",
		[3] = "Ѫ����",
		[4] = "������",
		[5] = "����",
		[6] = "٪��",
		[7] = "�ؾ�",
		[8] = "��ҹ����",
		[9] = "����",
		[10] = "��è��",
		[11] = "ţͷ��",
		[12] = "��ħ",
		[13] = "����",
		[14] = "����",
		[15] = "ʳ��ħ",
		[28] = "��е",
		[29] = "��������",
		[30] = "����ħ",
		[31] = "ľ��",
		[33] = "������",
		[34] = "������",
		[35] = "���",
		[36] = "ѻ��������",
		[37] = "������",
		[41] = "��ƥϣ˹����",
		[42] = "�ߵ�ѻ��"
	}
elseif GetLocale() == "zhTW" then
	RaceNames = 
	{
		[2] = "���",
		[3] = "Ѫ���`",
		[4] = "���R��",
		[5] = "����",
		[6] = "�ؾ�",
		[7] = "�粼��",
		[8] = "ҹ���`",
		[9] = "�F��",
		[10] = "��؈��",
		[11] = "ţ�^��",
		[12] = "ʳ����",
		[13] = "������",
		[14] = "����",
		[15] = "��ħ",
		[28] = "�Cе",
		[29] = "���X��",
		[30] = "�W��¡",
		[31] = "������",
		[33] = "������",
		[34] = "�\�~��",
		[35] = "����",
		[36] = "������������",
		[37] = "��F��",
		[41] = "피����o��",
		[42] = "�ߵȰ�������"
	}
else --enUS
	RaceNames = 
	{
		[2] = "Human",
		[3] = "Blood Elf",
		[4] = "Draenei",
		[5] = "Dwarf",
		[6] = "Gnome",
		[7] = "Goblin",
		[8] = "Night Elf",
		[9] = "Orc",
		[10] = "Pandaren",
		[11] = "Tauren",
		[12] = "Troll",
		[13] = "Undead",
		[14] = "Worgen",
		[15] = "Ogre",
		[28] = "Mechanical",
		[29] = "Saberon",
		[30] = "Ogron",
		[31] = "Botani",
		[33] = "Gnoll",
		[34] = "Jinyu",
		[35] = "Hozen",
		[36] = "Outcast Arakkoa",
		[37] = "Dire Orc",
		[41] = "Apexis Guardian",
		[42] = "High Arakkoa",
	}
end

local _, SmartFollowerManager = ...
local race = SmartFollowerManager.raceID
local raceName = RaceNames
local specFollower = SmartFollowerManager.specFollower

local API = {}

function API.GetClassSpecNameBySpecID(specID)
	local garrFollowerID = specFollower[specID]
	if garrFollowerID then
		return C_Garrison.GetFollowerClassSpecName(garrFollowerID)
	end
end

function API.GetRaceID(garrFollowerID)
	local id = garrFollowerID
	if not id then
		return
	end
	if type(id) == "string" then
		id = tonumber(id)
	end
	
	return race[id]
end

function API.GetRaceName(garrFollowerID)
	local id = garrFollowerID
	if not id then
		return
	end
	if type(id) == "string" then
		id = tonumber(id)
	end
	
	local rID = race[id]
	if not rID then
		return
	end
	
	local rName = raceName[rID]
	if not rName then
		rName = OTHER
	end
	
	return rName
end

SmartFollowerManager.API = API