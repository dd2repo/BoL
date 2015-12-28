--[[
Scriptname 	= Noscope Nidalee Reborn
Version 	= 2.0
Author		= DeadDevil2

ToDo
- Laneclear & Jungleclear
- Spear KS
]]

if myHero.charName ~= "Nidalee" then
return
end

local ignite = nil
local version = 2.0
local AUTOUPDATE = true
local SX = false
local SAC = false
local SCRIPT_NAME = "NoscopeNidaleeReborn"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local Spells = 	
{
	Q 	= 	{range = 1400, delay = 0.25, width = 37.5, speed = 1325},
	W 	= 	{range = 900, delay = 0.500, width = 80, speed = 1450},
	E 	= 	{range = 600},
	CW 	= 	{range = 375},
	ECW = 	{range = 750},
	CE 	= 	{range = 300}
}

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
    DONLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require 'VPrediction'
else print ("Noscope Nidalee Reborn: You need to download VPrediction. Loading Script failed..") return end
--[[
if VIP_USER and FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac") then
	require 'DivinePred'
	DP = DivinePred()
else print ("You need to download DivinePred. Loading Script failed..") return end
]]
if FileExist(LIB_PATH .. "/HPrediction.lua") then
	require 'HPrediction'
else print ("Noscope Nidalee Reborn: You need to download HPrediction. Loading Script failed..") return end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

local RequireI = Require("SourceLib")
RequireI:Check()

if AUTOUPDATE then
     SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/dd2repo/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/dd2repo/BoL/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end

function OnLoad()
	if _G.Reborn_Loaded ~= nil then
		SAC = true
		print ("Noscope Nidalee Reborn: SAC Reborn detected.")
	else SX = true
		print ("Noscope Nidalee Reborn: SAC cannot be found. Will load SxOrbWalk.")
		if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
			require 'SxOrbWalk'
		else print ("Noscope Nidalee Reborn: You need to download SxOrbWalk. Loading Script failed..") return 
		end
	end
	vars()
	menu()
end

