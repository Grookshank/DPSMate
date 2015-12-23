-- Notes
-- Need to prevent scrolling if there is not enough statusbars

-- Global Variables
DPSMate = {}
DPSMate.VERSION = "v0.1"
DPSMate.Parser = {}
DPSMate.localization = {}
DPSMate.DB = {}
DPSMate.Options = {}
DPSMate.Modules = {}
DPSMate.Events = {
	"CHAT_MSG_COMBAT_SELF_HITS",
	"CHAT_MSG_COMBAT_SELF_MISSES",
	"CHAT_MSG_SPELL_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", --
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
	"CHAT_MSG_COMBAT_PARTY_HITS",
	"CHAT_MSG_SPELL_PARTY_DAMAGE",
	"CHAT_MSG_COMBAT_PARTY_MISSES",
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	
	"COMBAT_TEXT_UPDATE",
	
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", 
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", 
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", 
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES",
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", 
	
	"CHAT_MSG_SPELL_SELF_BUFF",
	"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF",
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS",
	"CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",
	"CHAT_MSG_SPELL_PARTY_BUFF",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS",
	
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", --
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS", --
	"CHAT_MSG_SPELL_BREAK_AURA", --
	"CHAT_MSG_SPELL_AURA_GONE_SELF", --
	"CHAT_MSG_SPELL_AURA_GONE_OTHER", --
	"CHAT_MSG_SPELL_AURA_GONE_PARTY",
	
	"PLAYER_AURAS_CHANGED",
}
DPSMate.Registered = true

-- Local Variables
local RegistredModules = {}
local classcolor = {
	rogue = {r=1.0, g=0.96, b=0.41},
	priest = {r=1,g=1,b=1},
	druid = {r=1,g=0.49,b=0.04},
	warrior = {r=0.78,g=0.61,b=0.43},
	warlock = {r=0.58,g=0.51,b=0.79},
	mage = {r=0.41,g=0.8,b=0.94},
	hunter = {r=0.67,g=0.83,b=0.45},
	paladin = {r=0.96,g=0.55,b=0.73},
	shaman = {r=0,g=0.44,b=0.87},
}

-- Begin functions

function DPSMate:OnLoad()
	SLASH_DPSMate1 = "/dps"
	SlashCmdList["DPSMate"] = function(msg) DPSMate:SlashCMDHandler(msg) end

	DPSMate:InitializeFrames()
	DPSMate.Options:InitializeConfigMenu()
	DPSMate:SetStatusBarValue()
end

function DPSMate:SlashCMDHandler(msg)
	if (msg) then
		local cmd = msg
		if cmd == "lock" then
			DPSMate.Options:Lock()
		elseif cmd == "unlock" then
			DPSMate.Options:Unlock()
		elseif cmd == "config" then
			DPSMate_ConfigMenu:Show()
		elseif strsub(cmd, 1, 4) == "show" then
			local frame = getglobal("DPSMate_"..strsub(cmd, 6))
			if frame then
				DPSMate.Options:Show(frame)
			else
				DPSMate:SendMessage("Following frames are available. If there is none type /config.")
				for _, val in pairs(DPSMateSettings["windows"]) do
					DPSMate:SendMessage("|c3ffddd80- "..val["name"].."|r")
				end
			end
		elseif strsub(cmd, 1, 4) == "hide" then
			local frame = getglobal("DPSMate_"..strsub(cmd, 6))
			if frame then
				DPSMate.Options:Hide(frame)
			else
				DPSMate:SendMessage("Following frames are available. If there is none type /config.")
				for _, val in pairs(DPSMateSettings["windows"]) do
					DPSMate:SendMessage("|c3ffddd80- "..val["name"].."|r")
				end
			end
		else
			DPSMate:SendMessage("|c3ffddd80About:|r A damage meter.")
			DPSMate:SendMessage("|c3ffddd80Usage:|r /dps {lock|unlock|show|hide|config}")
			DPSMate:SendMessage("|c3ffddd80- lock:|r Lock your windows.")
			DPSMate:SendMessage("|c3ffddd80- unlock:|r Unlock your windows.")
			DPSMate:SendMessage("|c3ffddd80- show {name}:|r Show the window with the name {name}.")
			DPSMate:SendMessage("|c3ffddd80- hide {name}:|r Hide the window with the name {name}.")
			DPSMate:SendMessage("|c3ffddd80- config:|r Opens the config menu.")
		end
	end
