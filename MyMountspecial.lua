--[[
	MyMountspecial v8.0.1.0 (r10)
	Copyright (c) 2012-2018, All rights reserved.
	
	Written an maintained by:
		Sará @ Festung der Stürme (EU-de) - Sara#2672 - sarafdswow@gmail.com
		
	You may use this AddOn free of monetary charge and modify this AddOn for personal use.
	You may redistribute modified versions of this AddOn, as long as you credit the original author(s).
	
	THIS ADDON IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
]]

local defaultConfiguration = {
    enabled = true,
    randominterval = true,
    interval = 180,
    mininterval = 120,
    maxinterval = 240,
};

local MMS = select(2, ...);

MMS.IntervalFrame = CreateFrame("frame", "MyMountspecialIntervalFrame");
MMS.IntervalFrame:RegisterEvent("ADDON_LOADED");

MMS.IntervalFrame:SetScript("OnEvent",function(self, event, arg1)
    if (event == "COMPANION_UPDATE") then
        if (arg1 == "MOUNT") then
            MMS.MountedCheckFrame:CheckIfMounted();
        end;
    else
        if (event == "ADDON_LOADED") then
            if (arg1 == "MyMountspecial") then
                self:UnregisterEvent("ADDON_LOADED");
                self:Initialize();
            end;
        end;
    end;
end);

function MMS.IntervalFrame:ResetInterval()
    self.timer = 0;
	if (MyMountspecial_SV.randominterval) then
		self.interval = random(MyMountspecial_SV.mininterval,MyMountspecial_SV.maxinterval);
	else
        self.interval =  MyMountspecial_SV.interval;
	end;
end;

function MMS.IntervalFrame:Initialize()
	MyMountspecial_SV = MyMountspecial_SV or defaultConfiguration;
	if (MyMountspecial_SV.enabled == false) then
		self:UnregisterEvent("COMPANION_UPDATE");
    else
        self:RegisterEvent("COMPANION_UPDATE");
	end;
    self:ResetInterval();
end;

function MMS.IntervalFrame:Start()
	self:SetScript("OnUpdate",function(self, elapsed)
		self.timer = self.timer + elapsed;
		if (self.timer > self.interval) then
			if (GetUnitSpeed("player") == 0) then
				DoEmote("MOUNTSPECIAL");
			end
            self:ResetInterval();
		end;
	end);
end;

MMS.MountedCheckFrame = CreateFrame("frame", "MyMountspecialMountedCheckFrame");
function MMS.MountedCheckFrame:CheckIfMounted()
    self.timer = 0;
    self:SetScript("OnUpdate",function(self, elapsed)
		self.timer = self.timer + elapsed;
		if (self.timer > 0.1) then
			self:SetScript("OnUpdate",nil);
			if (IsMounted()) then
                MMS.IntervalFrame:Start();
			else
				MMS.IntervalFrame:SetScript("OnUpdate",nil);
			end;
		end;
	end);
end;

local YELLOW = "ffffff22";
local RED = "ffee2200";
local GREEN = "ff00ff00";

SLASH_MYMOUNTSPECIAL1, SLASH_MYMOUNTSPECIAL2 = '/mms', '/mymountspecial';
function SlashCmdList.MYMOUNTSPECIAL(msg)
	local cmd, val = msg:match("(%S*)%s*(%S*)");
	if (cmd == "on") then
		MyMountspecial_SV.enabled = true;
		MMS.IntervalFrame:RegisterEvent("COMPANION_UPDATE");
		print("|c"..YELLOW.."MMS|r is now |c"..GREEN.."on|r");
	elseif (cmd == "off") then
		MyMountspecial_SV.enabled = false;
		MMS.IntervalFrame:UnregisterEvent("COMPANION_UPDATE");
		print("|c"..YELLOW.."MMS|r is now |c"..RED.."off|r");
	elseif (cmd:find("^r")) then
		if (val == "on") then
			MyMountspecial_SV.randominterval = true;
			print("|c"..YELLOW.."MMS:|r random intervals are now |c"..GREEN.."on|r");
		elseif (val == "off") then
			MyMountspecial_SV.randominterval = false;
			print("|c"..YELLOW.."MMS:|r random intervals are now |c"..RED.."off|r");
		end
	elseif (cmd:find("^min")) then
		val = tonumber(val);
		if (val) then
            if (val < MyMountspecial_SV.maxinterval) then
                MyMountspecial_SV.mininterval = val;
                print("|c"..YELLOW.."MMS:|r minimum interval is now "..val.."seconds");
            else
                print("|c"..YELLOW.."MMS:|r minimum interval must be smaller than the maximum interval ("..MyMountspecial_SV.maxinterval.." seconds)");
            end
		end;
	elseif (cmd:find("^max")) then
		val = tonumber(val);
		if (val) then
            if (val > MyMountspecial_SV.mininterval) then
                MyMountspecial_SV.maxinterval = val;
                print("|c"..YELLOW.."MMS:|r maximum interval is now "..val.."seconds");
            else
                print("|c"..YELLOW.."MMS:|r maximum interval must be greater than the minimum interval ("..MyMountspecial_SV.mininterval.." seconds)");
            end
		end;
	elseif (cmd:find("^i")) then
		val = tonumber(val);
		if (val) then
			MyMountspecial_SV.interval = val;
			print("|c"..YELLOW.."MMS:|r fixed interval is now "..val.."seconds");
		end;
	else
		print("|c"..YELLOW.."/mms|r or |c"..YELLOW.."/mymountspecial|r");
		if (MyMountspecial_SV.enabled) then
			print("  |c"..GREEN.."on|r | |c"..YELLOW.."off|r -- enable/disable addon");
		else
			print("  |c"..YELLOW.."on|r | |c"..RED.."off|r -- enable/disable addon");
		end;
		print("  |c"..YELLOW.."int #|r -- set fixed interval in seconds (now: "..MyMountspecial_SV.interval..")");
		if (MyMountspecial_SV.randominterval) then
			print("  |c"..YELLOW.."random|r |c"..GREEN.."on|r | |c"..YELLOW.."off|r -- turn random interval on/off");
		else
			print("  |c"..YELLOW.."random on|r | |c"..RED.."off|r -- turn random interval on/off");
		end;
		print("  |c"..YELLOW.."min #|r -- set minimum interval in seconds (now: "..MyMountspecial_SV.mininterval..")");
		print("  |c"..YELLOW.."max #|r -- set maximum interval in seconds (now: "..MyMountspecial_SV.maxinterval..")");
	end;
end;