local _G = _G
local MB = MacroBox
MB.LS = LibStub
MB.L = MB.LS("AceLocale-3.0"):GetLocale("MacroBox")
MB.slash = string.sub(_G.SLASH_CAST1, 1, 1)
MB.MACRONUM = "|cff00bfff%s|r: %d/%d"
local L = MB.L
local select, GetSpellInfo, format = select, GetSpellInfo, format
MB.frame:RegisterEvent("ADDON_LOADED")
MB.frame:RegisterEvent("PLAYER_LOGIN")
MB.frame:SetScript("OnEvent", function(...) MB:EventHandler(...) end)
MB.textures = {
	["general"] = {"Interface\\GossipFrame\\BinderGossipIcon", 0, 1, 0, 1},
	["hunter"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0, 0.25, 0.25, 0.5},
	["raid"] = {"Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons", 0.75, 1, 0.25, 0.5},
	["deathknight"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.25, 0.5, 0.5, 0.75},
	["demonhunter"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.75, 1, 0.5, 0.75},
	["druid"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.75, 1, 0, 0.25},
	["mage"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.25, 0.5, 0, 0.25},
	["monk"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.5, 0.75, 0.5, 0.75},
	["paladin"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0, 0.25, 0.5, 0.75},
	["priest"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.5, 0.75, 0.25, 0.5},
	["rogue"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.5, 0.75, 0, 0.25},
	["shaman"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.25, 0.5, 0.25, 0.5},
	["warrior"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0, 0.25, 0, 0.25},
	["warlock"] = {"Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES", 0.75, 1, 0.25, 0.5},
}

MB.MacroCommands = {
	"ACHIEVEMENTUI","ASSIST","BENCHMARK","CALENDAR","CANCELAURA","CANCELFORM","CANCELQUEUEDSPELL","CAST","CASTGLYPH","CASTRANDOM", -- 10
	"CASTSEQUENCE","CHANGEACTIONBAR","CHANNEL","CHATLOG","CHAT_AFK","CHAT_ANNOUNCE","CHAT_BAN","CHAT_CINVITE","CHAT_DND","CHAT_HELP", -- 20
	"CHAT_KICK","CHAT_MODERATE","CHAT_MODERATOR","CHAT_MUTE","CHAT_OWNER","CHAT_PASSWORD","CHAT_UNBAN","CHAT_UNMODERATOR","CHAT_UNMUTE","CLEAR", -- 30
	"CLEARFOCUS","CLEARMAINASSIST","CLEARMAINTANK","CLEARTARGET","CLEAR_WORLD_MARKER","CLICK","COMBATLOG","CONSOLE","DISABLE_ADDONS","DISMISSBATTLEPET", -- 40
	"DISMOUNT","DUEL","DUEL_CANCEL","DUMP","DUNGEONS","EMOTE","ENABLE_ADDONS","EQUIP","EQUIP_SET","EQUIP_TO_SLOT", -- 50
	"EVENTTRACE","FOCUS","FOLLOW","FRAMESTACK","FRIENDS","GUILD","GUILDFINDER","GUILD_DEMOTE","GUILD_DISBAND","GUILD_HELP", -- 60
	"GUILD_INFO","GUILD_INVITE","GUILD_LEADER","GUILD_LEADER_REPLACE","GUILD_LEAVE","GUILD_MOTD","GUILD_PROMOTE","GUILD_ROSTER","GUILD_UNINVITE","GUILD_WHO", -- 70
	"HELP","IGNORE","INSPECT","INSTANCE_CHAT","INVITE","JOIN","LEAVE","LEAVEVEHICLE","LIST_CHANNEL","LOGOUT", -- 80
	"LOOT_FFA","LOOT_GROUP","LOOT_MASTER","LOOT_NEEDBEFOREGREED","LOOT_ROUNDROBIN","LOOT_SETTHRESHOLD","MACRO","MACROHELP","MAINASSISTOFF","MAINASSISTON", -- 90
	"MAINTANKOFF","MAINTANKON","OFFICER","OPEN_LOOT_HISTORY","PARTY","PET_AGGRESSIVE","PET_ASSIST","PET_ATTACK","PET_AUTOCASTOFF","PET_AUTOCASTON", -- 100
	"PET_AUTOCASTTOGGLE","PET_DEFENSIVE","PET_FOLLOW","PET_MOVE_TO","PET_PASSIVE","PET_STAY","PLAYED","PROMOTE","PVP","QUIT", -- 110
	"RAID","RAIDBROWSER","RAIDFINDER","RAID_INFO","RAID_WARNING","RANDOM","RANDOMFAVORITEPET","RANDOMPET","READYCHECK","RELOAD", -- 120
	"REMOVEFRIEND","REPLY","RESETCHAT","SAVEGUILDROSTER","SAY","SCRIPT","SET_TITLE","SMART_WHISPER","STARTATTACK","STOPATTACK", -- 130
	"STOPCASTING","STOPMACRO","STOPSPELLTARGET","STOPWATCH","SUMMON_BATTLE_PET","SWAPACTIONBAR","TARGET","TARGET_EXACT","TARGET_LAST_ENEMY","TARGET_LAST_FRIEND", -- 140
	"TARGET_LAST_TARGET","TARGET_MARKER","TARGET_NEAREST_ENEMY","TARGET_NEAREST_ENEMY_PLAYER","TARGET_NEAREST_FRIEND","TARGET_NEAREST_FRIEND_PLAYER","TARGET_NEAREST_PARTY","TARGET_NEAREST_RAID","TEAM_CAPTAIN","TEAM_DISBAND", -- 150
	"TEAM_INVITE","TEAM_QUIT","TEAM_UNINVITE","TIME","TOKEN","TRADE","UNIGNORE","UNINVITE","USE","USERANDOM", -- 160
	"USE_TALENT_SPEC","VOICEMACRO","WARGAME","WHISPER","WHO","WORLD_MARKER","YELL", "PET_DISMISS"}