end

function DPSMate:InitializeFrames()
	if not DPSMate:WindowsExist() then return end
	for k, val in pairs(DPSMateSettings["windows"]) do
		if not getglobal("DPSMate_"..val["name"]) then
			local f=CreateFrame("Frame", "DPSMate_"..val["name"], UIParent, "DPSMate_Statusframe")
			f.Key=k
		end
		local frame = getglobal("DPSMate_"..val["name"])
			
		DPSMate.Options:ToggleDrewDrop(1, DPSMate.DB:GetOptionsTrue(1, k), frame)
		DPSMate.Options:ToggleDrewDrop(2, DPSMate.DB:GetOptionsTrue(2, k), frame)
		
		local head = getglobal("DPSMate_"..val["name"].."_Head")
		head.font = getglobal("DPSMate_"..val["name"].."_Head_Font")
		head.bg = getglobal("DPSMate_"..val["name"].."_Head_Background")
		
		if DPSMateSettings["lock"] then
			getglobal("DPSMate_"..val["name"].."_Resize"):Hide()
		end
		if not val["titlebar"] then
			head:Hide()
		end
		head.bg:SetTexture(DPSMate.Options.statusbars[val["titlebartexture"]])
		head.bg:SetVertexColor(val["titlebarbgcolor"][1], val["titlebarbgcolor"][2], val["titlebarbgcolor"][3])
		head.font:SetFont(DPSMate.Options.fonts[val["titlebarfont"]], val["titlebarfontsize"], DPSMate.Options.fontflags[val["titlebarfontflag"]])
		head:SetHeight(val["titlebarheight"])
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Background"):SetTexture(DPSMate.Options.bgtexture[val["contentbgtexture"]])
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Background"):SetVertexColor(val["contentbgcolor"][1], val["contentbgcolor"][2], val["contentbgcolor"][3])
		frame:SetScale(val["scale"])
		
		-- Styles // Bars
		local child = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child")
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"):SetPoint("TOPLEFT", child, "TOPLEFT")
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"):SetPoint("TOPRIGHT", child, "TOPRIGHT")
		if DPSMateSettings["showtotals"] then
			getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"):SetHeight(val["barheight"])
		else
			getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"):SetHeight(0.00001)
		end
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"):SetStatusBarTexture(DPSMate.Options.statusbars[val["bartexture"]])
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total_BG"):SetTexture(DPSMate.Options.statusbars[val["bartexture"]])
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total_Name"):SetFont(DPSMate.Options.fonts[val["barfont"]], val["barfontsize"], DPSMate.Options.fontflags[val["barfontflag"]])
		getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total_Value"):SetFont(DPSMate.Options.fonts[val["barfont"]], val["barfontsize"], DPSMate.Options.fontflags[val["barfontflag"]])
		for i=1, 30 do
			local bar = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i)
			bar.name = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i.."_Name")
			bar.value = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i.."_Value")
			bar.icon = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i.."_Icon")
			bar.bg = getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i.."_BG")
			
			-- Postition
			bar:SetPoint("TOPLEFT", child, "TOPLEFT")
			bar:SetPoint("TOPRIGHT", child, "TOPRIGHT")
			if i>1 then
				bar:SetPoint("TOPLEFT", getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..(i-1)), "BOTTOMLEFT", 0, -1*val["barspacing"])
			else
				if DPSMateSettings["showtotals"] then
					bar:SetPoint("TOPLEFT", getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"), "BOTTOMLEFT", 0, -1*val["barspacing"])
				else
					bar:SetPoint("TOPLEFT", getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_Total"), "BOTTOMLEFT", 0, -1)
				end
			end
			if val["classicons"] then
				bar.name:ClearAllPoints()
				bar.name:SetPoint("TOPLEFT", bar, "TOPLEFT", val["barheight"], 0)
				bar.name:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
				bar.icon:SetWidth(val["barheight"])
				bar.icon:SetHeight(val["barheight"])
				bar.icon:Show()
			end
		
			-- Styles
			bar.name:SetFont(DPSMate.Options.fonts[val["barfont"]], val["barfontsize"], DPSMate.Options.fontflags[val["barfontflag"]])
			bar.value:SetFont(DPSMate.Options.fonts[val["barfont"]], val["barfontsize"], DPSMate.Options.fontflags[val["barfontflag"]])
			bar:SetStatusBarTexture(DPSMate.Options.statusbars[val["bartexture"]])
			bar.bg:SetTexture(DPSMate.Options.statusbars[val["bartexture"]])
			bar:SetHeight(val["barheight"])
		end
	end
	DPSMate.Options:ToggleTitleBarButtonState()
	DPSMate.Options:HideWhenSolo()
end

function DPSMate:WindowsExist()
	if (DPSMate:TableLength(DPSMateSettings.windows)==0) then
		return false
	end
	return true
end

function DPSMate:TMax(t)
	local max = 0
	for _,val in pairs(t) do
		if val>max then
			max=val
		end
	end
	return max
end

function DPSMate:TableLength(t)
	local count = 0
	if (t) then
		for _,_ in pairs(t) do
			count = count + 1
		end
	end
	return count
end

function DPSMate:TContains(t, value)
	if (t) then
		for cat, val in pairs(t) do
			if val == value or cat==value then
				return true
			end
		end
	end
	return false
end

function DPSMate:GetKeyByVal(t, value)
	for cat, val in pairs(t) do
		if val == value then
			return cat
		end
	end
end

function DPSMate:GetKeyByValInTT(t, x, y)
	for cat, val in pairs(t) do
		if (type(val) == "table") then
			if (x==val[y]) then
				return cat
			end
		end
	end
end

function DPSMate:InvertTable(t)
	local s={}
	for cat, val in pairs(t) do
		s[val]=cat
	end
	return s
end

function DPSMate:CopyTable(t)
	local s={}
	for cat, val in pairs(t) do
		s[cat] = val
	end
	return s
end

function DPSMate:GetUserById(id)
	for cat, val in pairs(DPSMateUser) do
		if val["id"] == id then
			return cat
		end
	end
end

-- Maybe inefficient?
-- Sorting it so that player is shown even if just the pet has done dmg
function DPSMate:GetSortedTable(arr)
	local b, a = {}, {}
	local total = 0
	if arr then
		for cat, val in pairs(arr) do
			local name = DPSMate:GetUserById(cat)
			if (not DPSMateUser[name]["isPet"]) then
				local CV = val["info"][3]
				if DPSMate:PlayerExist(DPSMateUser, DPSMateUser[name]["pet"]) and arr[DPSMateUser[DPSMateUser[name]["pet"]]["id"]] then
					CV=CV+arr[DPSMateUser[DPSMateUser[name]["pet"]]["id"]]["info"][3]
				end
				a[CV] = name
				local i = 1
				while true do
					if (not b[i]) then
						table.insert(b, i, CV)
						break
					else
						if b[i] < CV then
							table.insert(b, i, CV)
							break
						end
					end
					i=i+1
				end
				total = total + CV
			end
		end
	end
	return b, total, a
end

function DPSMate:GetSortedDTTable(arr)
	local b, a = {}, {}
	local total = 0
	if arr then
		for c, v in pairs(arr) do
			local CV = 0
			for cat, val in pairs(v) do
				CV = CV+val["info"][3]
			end
			a[CV] = c
			local i = 1
			while true do
				if (not b[i]) then
					table.insert(b, i, CV)
					break
				else
					if b[i] < CV then
						table.insert(b, i, CV)
						break
					end
				end
				i=i+1
			end
			total = total + CV
		end
	end
	return b, total, a
end

function DPSMate:GetSortedHealingTable(arr)
	local b, a, total = {}, {}, 0
	if arr then
		for c, v in pairs(arr) do
			a[v["info"][1]] = c
			local i = 1
			while true do
				if (not b[i]) then
					table.insert(b, i, v["info"][1])
					break
				else
					if b[i] < v["info"][1] then
						table.insert(b, i, v["info"][1])
						break
					end
				end
				i=i+1
			end
			total = total + v["info"][1]
		end
	end
	return b, total, a
end

function DPSMate:GetSortedAbsorbsTable(arr)
	local b, a, total = {}, {}, 0
	local temp = {}
	if arr then
		for cat, val in pairs(arr) do -- 28 Target
			local PerPlayerAbsorb = 0
			for ca, va in pairs(val) do -- 28 Owner
				local PerOwnerAbsorb = 0
				for c, v in pairs(va) do -- Power Word: Shield
					local PerAbilityAbsorb = 0
					for ce, ve in pairs(v) do -- 1
						local PerShieldAbsorb = 0
						for cet, vel in pairs(ve) do
							PerShieldAbsorb=PerShieldAbsorb+vel[2]*5
						end
						if ve["info"][1]==1 then
							PerShieldAbsorb=PerShieldAbsorb+ve["info"][2]
						end
						PerAbilityAbsorb = PerAbilityAbsorb+PerShieldAbsorb
					end
					PerOwnerAbsorb = PerOwnerAbsorb+PerAbilityAbsorb
				end
				if not temp[ca] then temp[ca] = PerOwnerAbsorb else temp[ca]=temp[ca]+PerOwnerAbsorb end
				PerPlayerAbsorb = PerPlayerAbsorb+PerOwnerAbsorb
			end
			total = total+PerPlayerAbsorb
		end
		for cat, val in pairs(temp) do
			a[val] = cat
			local i = 1
			while true do
				if (not b[i]) then
					table.insert(b, i, val)
					break
				else
					if b[i] < val then
						table.insert(b, i, val)
						break
					end
				end
				i=i+1
			end
		end
	end
	return b, total, a
end

function DPSMate:GetSortedAbsorbedTable(arr)
	local b, a, total = {}, {}, 0
	local temp = {}
	if arr then
		for cat, val in pairs(arr) do -- 28 Target
			local PerPlayerAbsorb = 0
			for ca, va in pairs(val) do -- 28 Owner
				local PerOwnerAbsorb = 0
				for c, v in pairs(va) do -- Power Word: Shield
					local PerAbilityAbsorb = 0
					for ce, ve in pairs(v) do -- 1
						local PerShieldAbsorb = 0
						for cet, vel in pairs(ve) do
							PerShieldAbsorb=PerShieldAbsorb+vel[2]*5
						end
						if ve["info"][1]==1 then
							PerShieldAbsorb=PerShieldAbsorb+ve["info"][2]
						end
						PerAbilityAbsorb = PerAbilityAbsorb+PerShieldAbsorb
					end
					PerOwnerAbsorb = PerOwnerAbsorb+PerAbilityAbsorb
				end
				PerPlayerAbsorb = PerPlayerAbsorb+PerOwnerAbsorb
			end
			total = total+PerPlayerAbsorb
			a[PerPlayerAbsorb] = cat
			local i = 1
			while true do
				if (not b[i]) then
					table.insert(b, i, PerPlayerAbsorb)
					break
				else
					if b[i] < PerPlayerAbsorb then
						table.insert(b, i, PerPlayerAbsorb)
						break
					end
				end
				i=i+1
			end
		end
	end
	return b, total, a
end

function DPSMate:PlayerExist(arr, name)
	for cat, val in pairs(arr) do
		if (cat == name) then
			return true
		end
	end
	return false
end

function DPSMate:SetStatusBarValue()
	if not DPSMate:WindowsExist() then return end
	DPSMate:HideStatusBars()
	for k,c in pairs(DPSMateSettings.windows) do
		local arr, cbt = DPSMate:GetMode(k)
		local user, val, perc, strt = DPSMate:GetSettingValues(arr,cbt,k)
		if DPSMateSettings["showtotals"] then
			getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_Total_Name"):SetText("Total")
			getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_Total_Value"):SetText(strt[1]..strt[2])
		end
		if (user[1]) then
			for i=1, 30 do
				if (not user[i]) then break end -- To prevent visual issues
				local statusbar, name, value, texture, p = getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_StatusBar"..i), getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_StatusBar"..i.."_Name"), getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_StatusBar"..i.."_Value"), getglobal("DPSMate_"..c["name"].."_ScrollFrame_Child_StatusBar"..i.."_Icon"), ""
				
				local r,g,b, img = DPSMate:GetClassColor(user[i])
				statusbar:SetStatusBarColor(r,g,b, 1)
				
				if c["ranks"] then p=i..". " else p="" end
				name:SetText(p..user[i])
				value:SetText(val[i])
				texture:SetTexture("Interface\\AddOns\\DPSMate\\images\\class\\"..img)
				statusbar:SetValue(perc[i])
				
				statusbar.user = user[i]
				statusbar:Show()
			end
		end
	end
end

function DPSMate:FormatNumbers(dmg,total,sort,k)
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then
		dmg = string.format("%.1f", (dmg/1000))
		total = string.format("%.1f", (total/1000))
		sort = string.format("%.1f", (sort/1000))
	end
	return dmg, total, sort
end

-- Needs improvement
function DPSMate:GetSettingValues(arr, cbt, k)
	local name, value, perc, sortedTable, total, a, p, strt = {}, {}, {}, {}, 0, 0, "", {[1]="",[2]=""}
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then p = "K" end
	if (DPSMateSettings["windows"][k]["CurMode"] == "dps") then
		sortedTable, total, a = DPSMate:GetSortedTable(arr)
		for cat, val in pairs(sortedTable) do
			local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			if dmg==0 then break end
			local str = {[1]="",[2]="",[3]=""}
			if DPSMateSettings["columnsdps"][1] then str[1] = "("..dmg..p..")"; strt[1] = "("..tot..p..")" end
			if DPSMateSettings["columnsdps"][2] then str[2] = " "..string.format("%.1f", (dmg/cbt))..p; strt[2] = " "..string.format("%.1f", (tot/cbt))..p end
			if DPSMateSettings["columnsdps"][3] then str[3] = " ("..string.format("%.1f", 100*dmg/tot).."%)" end
			table.insert(name, a[val])
			table.insert(value, str[1]..str[2]..str[3])
			table.insert(perc, 100*(dmg/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "damage") then
		sortedTable, total, a = DPSMate:GetSortedTable(arr)
		for cat, val in pairs(sortedTable) do
			local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			if dmg==0 then break end
			local str = {[1]="",[2]="",[3]=""}
			if DPSMateSettings["columnsdmg"][1] then str[1] = " "..dmg..p; strt[2] = tot..p end
			if DPSMateSettings["columnsdmg"][2] then str[2] = "("..string.format("%.1f", (dmg/cbt))..p..")"; strt[1] = "("..string.format("%.1f", (tot/cbt))..p..") " end
			if DPSMateSettings["columnsdmg"][3] then str[3] = " ("..string.format("%.1f", 100*dmg/tot).."%)" end
			table.insert(name, a[val])
			table.insert(value, str[2]..str[1]..str[3])
			table.insert(perc, 100*(dmg/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "damagetaken") then
		sortedTable, total, a = DPSMate:GetSortedDTTable(arr)
		for cat, val in pairs(sortedTable) do
			local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			if dmg==0 then break end
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..dmg..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*dmg/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(dmg/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "enemydamagedone") then
		sortedTable, total, a = DPSMate:GetSortedDTTable(arr)
		for cat, val in pairs(sortedTable) do
			local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			if dmg==0 then break end
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..dmg..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*dmg/tot).."%)"
			table.insert(name, a[val])
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(dmg/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "enemydamagetaken") then
		sortedTable, total, a = DPSMate:GetSortedDTTable(arr)
		for cat, val in pairs(sortedTable) do
			local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			if dmg==0 then break end
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..dmg..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*dmg/tot).."%)"
			table.insert(name, a[val])
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(dmg/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "healing") then
		sortedTable, total, a = DPSMate:GetSortedHealingTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "overhealing") then
		sortedTable, total, a = DPSMate:GetSortedHealingTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "effectivehealing") then
		sortedTable, total, a = DPSMate:GetSortedHealingTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "healingtaken") then
		sortedTable, total, a = DPSMate:GetSortedHealingTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "effectivehealingtaken") then
		sortedTable, total, a = DPSMate:GetSortedHealingTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "absorbs") then
		sortedTable, total, a = DPSMate:GetSortedAbsorbsTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "absorbtaken") then
		sortedTable, total, a = DPSMate:GetSortedAbsorbedTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	elseif (DPSMateSettings["windows"][k]["CurMode"] == "healingandabsorbs") then
		sortedTable, total, a = DPSMate:GetSortedAbsorbedTable(arr)
		for cat, val in pairs(sortedTable) do
			local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
			local str = {[1]="",[2]="",[3]=""}
			str[1] = " "..va..p; strt[2] = tot..p
			str[2] = " ("..string.format("%.1f", 100*va/tot).."%)"
			table.insert(name, DPSMate:GetUserById(a[val]))
			table.insert(value, str[1]..str[2])
			table.insert(perc, 100*(va/sort))
		end
	end
	
	return RegistredModules[DPSMateSettings["windows"][k]["CurMode"]]:GetSettingValues(arr, cbt, k)
