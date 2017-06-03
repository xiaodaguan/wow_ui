local name = GetUnitName("player", true)
local hi = "hi, "..name..". Addon: gxd loaded."
print(hi)

local function Event(event, handler)
    if _G.event == nil then
        _G.event = CreateFrame("Frame")
        _G.event.handler = {}
        _G.event.OnEvent = function(frame, event, ...)
            for key, handler in pairs(_G.event.handler[event]) do
                handler(...)
            end
        end
        _G.event:SetScript("OnEvent", _G.event.OnEvent)
    end
    if _G.event.handler[event] == nil then
        _G.event.handler[event] = {}
        _G.event:RegisterEvent(event)
    end
    table.insert(_G.event.handler[event], handler)
end

local function HookFormatNumber()
    Skada.FormatNumber = function(self, number)
        if number then
            if self.db.profile.numberformat == 1 then
                if number > 100000000 then
                    return ("%02.2f亿"):format(number / 100000000)
                end
                return ("%02.2f万"):format(number / 10000)
            else
                return math.floor(number)
            end
        end
    end
end

Event("PLAYER_ENTERING_WORLD", function()
    HookFormatNumber()
end)


-- 自用一般不要指定名字，parent最好是UIParent 
local frame = CreateFrame("Frame", nil, UIParent) 
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200) -- 调整frame在屏幕的位置 
frame:SetWidth(1200)      -- 足够大点，不然点击不到 
frame:SetHeight(40) 
frame:Hide() 
frame:SetScale(1) 
frame:EnableMouse(true) -- 确保鼠标按键有效 
local FrameText = frame:CreateFontString(nil,"ARTWORK"); 
FrameText:SetFontObject(GameFontNormal); 
FrameText:SetFont(STANDARD_TEXT_FONT, 40,"outline") 
FrameText:SetTextColor(0.8,0,0,1) -- change this to change color 
FrameText:SetPoint("CENTER")     -- text正常设置到frame自身 
FrameText:SetText("你的装备耐久低于20%！")  -- 没其他用途，就只需要设置一次 
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY") 
frame:RegisterEvent("PLAYER_ENTERING_WORLD") 
frame:SetScript("OnEvent", function(self) 
    for id=20,1,-1  do 
        local cur, max = GetInventoryItemDurability(id) 
        if cur and max and cur/max <= 0.2 then --这里修改需要提醒的百分比 
            frame:Show() 
            return -- 只要有一件，不做多余检查，否则你的代码只有第一件装备需要修理时才会显示 
        end 
    end 
    frame:Hide() 
end) 
-- 处理右键点击 
frame:SetScript("OnMouseUp", function(self, btn) 
    if btn == "RightButton" then 
        frame:Hide() 
    end 
end)