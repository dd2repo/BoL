--[[
	Script: Easy Elo Elise
	Author: DeadDevil2
	v0.1 	Initial release
	v0.2 	Fixed Prodiction
	v0.3 	Added Formswitch KS
	v0.4 	Added Formswitch in Combo
	v0.5 	Changed Formswitch QWE Check
 ______                  ______ _         ______ _ _          
|  ____|                |  ____| |       |  ____| (_)         
| |__   __ _ ___ _   _  | |__  | | ___   | |__  | |_ ___  ___ 
|  __| / _` / __| | | | |  __| | |/ _ \  |  __| | | / __|/ _ \
| |___| (_| \__ \ |_| | | |____| | (_) | | |____| | \__ \  __/
|______\__,_|___/\__, | |______|_|\___/  |______|_|_|___/\___|
                  __/ |                                       
                 |___/ 
 ]]

if myHero.charName ~= "Elise" then
return
end

if not VIP_USER then
    PrintChat(">> VIP Authentication Failed! You are not authorised to run this script. Unloading.<<")
	return
end

if VIP_USER then
	PrintChat(">> VIP Authentication Successful! Loading the VIP Version, please stand by... <<")
end 

require 'Collision'
require 'VPrediction'
require 'SOW'
require 'Prodiction'


local VP = nil
local VIP_User
local version = 0.5
local AUTOUPDATE = true
local SCRIPT_NAME = "EasyEloElise"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"


if FileExist(SOURCELIB_PATH) then
    require("SourceLib")
else
    DONLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

local RequireI = Require("SourceLib")
RequireI:Check()


if AUTOUPDATE then
     SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/dd2repo/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/dd2repo/BoL/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end
-- Thank you to Roach and Bilbao for the support!
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()



--[[
  ____          _                     _ 
 / __ \        | |                   | |
| |  | |_ __   | |     ___   __ _  __| |
| |  | | '_ \  | |    / _ \ / _` |/ _` |
| |__| | | | | | |___| (_) | (_| | (_| |
 \____/|_| |_| |______\___/ \__,_|\__,_|
 ]]

function OnLoad()
	vars()
	menu()
end

function menu()
	m = scriptConfig("Easy Elo Elise", "easyeloelise")

	m:addSubMenu("Combo Manager", "combosettings")
	m.combosettings:addSubMenu("Humanform Combo", "humancombo")
	m.combosettings.humancombo:addParam("useq", "Use Human Q", SCRIPT_PARAM_ONOFF, true) 
	m.combosettings.humancombo:addParam("usew", "Use Human W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.humancombo:addParam("usee", "Use Human E", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addSubMenu("Spiderform Combo", "spidercombo")
	m.combosettings.spidercombo:addParam("useq", "Use Spider Q", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.spidercombo:addParam("usew", "Use Spider W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.spidercombo:addParam("usee", "Use Spider E", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addParam("platzhalter", "", 5, "")
	m.combosettings:addParam("cocooninfo", "--- Formswitch Manager ---", 5, "")
	m.combosettings:addParam("autospider", "Switch to Spider if target is cocooned", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("autohuman", "Switch to Human if QWE on Cooldown", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("platzhalter", "", 5, "")
	m.combosettings:addParam("magetinfo", "--- Meele Magnet ---", 5, "")
	m.combosettings:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("Cinfo", "Only for Spider in meele Range to avoid aa cancel", 5, "")
	m.combosettings:addParam("Cinfo", "Pls check the Thread for further explanation", 5, "")

	m:addSubMenu("Item Manager", "items")
	m.items:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("apitemsinfo", "--- AP Items ---", 5, "")
	m.items:addParam("dfg", "Deathfire Grasp", SCRIPT_PARAM_LIST, 2, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("bft", "Blackfire Torch", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- Hybrid Items ---", 5, "")
	m.items:addParam("hg", "Hextech Gunblade", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Both" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- AD Items ---", 5, "")
	m.items:addParam("yg", "Youmuu's Ghostblade", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("blade", "Blade of the Ruined King", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("cutlass", "Bilgewater Cutlass", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("sod", "Sword of the Divine", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("supportitemsinfo", "--- Support Items ---", 5, "")
	m.items:addParam("fqc", "Frost Queen's Claim", SCRIPT_PARAM_LIST, 1, {"Never", "Spider", "Human", "Always" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- Defensive Items ---", 5, "")
	m.items:addParam("enableautozhonya", "Auto Zhonya's", SCRIPT_PARAM_ONOFF, false)
	m.items:addParam("autozhonya", "Zhonya's if Health under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)

	m:addSubMenu("KS Manager", "ks")
	m.ks:addSubMenu("Spiderform KS", "spiderks")
	m.ks.spiderks:addParam("useq", "Use Spider Q", SCRIPT_PARAM_ONOFF, true)
	m.ks:addSubMenu("Humanform KS", "humanks")
	m.ks.humanks:addParam("useq", "Use Human Q", SCRIPT_PARAM_ONOFF, true)
	m.ks.humanks:addParam("usew", "Use Human W", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("switchks", "Switch Forms to KS", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)


	m:addSubMenu("Jungle Manager", "c")
	m.c:addSubMenu("Spiderform Clear", "spiderc")
	m.c.spiderc:addParam("useq", "Use Spider Q", SCRIPT_PARAM_ONOFF, true)
	m.c.spiderc:addParam("usew", "Use Spider W", SCRIPT_PARAM_ONOFF, true)
	m.c:addSubMenu("Humanform Clear", "humanc")
	m.c.humanc:addParam("useq", "Use Human Q", SCRIPT_PARAM_ONOFF, true)
	m.c.humanc:addParam("usew", "Use Human W", SCRIPT_PARAM_ONOFF, true)

	m:addSubMenu("Draw Manager", "draw")
	m.draw:addSubMenu("Humanform Draw", "hdraw")
	m.draw.hdraw:addParam("drawaa", "Draw Human AA Range", SCRIPT_PARAM_ONOFF, true)
	m.draw.hdraw:addParam("drawq", "Draw Human Q Range", SCRIPT_PARAM_ONOFF, true)
	m.draw.hdraw:addParam("draww", "Draw Human W Range", SCRIPT_PARAM_ONOFF, true)
	m.draw.hdraw:addParam("drawe", "Draw Human E Range", SCRIPT_PARAM_ONOFF, true)
	m.draw:addSubMenu("Spiderform Draw", "sdraw")
	m.draw.sdraw:addParam("drawq", "Draw Spider Q Range", SCRIPT_PARAM_ONOFF, true)
	m.draw.sdraw:addParam("draww", "Draw Spider W Range", SCRIPT_PARAM_ONOFF, true)
	m.draw.sdraw:addParam("drawe", "Draw Spider E Range", SCRIPT_PARAM_ONOFF, true)


	m:addSubMenu("VIP Menu", "vip")
	m.vip:addParam("pretype", "--- Prediction Type ---", 5, "")
	m.vip:addParam("prediction", "Choose Prediction", SCRIPT_PARAM_LIST, 2, {"Vprediction", "Prodiction" })
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hitchance", "Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	m.vip:addParam("hitinfo", "1=low 2=high 3=slowed 4=stunned/rooted", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("pretype", "--- Lag Free Circles ---", 5, "")
	m.vip:addParam("LagFree", "Activate Lag Free Circles", 1, true)
	m.vip:addParam("CL", "Length before snapping", 4, 75, 75, 2000, 0)
	m.vip:addParam("CLinfo", "The lower your length the better system you need", 5, "")

	ts.name = "Elise"
	m:addSubMenu("Orbwalker", "orbwalk")
	sow:LoadToMenu(m.orbwalk)
	m:addTS(ts)

	m:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	m:addParam("junglekey", "Jungle Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))

	PrintChat ("<font color='#009AFF'>Easy Elo Elise v0.5 by DeadDevil2 Loaded! </font>")
end


function vars()
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,0)
	VP = VPrediction()

	Qready = false
	Wready = false
	Eready = false
	Rready = false

	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2

	spiderform = false
	EliseSpiderW = false

	sow = SOW(VP)
	sow:RegisterOnAttackCallback(CastSpiderW)
	jungleMinions = minionManager(MINION_JUNGLE, 1000, myHero, MINION_SORT_MAXHEALTH_DEC)

	Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
end

--[[
  ____          _______ _      _    
 / __ \        |__   __(_)    | |   
| |  | |_ __      | |   _  ___| | __
| |  | | '_ \     | |  | |/ __| |/ /
| |__| | | | |    | |  | | (__|   < 
 \____/|_| |_|    |_|  |_|\___|_|\_\
]]                                    
function OnTick()
	jungleMinions:update()
	ts:update()
	target = ts.target
	checks()
	range()
	combo()
	coconbuff()
	targetmagnet()
	autozhonya()
	Items()
	LFC()
	Cocoonedcheck()
	Killsteal()
	JungleClear()
end

function checks()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
end

function targetmagnet()
    if m.combokey and Spiderform and target and m.combosettings.magnet then
	local dist = GetDistanceSqr(target)
	if dist < 250^2 and dist > 80^2 then 
		stayclose(target, true)
	elseif dist <= 80^2 then
		stayclose(target, false)
	end
    end
end

function stayclose(unit, mode)
	if mode then
		local myVector = Vector(myHero.x, myHero.y, myHero.z)
		local targetVector = Vector(unit.x, unit.y, unit.z)
		local orbwalkPoint1 = targetVector + (myVector-targetVector):normalized()*100
		local orbwalkPoint2 = targetVector - (myVector-targetVector):normalized()*100
		if GetDistanceSqr(orbwalkPoint1) < GetDistanceSqr(orbwalkPoint2) then
			sow:OrbWalk(unit, orbwalkPoint1)
		else
			sow:OrbWalk(unit, orbwalkPoint2)
		end
	else
		sow:OrbWalk(unit, myHero)
	end
end

function LFC()
	if not m.vip.LagFree then _G.DrawCircle = _G.oldDrawCircle end
	if m.vip.LagFree then
		_G.DrawCircle = DrawCircle2
	end
end

function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then
			CastSpell(Ignite, enemy)
		end
		if Spiderform then
			if m.ks.spiderks.useq and ValidTarget(enemy, 475) then
				local QMDmg = getDmg('QM', enemy, myHero) or 0
				if Qready and enemy.health <= QMDmg then
					CastSpell(_Q, enemy)
				end
			end
			if m.ks.switchks and m.ks.humanks.usew and m.ks.humanks.useq then
				local QDmg = getDmg('Q', enemy, myHero) or 0
				local WDmg = getDmg('W', enemy, myHero) or 0
				if not Qready and (enemy.health <= QDmg or enemy.health <= WDmg) and ValidTarget(enemy, 625) then
					CastSpell(_R)
				end
			end
		else
			if m.ks.humanks.useq and ValidTarget(enemy, 625) then
				local QDmg = getDmg('Q', enemy, myHero) or 0
				if Qready and enemy.health <= QDmg then
					CastSpell(_Q, enemy)
				end
			end
			if m.ks.humanks.usew and ValidTarget(enemy, 750) then
				local WDmg = getDmg('W', enemy, myHero) or 0
				if Wready and enemy.health <= WDmg then
					CastSpell(_W, enemy.x, enemy.z)
				end
			end
			if m.ks.humanks.usew and m.ks.humanks.useq and ValidTarget(enemy, 625) then
				local QDmg = getDmg('Q', enemy, myHero) or 0
				local WDmg = getDmg('W', enemy, myHero) or 0
				if Wready and Qready and enemy.health <= (WDmg+QDmg) then
					CastSpell(_W, enemy.x, enemy.z)
					CastSpell(_Q, enemy)
				end
			end
			if m.ks.switchks and m.ks.spiderks.useq then
				if not Qready and not Wready and not Spiderform then
					local QMDmg = getDmg('QM', enemy, myHero) or 0
					if ValidTarget(enemy, 475) and enemy.health <= QMDmg then
						CastSpell(_R)
					end
				end
			end
		end
	end	
end


function range()
	ts:update()
	if Spiderform then
		ts.range = 975
	else
	    ts.range = 1075
	end
end

function autozhonya()
	if m.items.enableautozhonya then
		if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157)
		end
	end
end

function CastSpiderW()
if m.combokey and m.combosettings.spidercombo.usew and Wready and target and ValidTarget(target, 200) and Spiderform then CastSpell(_W) end
end

function combo()
	if not target then 
		return 
	end
	if m.combokey then
		if Spiderform then 
			if m.combosettings.spidercombo.useq and Qready and target and ValidTarget(target) and GetDistance(target) < 475 then
				CastSpell(_Q, target)
			end
			if not usingE then
				if m.combosettings.spidercombo.usee and Eready and target and ValidTarget(target, 975) and GetDistance(target) > 475 then
					CastSpell(_E)
				end
			end
			if Eready and target and ValidTarget(target, 975) and usingE then
				CastSpell(_E, target)
			end
			if not Eready and not Qready and not Wready and not usingW and Rready and GetDistance(target) > 300 then
				CastSpell(_R)
			end
		else
			if m.combosettings.humancombo.useq and Qready and target and ValidTarget(target) and GetDistance(target) < 625 then
				CastSpell(_Q, target)
			end
			if m.combosettings.humancombo.usew and Wready and target and ValidTarget(target) and GetDistance(target) < 750 then
				CastSpell(_W, target.x, target.z)
			end
			if m.combosettings.humancombo.usee and Eready and target and ValidTarget(target) and GetDistance(target) < 1075 then
				if m.vip.prediction == 1 then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 70, 1075, 1450, myHero, true)
					if HitChance >= m.vip.hitchance then
						CastSpell(_E, CastPosition.x, CastPosition.z)
					end
				end
				if m.vip.prediction == 2 then
					local pos, info = Prodiction.GetPrediction(target, 1075, 1450, 0.5, 70, myHero)
					local coll = Collision(1075, 1450, 0.5, 70)
					if not coll:GetMinionCollision(pos, myHero) then
						if pos then
							  CastSpell(_E, pos.x, pos.z)
						end
					end
				end
			end
		end
	end
end

function Items()
	if not target then 
		return 
	end
	if m.combokey and m.items.useitems then 
		if Spiderform then
			---- ITEMS
				if m.items.dfg == 2 then CastItem(3128, target) end
				if m.items.dfg == 4 then CastItem(3128, target) end
				if m.items.hg == 2 then CastItem(3146, target) end
				if m.items.hg == 4 then CastItem(3146, target) end
				if m.items.yg == 2 then CastItem(3142) end
				if m.items.yg == 4 then CastItem(3142) end
				if m.items.blade == 2 then CastItem(3153, target) end
				if m.items.blade == 4 then CastItem(3153, target) end
				if m.items.cutlass == 2 then CastItem(3144, target) end
				if m.items.cutlass == 4 then CastItem(3144, target) end
				if m.items.sod == 2 then CastItem(3131) end
				if m.items.sod == 4 then CastItem(3131) end
				if m.items.fqc == 2 then CastItem(3092, target.x,target.z) end
				if m.items.fqc == 4 then CastItem(3092, target.x,target.z) end
				if m.items.bft == 2 then CastItem(3188, target) end
				if m.items.bft == 4 then CastItem(3188, target) end
		elseif ValidTarget(target, 550) then
				if m.items.dfg == 3 then CastItem(3128, target) end
				if m.items.dfg == 4 then CastItem(3128, target) end
				if m.items.hg == 3 then CastItem(3146, target) end
				if m.items.hg == 4 then CastItem(3146, target) end
				if m.items.yg == 3 then CastItem(3142) end
				if m.items.yg == 4 then CastItem(3142) end
				if m.items.blade == 3 then CastItem(3153, target) end
				if m.items.blade == 4 then CastItem(3153, target) end
				if m.items.cutlass == 3 then CastItem(3144, target) end
				if m.items.cutlass == 4 then CastItem(3144, target) end
				if m.items.sod == 3 then CastItem(3131) end
				if m.items.sod == 4 then CastItem(3131) end
				if m.items.fqc == 3 then CastItem(3092, target.x,target.z) end
				if m.items.fqc == 4 then CastItem(3092, target.x,target.z) end
				if m.items.bft == 3 then CastItem(3188, target) end
				if m.items.bft == 4 then CastItem(3188, target) end
		end
	end
end
		
function JungleClear()
	for i, jungleMinion in pairs(jungleMinions.objects) do
		if jungleMinion ~= nil then
			if m.junglekey then
				if Spiderform then 
					if Qready and m.c.spiderc.useq and ValidTarget(jungleMinion, 475) then
						CastSpell(_Q, jungleMinion)
						
					end
					if Wready and m.c.spiderc.usew and ValidTarget(jungleMinion, 300) then
						CastSpell(_W)
						
					end
				else
					if Qready and m.c.humanc.useq and ValidTarget(jungleMinion, 625) then
						CastSpell(_Q, jungleMinion)
						
					end	
					if Wready and m.c.humanc.usew and ValidTarget(jungleMinion, 950) then
						CastSpell(_W, jungleMinion.x, jungleMinion.z)
						
					end
				end
			end
		end
	end
end

--[[
 _____              _              _____ _               _        
|  __ \            (_)            / ____| |             | |       
| |__) |_ _ ___ ___ ___   _____  | |    | |__   ___  ___| | _____ 
|  ___/ _` / __/ __| \ \ / / _ \ | |    | '_ \ / _ \/ __| |/ / __|
| |  | (_| \__ \__ \ |\ V /  __/ | |____| | | |  __/ (__|   <\__ \
|_|   \__,_|___/___/_| \_/ \___|  \_____|_| |_|\___|\___|_|\_\___/
]]

function OnGainBuff(unit, buff) 
    if buff.name == 'EliseR' and unit.isMe then
    	Spiderform = true
    end
    if buff.name == 'elisespidere' and unit.isMe then
    	usingE = true
    end
    if buff.name == 'EliseSpiderW' and unit.isMe then
    	usingW = true
    end
    if buff.name == 'elisespiderw' and unit.isMe then
    	usingW = true
    end
end

function OnLoseBuff(unit, buff)
    if buff.name == 'EliseR' and unit.isMe then
        Spiderform = false
    end
   	if buff.name == 'elisespidere' and unit.isMe then
        usingE = false
    end
    if buff.name == 'EliseSpiderW' and unit.isMe then
    	usingW = false
    end
    if buff.name == 'elisespiderw' and unit.isMe then
    	usingW = false
    end
end

function coconbuff(unit)
	return TargetHaveBuff('EliseHumanE', unit)
end

function Cocoonedcheck()
	if spiderform then return end
	if not Spiderform then
		if m.combosettings.autospider and m.combokey and target and ValidTarget(target, 800) and coconbuff(target) and Rready then
			CastSpell(_R)
		end	
	end
end
	

--[[
  ____          _____                     
 / __ \        |  __ \                    
| |  | |_ __   | |  | |_ __ __ ___      __
| |  | | '_ \  | |  | | '__/ _` \ \ /\ / /
| |__| | | | | | |__| | | | (_| |\ V  V / 
 \____/|_| |_| |_____/|_|  \__,_| \_/\_/  
 ]]


function OnDraw()
	Drawings()
end

function Drawings()
if m.draw.hdraw.drawq and not Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 625, ARGB(255, 255, 255, 255))
end
if m.draw.hdraw.draww and not Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 950, ARGB(255, 255, 255, 255))
end
if m.draw.hdraw.drawe and not Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 1075, ARGB(255, 255, 255, 255))
end
if m.draw.sdraw.drawq and Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 475, ARGB(255, 255, 255, 255))
end
if m.draw.sdraw.drawe and Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 975, ARGB(255, 255, 255, 255)) 
end
if m.draw.hdraw.drawaa and not Spiderform then
	DrawCircle(myHero.x, myHero.y, myHero.z, 550, ARGB(255, 255, 255, 255))
end
end

function round(num) 
    if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end