end

function DPSMate:GetClassColor(class)
	if (class) then
		if DPSMateUser[class] then class = DPSMateUser[class]["class"] end
		if classcolor[class] then
			return classcolor[class].r, classcolor[class].g, classcolor[class].b, class
		else
			return 0.78,0.61,0.43, "Warrior"
		end
	else
		return 0.1,0,0.1, "None"
	end
end

function DPSMate:GetDisplay(k)
	if DPSMateSettings["windows"][k]["CurMode"] == "dps" or DPSMateSettings["windows"][k]["CurMode"] == "damage" then
		return DPSMateDamageDone, "DMGDone"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "damagetaken" then
		return DPSMateDamageTaken, "DMGTaken"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "enemydamagedone" then
		return DPSMateEDD, "EDDone"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "enemydamagetaken" then
		return DPSMateEDT, "EDTaken"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "healing" then
		return DPSMateTHealing, "THealing"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "overhealing" then
		return DPSMateOverhealing, "OHealing"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "effectivehealing" then
		return DPSMateEHealing, "EHealing"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "healingtaken" then
		return DPSMateHealingTaken, "HTaken"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "effectivehealingtaken" then
		return DPSMateEHealingTaken, "EHTaken"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "absorbs" then
		return DPSMateAbsorbs, "Absorbs"
	elseif DPSMateSettings["windows"][k]["CurMode"] == "absorbtaken" then
		return DPSMateAbsorbs, "Absorbs"
	end
