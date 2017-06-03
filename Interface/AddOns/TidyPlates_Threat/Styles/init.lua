local _, ns = ...
local t = ns.TidyPlates_Threat

if not TidyPlatesThemeList["Threat"] then
	TidyPlatesThemeList["Threat"] = {}
end

local ThemeTable = {}

local function RegisterTheme(name, create)
	if not ThemeTable[name] then
		ThemeTable[name] = {
			name = name,
			create = create
		}
	else
		t.Print("Theme by the name of '" .. name .. "' already exists.")
	end
end

local function SetThemes(self)
	for k, v in pairs(ThemeTable) do
		TidyPlatesThemeList["Threat"][v.name] = v.create(self, v.name)
	end
end

t.RegisterTheme = RegisterTheme
t.SetThemes = SetThemes