function vars()
	ts 	= TargetSelector(TARGET_LESS_CAST_PRIORITY,0)
	VP 	= VPrediction()
	HPred 	= HPrediction()
	HP_Q = HPSkillshot({type = "DelayLine", delay = Spells.Q.delay, range = Spells.Q.range, speed = Spells.Q.speed, collisionM = true, collisionH = true, width = Spells.Q.width*2, IsVeryLowAccuracy = true})
	hunting = false
	cougar 	= false
	Ignite 	= (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
	if SX then SxOrb:RegisterOnAttackCallback(CastCougarQ) end
    jungleMinions = minionManager(MINION_JUNGLE, 800, myHero, MINION_SORT_MAXHEALTH_DEC)
    enemyMinions = minionManager(MINION_ENEMY, 800, myHero, MINION_SORT_HEALTH_ASC)
end

function menu()
	m = scriptConfig("[Noscope Nidalee Reborn v2.0]", "Noscopenidaleereborn")
	
	m:addSubMenu("NNR - [Key Manager]", "key")
	m.key:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	m.key:addParam("escapekey", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	m.key:addParam("harass", "Toogle Auto Harass with Spears", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
	m.key:addParam("junglekey", "Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))

	m:addSubMenu("NNR - [Combo Manager]", "combosettings")
	m.combosettings:addSubMenu("Humanform Combo", "humancombo")
	m.combosettings.humancombo:addParam("usehq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.humancombo:addParam("usehw", "Use W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addSubMenu("Cougar Combo", "cougarcombo")
	m.combosettings.cougarcombo:addParam("usecq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.cougarcombo:addParam("usecw", "Use W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.cougarcombo:addParam("usece", "Use E", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addParam("platzhalter", "", 5, "")
	m.combosettings:addParam("huntedinfo", "--- Passive Manager ---", 5, "")
	m.combosettings:addParam("autocougar", "Switch to Cougar if target is Hunted", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("Cinfo", "Only switchs if target is in extended Pounce range", 5, "")
	m.combosettings:addParam("platzhalter", "", 5, "")
	
	m:addSubMenu("NNR - [Item Manager]", "items")
	m.items:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- Hybrid Items ---", 5, "")
	m.items:addParam("hg", "Hextech Gunblade", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Both" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- AD Items ---", 5, "")
	m.items:addParam("yg", "Youmuu's Ghostblade", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("blade", "Blade of the Ruined King", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("cutlass", "Bilgewater Cutlass", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("sod", "Sword of the Divine", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("supportitemsinfo", "--- Support Items ---", 5, "")
	m.items:addParam("fqc", "Frost Queen's Claim", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("hybriditemsinfo", "--- Defensive Items ---", 5, "")
	m.items:addParam("enableautozhonya", "Auto Zhonya's", SCRIPT_PARAM_ONOFF, false)
	m.items:addParam("autozhonya", "Zhonya's if Health under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	
	m:addSubMenu("NNR - [Heal Manager]", "healmanager")
	m.healmanager:addParam("healinfo", "--- Self Heal ---", 5, "")
	m.healmanager:addParam("enableheal", "Auto Heal", SCRIPT_PARAM_ONOFF, true)
	m.healmanager:addParam("heal", "Heal if Health under -> %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	m.healmanager:addParam("platzhalter", "", 5, "")
	m.healmanager:addParam("ahealinfo", "--- Ally Heal ---", 5, "")
	m.healmanager:addParam("platzhalter", "SoonTM <3", 5, "")
	m.healmanager:addParam("platzhalter", "", 5, "")
	m.healmanager:addParam("healswitch", "Switch Forms for Heal", SCRIPT_PARAM_ONOFF, false)
	
	m:addSubMenu("NNR - [KS Manager]", "ks")
	m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usecq", "Use Cougar Q", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usecw", "Use Cougar W", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usece", "Use Cougar E", SCRIPT_PARAM_ONOFF, true)

	m:addSubMenu("NNR - [Clear Manager]", "c")

	m.c:addParam("usehq", "Use Spear", SCRIPT_PARAM_ONOFF, false)
	m.c:addParam("usehw", "Use Trap", SCRIPT_PARAM_ONOFF, false)
	m.c:addParam("usecq", "Use Cougar Q", SCRIPT_PARAM_ONOFF, true)
	m.c:addParam("usecw", "Use Cougar W", SCRIPT_PARAM_ONOFF, true)
	m.c:addParam("usece", "Use Cougar E", SCRIPT_PARAM_ONOFF, true)
	m.c:addParam("autocougar", "Switch to Cougar if Creep is Hunted", SCRIPT_PARAM_ONOFF, false)


	m:addSubMenu("NNR - [Misc Manager]", "vip")
	m.vip:addParam("pretype", "--- Spear Prediction ---", 5, "")
	m.vip:addParam("prediction", "Choose Prediction", SCRIPT_PARAM_LIST, 2, {"VPrediction", "HPrediction" })
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hitchance", "Q Hitchance [VPrediction]", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	m.vip:addParam("hitinfo", "1=low 2=high 3=slowed 4=stunned/rooted", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hhitchance", "Q Hitchance [HPrediction]", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
	m.vip:addParam("hitinfo", "1=low 2=mid 3=high", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("pretype", "--- Lag Free Circles ---", 5, "")
	m.vip:addParam("LagFree", "Activate Lag Free Circles", 1, false)
	m.vip:addParam("CL", "Length before snapping", 4, 75, 75, 2000, 0)
	m.vip:addParam("CLinfo", "The lower your length the better system you need", 5, "")
	
	m:addSubMenu("NNR - [Draw Manager]", "draw")
	m.draw:addParam("drawq", "Draw Spear Range", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("drawaa", "Draw AA Range", SCRIPT_PARAM_ONOFF, false)

	if SX == true then
	m:addSubMenu("NNR - [Orbwalk Manager]", "orbwalk")
	SxOrb:LoadToMenu(m.orbwalk)
	else
	m:addSubMenu("[SAC detected. SxOrbWalk disabled!]", "orbwalk")
	end
	m:addTS(ts)
	ts.name = "Noscope"
	PrintChat ("<font color='#FF9A00'>[Noscope Nidalee Reborn v2.0] by dd2 Loaded! </font>")
end

function OnTick()
	ts:update()
	target = ts.target
	checks()
	autoheal()
	combo()
	range()
	autozhonya()
	harass()
	Huntedcheck()
	TargetHunted()
	Items()
	escape()
	Killsteal()
	jungleMinions:update()
	enemyMinions:update()
	JungleClear()
	Clear()
end

function checks()
	if myHero:GetSpellData(_Q).name == "Takedown" or myHero:GetSpellData(_W).name == "Pounce" or myHero:GetSpellData(_E).name == "Swipe" then
		cougar 	= true
		human 	= false
	end
	if myHero:GetSpellData(_Q).name == "JavelinToss" or myHero:GetSpellData(_W).name == "Bushwhack" or myHero:GetSpellData(_E).name == "PrimalSurge" then
		cougar 	= false 
		human 	= true
	end
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function escape()
	if m.key.escapekey then
			myHero:MoveTo(mousePos.x, mousePos.z)
		if cougar then
			if Wready then
				CastSpell(_W, mousePos.x, mousePos.z)
			end
		elseif Rready then
			CastSpell(_R)
		end
	end
end

function Clear()
	if m.key.junglekey then
		local minion300, health300 = nil, 0
		local minion375, health375 = nil, 0
		local minion900, health900 = nil, 0
		local minion1500, health1500 = nil, 0
		for i, enemyMinion in pairs(enemyMinions.objects) do
			if ValidTarget(enemyMinion) then
				local distance = GetDistanceSqr(enemyMinion)
				if distance < 1500 * 1500 then
					if enemyMinion.health > health375 then
						minion375, health375 = enemyMinion, enemyMinion.health
					end
					if distance < 300 * 300 then
						if enemyMinion.health > health300 then
							minion300, health300 = enemyMinion, enemyMinion.health
						end
					end
					if distance < 900 * 900 then
						if enemyMinion.health > health900 then
							minion900, health900 = enemyMinion, enemyMinion.health
						end
					end
					if distance < 1500 * 1500  then
						if enemyMinion.health > health1500 then
							minion1500, health1500  = enemyMinion, enemyMinion.health
						end
					end
				end
			end
		end
		if cougar then
			if minion300 then
				if Qready and m.c.usecq then
					CastSpell(_Q) 
				end
			end
			if minion375 then
				if Wready and m.c.usecw then
					CastSpell(_W, minion375 .x, minion375 .z)
				end 
				if Eready and m.c.usece then
					CastSpell(_E, minion375 .x, minion375 .z)
				end 
			end
		else
			if minion1500 then
				if Qready and m.c.usehq then
					CastSpell(_Q, minion1500 .x, minion1500 .z)
				end
			end
			if minion900 then
				if Wready and m.c.usecw then
					CastSpell(_W, minion900 .x, minion900 .z)
				end 
			end
		end
	end
end

function JungleClear()
	if m.key.junglekey then
		local minion300, health300 = nil, 0
		local minion375, health375 = nil, 0
		local minion900, health900 = nil, 0
		local minion1500, health1500 = nil, 0
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if ValidTarget(jungleMinion) then
				local distance = GetDistanceSqr(jungleMinion)
				if distance < 1500 * 1500 then
					if jungleMinion.health > health375 then
						minion375, health375 = jungleMinion, jungleMinion.health
					end
					if distance < 300 * 300 then
						if jungleMinion.health > health300 then
							minion300, health300 = jungleMinion, jungleMinion.health
						end
					end
					if distance < 900 * 900 then
						if jungleMinion.health > health900 then
							minion900, health900 = jungleMinion, jungleMinion.health
						end
					end
					if distance < 1500 * 1500  then
						if jungleMinion.health > health1500 then
							minion1500, health1500  = jungleMinion, jungleMinion.health
						end
					end
				end
			end
			if TargetHunted(jungleMinion) and (objhunt1 or objhunt2 or objhunt3) and ValidTarget(jungleMinion, 680) and Wready and cougar then
				CastSpell(_W, jungleMinion.x, jungleMinion.z)
			elseif
				TargetHunted(jungleMinion) and (objhunt1 or objhunt2 or objhunt3) and ValidTarget(jungleMinion, 680) and Rready and human then
				CastSpell(_R)
			end
		end
		if cougar then
			if minion300 then
				if Qready and m.c.usecq then
					CastSpell(_Q) 
				end
			end
			if minion375 then
				if Wready and m.c.usecw then
					CastSpell(_W, minion375 .x, minion375 .z)
				end 
				if Eready and m.c.usece then
					CastSpell(_E, minion375 .x, minion375 .z)
				end 
			end
		else
			if minion1500 then
				if Qready and m.c.usehq then
					CastSpell(_Q, minion1500 .x, minion1500 .z)
				end
			end
			if minion900 then
				if Wready and m.combosettings.humancombo.usehw then
					CastSpell(_W, minion900 .x, minion900 .z)
				end 
			end
		end
	end
end

--[[
function OnApplyBuff(unit, buff)
    if buff.name == 'nidaleepassivehunting' and unit.isMe then
    	hunting = true
    end
end

function OnRemoveBuff(unit, buff)
    if buff.name == 'nidaleepassivehunting' and unit.isMe then
        hunting = false
    end
end
]]

function OnIssueOrder(source, order, position, target)
	if SAC == true then
		if _G.AutoCarry.Keys.AutoCarry and source.isMe and order == 3 then -- 2 = move, 3 = attack
			if GetDistance(position) - target.boundingRadius < myHero.range + myHero.boundingRadius then -- Check that they are in our AA range
				CastSpell(_Q) -- This will cast before the "order" is actually sent to the server
			end
		end
	else
		return
	end
end

function OnCreateObj(object)
    if object.name == 'Nidalee_Base_Q_Tar.troy' then
        objhunt1 = true
    end
    if object.name == 'Nidalee_Base_Q_Buf.troy' then
        objhunt2 = true
    end
    if object.name == 'Nidalee_Base_P_Buf.troy' then
        objhunt3 = true
    end
end

function OnDeleteObj(object)
    if object.name == 'Nidalee_Base_Q_Tar.troy' then
        objhunt1 = false
    end
    if object.name == 'Nidalee_Base_Q_Buf.troy' then
        objhunt2 = false
    end
    if object.name == 'Nidalee_Base_P_Buf.troy' then
        objhunt3 = false
    end
end

function TargetHunted(unit)
 return TargetHaveBuff('nidaleepassivehunted', unit)
end

function Huntedcheck()
	if TargetHunted(target) and human and (objhunt1 or objhunt2 or objhunt3) then
		if m.combosettings.autocougar and m.key.combokey and target and ValidTarget(target, 650) and Rready then
			CastSpell(_R)
		end	
	else
	return
	end
end

function Huntedcheck()
	if TargetHunted(target) and human and (objhunt1 or objhunt2 or objhunt3) then
		if m.combosettings.autocougar and m.key.combokey and target and ValidTarget(target, 650) and Rready then
			CastSpell(_R)
		end	
	else
	return
	end
end

function range()
	ts:update()
	if cougar then
		ts.range = 700
	else
	    ts.range = 1500
	end
end

function autoheal()
	if not cougar then
		if m.healmanager.enableheal and Eready and myHero.health <= (myHero.maxHealth * m.healmanager.heal / 100) then
			CastSpell(_E)
		end
	elseif Rready and m.healmanager.healswitch and m.healmanager.enableheal and myHero.health <= (myHero.maxHealth * m.healmanager.heal / 100) then
		CastSpell(_R)
	end
end

function autozhonya()
	if m.items.enableautozhonya then
		if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157)
		end
	end
end

-- Cast Function --
function CastCougarQ()
	if m.key.combokey and Qready and m.combosettings.cougarcombo.usecq and target and ValidTarget(target) then 
		CastSpell(_Q)
	end 
end

-- VPrediction Q Cast --
function CastVQ(unit)
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, Spells.Q.delay, Spells.Q.width, Spells.Q.range, Spells.Q.speed, myHero, true)
	if HitChance >= m.vip.hitchance then
  		CastSpell(_Q, CastPosition.x, CastPosition.z)
  	end
end

-- HPrediction Q Cast --
function CastHQ(unit)
	local QPos, QHitChance = HPred:GetPredict(HP_Q, unit, myHero)
	if QHitChance >= m.vip.hhitchance then
		CastSpell(_Q, QPos.x, QPos.z)
	end
end

-- HPrediction E Cast --
function CastHE(unit)
	local QPos, QHitChance = HPred:GetPredict("HP_E", unit, myHero)
	if QHitChance >= 2 then
		CastSpell(_E, EPos.x, EPos.z)
	end
end

function combo()
	if not target then return end
	if m.key.combokey then
		-- cougar --
		if cougar then
			if Eready and target and GetDistance(target) < Spells.CE.range and m.combosettings.cougarcombo.usece then
				--CastHE(target)
				CastSpell(_E, target.x, target.z)
			end
			if Wready and target and ValidTarget(target) and GetDistance(target) > 160 and m.combosettings.cougarcombo.usecw then
				CastSpell(_W, target.x, target.z)
			end
		-- Human --
		else
			if Qready and ValidTarget(target, 1400) and target and GetDistance(target) <= 1400 and m.combosettings.humancombo.usehq then
				if m.vip.prediction == 1 then
					CastVQ(target)
				elseif m.vip.prediction == 2 then
					CastHQ(target)
				--elseif VIP_USER and m.vip.prediction == 3 then
				--	CastDQ(target)
				end
			end
			if Wready and ValidTarget(target, 650) and target and GetDistance(target) <= 650 and m.combosettings.humancombo.usehw then
				CastSpell(_W, target.x, target.z)
			end
		end
	end
end

function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
		end
		if cougar and m.ks.usecq and ValidTarget(enemy, 250) then
			local QDmg = getDmg('QM', enemy, myHero) or 0
			if Qready and enemy.health <= QDmg then -- fuck getdmg srsly
				CastSpell(_Q)
				myHero:Attack(enemy)
			end
		end
		if cougar and m.ks.usece and ValidTarget(enemy, 310) then
			local EDmg = getDmg('EM', enemy, myHero) or 0
			if Eready and enemy.health <= EDmg then
				CastSpell(_E, enemy.x, enemy.z)
			end
		end
		if cougar and m.ks.usecw and ValidTarget(enemy, 400) then
			local WDmg = getDmg('WM', enemy, myHero) or 0
			if Wready and enemy.health <= WDmg then
				CastSpell(_W, enemy.x, enemy.z)
			end
		end
	end	
end

function Items()
	if not target then return end
	if m.key.combokey and m.items.useitems then 
		if cougar then
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
		elseif ValidTarget(target, 525) then
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
		end
	end
end

function harass()
	if not target then return end
	if human then
	    if m.key.harass then
			if Qready and ValidTarget(target, 1400) and target and m.key.harass then
				if m.vip.prediction == 1 then
					CastVQ(target)
				else
					CastHQ(target)
				end	
			end
		end
	end
end

function OnDraw()
	Drawings()
end

function Drawings()
	if m.draw.drawq and not cougar then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 1400, 1, ARGB(255, 255, 255, 255))
	end
	if m.draw.drawaa and not cougar then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 550, 1, ARGB(255, 255, 255, 255))
	end
end