end

function DPSMate:GetMode(k)
	local arr, hist = DPSMate:GetDisplay(k)
	local result = {total={arr[1], DPSMateCombatTime["total"]}, currentfight={arr[2], DPSMateCombatTime["current"]}}
	for cat, val in pairs(DPSMateSettings["windows"][k]["options"][2]) do
		if val then
			if strfind(cat, "segment") then
				local num = tonumber(strsub(cat, 8))
				return DPSMateHistory[hist][num], DPSMateCombatTime["segments"][num]
			else
				return result[cat][1], result[cat][2]
			end
		end
	end
end

function DPSMate:GetModeName(k)
	local result = {total="Total", currentfight="Current fight"}
	for cat, val in pairs(DPSMateSettings["windows"][k]["options"][2]) do
		if val then 
			if strfind(cat, "segment") then
				local num = tonumber(strsub(cat, 8))
				return "Segment "..num
			else
				return result[cat]
			end
		end
	end
end

function DPSMate:HideStatusBars()
	for _,val in pairs(DPSMateSettings.windows) do
		for i=1, 30 do
			getglobal("DPSMate_"..val["name"].."_ScrollFrame_Child_StatusBar"..i):Hide()
		end
	end
end

function DPSMate:Disable()
	if DPSMate.Registered then
		for _, event in pairs(DPSMate.Events) do
			DPSMate_Options:UnregisterEvent(event)
		end
		DPSMate.Registered = false
	end
end

function DPSMate:Enable()
	if not DPSMate.Registered then
		for _, event in pairs(DPSMate.Events) do
			DPSMate_Options:RegisterEvent(event)
		end
		DPSMate.Registered = true
	end
end

function DPSMate:SendMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080"..DPSMate.localization.name.."|r: "..msg)
end

function DPSMate:Register(prefix, table)
	RegistredModules[prefix] = table
end