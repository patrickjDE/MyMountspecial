--[[
	MyMountspecial v7.1.0.0 (r7)
	Copyright (c) 2012-2016, All rights reserved.
	
	Written an maintained by:
		Sará @ Festung der Stürme (EU-de) - Sara#2672 - sarafdswow@gmail.com
		
	You may use this AddOn free of monetary charge and modify this AddOn for personal use.
	You may redistribute modified versions of this AddOn, as long as you credit the original author(s).
	
	THIS ADDON IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
]]

local f = CreateFrame("frame");
local f2 = CreateFrame("frame");
f:RegisterEvent("COMPANION_UPDATE");
f:RegisterEvent("ADDON_LOADED");

local mounted = nil;
local timer = 0;
local interval = 120;

local function SetInterval()
	if (MyMountspecial_SV.randominterval) then
		interval = random(MyMountspecial_SV.mininterval,MyMountspecial_SV.maxinterval);
	else
		interval = MyMountspecial_SV.interval;
	end;
end;

local function Initialize()
	MyMountspecial_SV = MyMountspecial_SV or {
		enabled = true,
		randominterval = true,
		interval = 180,
		mininterval = 120,
		maxinterval = 240
	}
	if (MyMountspecial_SV.enabled == false) then
		f:UnregisterEvent("COMPANION_UPDATE");
	end;
	SetInterval();
end

local function StartRandomMountspecial()
	f:SetScript("OnUpdate",function(s,e)
		timer = timer + e;
		if (timer > interval) then
			if (GetUnitSpeed("player") == 0) then
				DoEmote("MOUNTSPECIAL");
			end
			SetInterval();
			timer = 0;
		end;
	end);
end;

local function CheckIfMounted()
	local t = 0;
	f2:SetScript("OnUpdate",function(s,e)
		t = t + e;
		if (t > 0.1) then
			mounted = IsMounted();
			f2:SetScript("OnUpdate",nil);
			if (mounted) then
				StartRandomMountspecial();
			else
				f:SetScript("OnUpdate",nil);
			end;
		end;
	end);
end;

f:SetScript("OnEvent",function(s,e,a)
	if (e == "COMPANION_UPDATE") then
		if (a == "MOUNT") then
			CheckIfMounted();
		end;
	else
		if (e == "ADDON_LOADED") then
			if (a == "MyMountspecial") then
				f:UnregisterEvent("ADDON_LOADED");
				Initialize();
			end;
		end;
	end;
end);

SLASH_MYMOUNTSPECIAL1, SLASH_MYMOUNTSPECIAL2 = '/mms', '/mymountspecial';
function SlashCmdList.MYMOUNTSPECIAL(msg)
	cmd, val = msg:match("(%S*)%s*(%S*)");
	if (cmd == "on") then
		MyMountspecial_SV.enabled = true;
		f:RegisterEvent("COMPANION_UPDATE");
		print("|cffffff22MMS|r is now |cff00ff00on|r");
	elseif (cmd == "off") then
		MyMountspecial_SV.enabled = false;
		f:UnregisterEvent("COMPANION_UPDATE");
		print("|cffffff22MMS|r is now |cffee2200off|r");
	elseif (cmd:find("ra")) then
		if (val == "on") then
			MyMountspecial_SV.randominterval = true;
			print("|cffffff22MMS:|r random intervals are now |cff00ff00on|r");
			SetInterval();
		elseif (val == "off") then
			MyMountspecial_SV.randominterval = false;
			print("|cffffff22MMS:|r random intervals are now |cffee2200off|r");
			SetInterval();
		end
	elseif (cmd:find("min")) then
		val = tonumber(val);
		if (val) then
			MyMountspecial_SV.mininterval = val;
			print("|cffffff22MMS:|r minimum interval is now "..val);
			SetInterval();
		end;
	elseif (cmd:find("max")) then
		val = tonumber(val);
		if (val) then
			MyMountspecial_SV.maxinterval = val;
			print("|cffffff22MMS:|r maximum interval is now "..val);
			SetInterval();
		end;
	elseif (cmd:find("int")) then
		val = tonumber(val);
		if (val) then
			MyMountspecial_SV.interval = val;
			print("|cffffff22MMS:|r fixed interval is now "..val);
			SetInterval();
		end;
	else
		print("|cffffff22/mms|r or |cffffff22/mymountspecial|r");
		if (MyMountspecial_SV.enabled) then
			print("  |cff00ff00on|r | |cffffff22off|r -- enable/disable addon");
		else
			print("  |cffffff22on|r | |cffee2200off|r -- enable/disable addon");
		end;
		print("  |cffffff22int #|r -- set interval in sec (now: "..MyMountspecial_SV.interval..")");
		if (MyMountspecial_SV.randominterval) then
			print("  |cffffff22random|r |cff00ff00on|r | |cffffff22off|r -- turn use of random interval on/off");
		else
			print("  |cffffff22random on|r | |cffee2200off|r -- turn random interval on/off");
		end;
		print("  |cffffff22min #|r -- set minimum interval in sec (now: "..MyMountspecial_SV.mininterval..")");
		print("  |cffffff22max #|r -- set maximum interval in sec (now: "..MyMountspecial_SV.maxinterval..")");
	end;
end;