--tokenised to make them locale agnostic
-- // - slash/# command, :: = spell id, $ = item id, * = emote, & = newline
function MB:gsi(sid)
	local sname
	if type(sid) == "number" then
		sname = select(1, GetSpellInfo(sid))
	else
		sname = sid
	end
	sname = sname or "_removed_"
	return sname
end

local function gsi(sid)
	return MB:gsi(sid)
end

function MB:GenerateMacros()
	MB.Macros = {
	["general"] = {
		[1] = {"//5::19263&//5::1022&//5::44212&//5::54649&//5::1706&//5::130&//5::34477&//41&//126 VehicleExit()", L["Cancel auras"]},
		[2] = {"//999&//8 [mod:shift,nocombat]::116562&//132 [mod]&//34 [dead]&//143 [noexists]&//2 [help,nodead,combat]&//129 [harm,nodead]", L["Attack, or fish"]},
		[3] = {"//126 local a=\"gxWindow\";SetCVar(a,1-GetCVar(a));SetCVar(\"gxMaximize\",0);RestartGx()", L["Toggle screen mode"]},
		[4] = {"//126 SetCVar(\"cameraDistanceMax\",50)", L["Max camera distance"]},
		[5] = {"//126 ShowCloak(not ShowingCloak())", L["Toggle cloak"]},
		[6] = {"//126 ShowHelm(not ShowingHelm())", L["Toggle helm"]},
	},
	["hunter"] = {
		[1] = {"//5::186265",format("%s-%s", _G.CANCEL, gsi(186265))},
		[2] = {"//999::34477&//8 [@mouseover,help,nodead][@focus,help,nodead]::34477",34477},
		[3] = {"//999::205440&//98&//8::205440",205440},
		[4] = {"//999::2643&//98&//8::2643",2643},
		[5] = {"//999::186890&//98&//8::186890",186890},
		[6] = {"//999::205441&//98&//8::205441",205441},
	},
	["raid"] = {
		[1] = {format("//126 SetRaidTargetIcon(\"target\",7)&//115 %s&/dbm pull 3", L["Pulling in 3 seconds"]), L["Pull with DBM warning"]},
		[2] = {"//36 ExtraActionButton1", L["Click boss action button"]},
		[3] = {"//126 if(xx or 0)==0 then xx=9 end xx=xx-1 SetRaidTarget(\"mouseover\",xx)", _G.BINDING_HEADER_RAID_TARGET},
		[4] = {"//52 [@mouseover,exists][exists]&//132 [@mouseover,exists][exists]&//31", L["Focus macro"]},
		[5] = {"//126 nfb=\"[Eat!]: \";for i=1,GetNumGroupMembers()do for b=1,40 do ua=UnitAura('raid'..i,b);if ua==\"Well Fed\"or ua==\"Food\"then break;elseif b==40 and ua~=\"Well Fed\"then nfb=nfb..UnitName('raid'..i)..\" \";end;end;end;print(nfb);", L["No food buff"]},
		[6] = {"//126 nfb=\"[Eat!]: \";for i=1,GetNumGroupMembers()do for b=1,40 do ua=UnitAura('raid'..i,b);if ua==\"Well Fed\"or ua==\"Food\"then break;elseif b==40 and ua~=\"Well Fed\"then nfb=nfb..UnitName('raid'..i)..\" \";end;end;end;SendChatMessage(nfb,\"raid\");", L["No food buff show to raid"]},
		[7] = {"//126 nf=\"[Flask!]: \";for i=1,GetNumGroupMembers()do for b=1,41 do ufl=UnitAura('raid'..i,b);if ufl then if strfind(ufl,\"Flask\")or strfind(ufl,\"Distilled\")then break;end;elseif b==41 then nf=nf..UnitName('raid'..i)..\" \";end;end;end;print(nf);", L["No flask"]},
		[8] = {"//126 nf=\"[Flask!]: \";for i=1,GetNumGroupMembers()do for b=1,41 do ufl=UnitAura('raid'..i,b);if ufl then if strfind(ufl,\"Flask\")or strfind(ufl,\"Distilled\")then break;end;elseif b==41 then nf=nf..UnitName('raid'..i)..\" \";end;end;end;SendChatMessage(nf,\"raid\");", L["No flask show to raid"]},
	},
	["deathknight"] = {
		[1] = {"//999::61999&//8 [@mouseover,help][@target]::61999",61999},
		[2] = {"//999::47528&//8 [@focus,harm,nodead][]::47528",47528},
		[3] = {"//999::108199&//8 [@focus]::108199",108199},
		[4] = {"//999::108199&//8 [@player]::108199",format("%s 2", gsi(108199))},
		[5] = {"//999::108199&//8 [mod:ctrl, @player]::108199;::108199",format("%s 3", gsi(108199))},
		[6] = {"//999::49576&//8 [@mouseover, exists, nohelp, nodead]::49576;::49576",49576},
		[7] = {"//999::203171&//8 [mod:ctrl, @cursor]::203171;[@player]::203171",203171},
		[8] = {"//5::1022",format("%s-%s", _G.CANCEL, gsi(1022))},
		[9] = {"//999::49576&//8 [@mouseover,exists]::49576;::49576",format("%s 2", gsi(49576))},
		[10] = {"//999::237680&//8 [@mouseover]::237680",237680},
		[11] = {"//999::77575&//8 [@mouseover,exists]::77575;::77575",77575},
		[12] = {"//999::212469&//8 [@mouseover,exists]::212469;::212469",212469},
		[13] = {"//8::70895&//8::83010&//8::212385&//8::212753",70895},
		[14] = {"//168 [pet]", _G.PET_DISMISS},
	},
	["demonhunter"] = {
		[1] = {"//999::183752&//8 [@focus,harm,nodead][]::183752",183752},
		[2] = {"//5::1022",format("%s-%s", _G.CANCEL, gsi(1022))},
		[3] = {"//999::185245&//8 [@mouseover,harm,nodead][]::185245",185245},
		[4] = {"//999&//8 [talent:7/1]::211048;[talent:7/2]::222703",211048},
		[5] = {"//999&//8 [talent:5/2]::234346;[talent:5/3]::206491",234346},
	},
	["druid"] = {
		[1] = {"//999::20484&//8 [@mouseover,help]::20484;::20484",20484},
		[2] = {"//999::2782&//8 [@mouseover,help,nodead][@target]::2782",2782},
		[3] = {"//999::231049&//8 [@cursor]::231049",231049},
		[4] = {"//999::8936&//38 autounshift 0&//8 [@mouseover]::8936&//38 autounshift 1&//159 3",8936},
		[5] = {"//999::221514&//8 [@mouseover,harm,nodead][]::221514",221514},
		[6] = {"//999::6795&//8 [@mouseover,harm,nodead][]::6795",6795},
		[7] = {"//999::164812&//8 [@mouseover,harm,nodead][]::164812",164812},
		[8] = {"//999::102280&//8::102280&//5::768",102280},
	},
	["mage"] = {
		[1] = {"//999&//131&//8::1953",1953},
		[2] = {"//999&//131&//5::45438&//8::45438",45438},
		[3] = {"//5::45438",format("%s-%s", _G.CANCEL, gsi(45438))},
		[4] = {"//999&//131&//8::195676&//8::145436",145436},
		[5] = {"//999&//8::33395",33395},
		[6] = {"//999&//8::228597&//8::33395",format("%s 2", gsi(33395))},
	},
	["monk"] = {
		[1] = {"//999::115450&//8 [@mouseover,help,nodead]::115450;::115450",115450},
		[2] = {"//999::116841&//8 [@mouseover,help,nodead]::116841;::116841",116841},
		[3] = {"//999::237371&//8 [@mouseover,help,nodead]::237371;::237371",237371},
		[4] = {"//999::132467&//159 [nomod, @player]::132467&//159 [mod:ctrl]::132467",132467},
		[5] = {"//999::214326&//8 [@cursor]::214326",214326},
		[6] = {"//999::214326&//8 [@player]::214326",format("%s 2", gsi(214326))},
		[7] = {"//5::1022",format("%s-%s", _G.CANCEL, gsi(1022))},
		[8] = {"//999::204181&//8 [@mouseover,harm,nodead][]::204181",204181},
		[9] = {"//999::204181&//137::163177&//8::204181&//141",format("%s 2", gsi(204181))},
		[10] = {"//999::209525&//8 [@mouseover]::209525",209525},
		[11] = {"//999::100780&//132 [channeling:::117418]&//131 [channeling:::117953]&//8::100780",100780},
	},
	["paladin"] = {
		[1] = {"//999::1022&//131&//8 [@mouseover]::1022",1022},
		[2] = {"//999::1044&//131&//8 [@mouseover]::1044",1044},
		[3] = {"//999::179485&//131&//8 [@mouseover]::179485",179485},
		[4] = {"//999::63148&//131&//8::63148",63148},
		[5] = {"//999::53652&//8 [@mouseover,help,nodead][]::53652",53652},
		[6] = {"//999::4987&//8 [@mouseover]::4987",4987},
		[7] = {"//999::6940&//131&//8 [@mouseover]::6940",6940},
		[8] = {"//999::213652&//131&//8 [@mouseover]::213652",213652},
		[9] = {"//999::213644&//8 [@mouseover]::213644",213644},
		[10] = {"//999::96231&//131&//8 [@focus,exists][]::96231",96231},
		[11] = {"//999::63148&//8::63148&//5::63148",format("%s 2", gsi(63148))},
		[12] = {"//5::1022",format("%s-%s", _G.CANCEL, gsi(1022))},
	},
	["priest"] = {
		[1] = {"//8 [@mouseover,help,nodead][]::92832",92832},
		[2] = {"//999::200829&//8 [@mouseover,help,nodead][]::200829",200829},
		[3] = {"//999&//8 [@mouseover,exists,help,talent:1/1][talent:1/1]::47666;[talent:1/2]::47666;[talent:1/3]::47666",47666},
		[4] = {"//999::589&//8 [harm,nodead][@targettarget,harm,nodead][@targettargettarget,harm,nodead][@targettargettargettarget,harm,nodead][@targettargettargettargettarget,harm,nodead]::589",589},
		[5] = {"//999::27608&//8 [@mouseover,help,nodead][]::27608",27608},
		[6] = {"//999&//8 [@mouseover,exists,help,talent:7/3][talent:7/3]::204883;[talent:7/1]::200183",200183},
		[7] = {"//999::47585&//131&//8::47585&//5::47585",47585},
	},
	["rogue"] = {
		[1] = {"//999::53&//129&//8::53",53},
		[2] = {"//999&//8 [@mouseover]::59628",59628},
		[3] = {"//999&//8 [@focus]::59628",format("%s 2", gsi(59628))},
		[4] = {"//999&//8 [@mouseover, help][@focus, help][@targettarget, help]::59628",format("%s 3", gsi(59628))},
	},
	["shaman"] = {
		[1] = {"//999&//131&//8 [@focus,exists][@target]::57994",57994},
		[2] = {"//999&//131&//8 [@focus,exists][@target]::370",370},
		[3] = {"//999&//8 [@cursor]::61882",61882},
		[4] = {"//999&//131&//8::217206",217206},
		[5] = {"//999&//8 [@mouseover]::77472",77472},
		[6] = {"//999&//8 [@cursor]::73921",73921},
		[7] = {"//999&//8 [@player]::73921",format("%s 2", gsi(73921))},
		[8] = {"//999&//8 [@focus,exists,nodead]::234893;::234893",234893},
		[9] = {"//999&//131&//8::2645",2645},
		[10] = {"//999&//132 [flying]&//126 C_MountJournal.Summon(0)&//126 UIErrorsFrame:Clear()&//8::2645",_G.MOUNT},
	},
	["warlock"] = {
		[1] = {"//999::20707&//8 [@mouseover,exists][]::20707",20707},
		[2] = {"//999&//131&//8::60854",60854},
		[3] = {"//5::60854",format("%s-%s", _G.CANCEL, gsi(60854))},
		[4] = {"//999::80240&//8 [@mouseover,harm]::80240;[harm]::80240",80240},
		[5] = {"//999::42223&//8 [@cursor]::42223",42223},
	},
	["warrior"] = {
		[1] = {"//999::50622&//5::50622&//8::50622",50622},
		[2] = {"//999::6552&//8 [@focus, harm, exists][@target]::6552",6552},
		[3] = {"//999::52174&//8 !::52174",52174},
		[4] = {"//999&//5::50622&//8 [harm]::100&//8::122979",122979},
		[5] = {"//8::1719&//8::20572&//8::26297&//8::12292&//8::107574&//159 13&//159 14",20572},
		[6] = {"//999::50622&//8::111220&//8::50622",111220},
		[7] = {"//999::197197&//8 [@mouseover,harm,nodead][@target]::197197",197197},
		[8] = {"//999::198758&//137 other_tank_name&//8::198758&//141",198758},
		[9] = {"//999::198758&//137 melee_player_name&//8::198758&//141",format("%s 2", gsi(198758))},
		[10] = {"//999::198758&//8 [@mouseover, help, nodead][@target]::198758",format("%s 3", gsi(198758))},
		[11] = {"//5::1022&//5::135910",format("%s-%s", _G.CANCEL, gsi(1022))},
	},
}
end
MB:GenerateMacros()
