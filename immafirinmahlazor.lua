--[[
Scriptname 	= Imma firin mah lazor
Version 	= 1.5
Author		= dd2

ToDo
- Laneclear & Jungleclear
- DivinePrediction Integration
]]

if myHero.charName ~= "Lux" then return end

local ignite = nil
local version = 1.5
local AUTOUPDATE = true
local SX = false
local SAC = false
local recalling = false
local targetbinded = false
local targetsaa = false
local myheroignited = false
local ignited = false
local SCRIPT_NAME = "immafirinmahlazor"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local Spells = {
		Q = {range = 1300, delay = 0.25, speed = 1200, width = 80},
		W = {range = 1175, delay = 0.25, speed = 1400, width = 110},
		E = {range = 1100, delay = 0.25, speed = 1300,  width = 275},
		R = {range = 3340, delay = 1.35, speed = math.huge, width = 190}
	}

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
    DONLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require 'VPrediction'
else print ("Imma firin mah lazor: You need to download VPrediction. Loading Script failed..") return end

if FileExist(LIB_PATH .. "/HPrediction.lua") then
	require 'HPrediction'
else print ("Imma firin mah lazor: You need to download HPrediction. Loading Script failed..") return end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

local RequireI = Require("SourceLib")
RequireI:Check()

if AUTOUPDATE then
     SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/dd2repo/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/dd2repo/BoL/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end

function OnLoad()
	if _G.Reborn_Loaded ~= nil then
		SAC = true
		print ("Imma firin mah lazor: SAC Reborn detected.")
	else SX = true
		print ("Imma firin mah lazor: SAC cannot be found. Will load SxOrbWalk.")
		if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
			require 'SxOrbWalk'
		else print ("Imma firin mah lazor: You need to download SxOrbWalk. Loading Script failed..") return 
		end
	end
	vars()
	menu()
end

function vars()
	ts 	= TargetSelector(TARGET_LESS_CAST_PRIORITY,1300)
	VP 	= VPrediction()
	HPred 	= HPrediction()
	HP_Q = HPSkillshot({collisionM = true, collisionH = false, delay = Spells.Q.delay, range = Spells.Q.range, speed = Spells.Q.speed, type = "DelayLine", width = Spells.Q.width*2, IsLowAccuracy = true})
	Ignite 	= (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
end

function menu()
	m = scriptConfig("[Imma firin mah lazor v1.1]", "ifml")
	
	m:addSubMenu("IFML - [Key Manager]", "key")
	m.key:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)

	m:addSubMenu("IFML - [Combo Manager]", "combo")
	m.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
	m.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
	m.combo:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
	m.combo:addParam("rmode", "R Mode", SCRIPT_PARAM_LIST, 2, {"Binded", "Binded+Kill", "Kill", "Always" })
	m.combo:addParam("procp", "Try to proc passive", SCRIPT_PARAM_ONOFF, true)

	m:addSubMenu("IFML - [Shield Manager]", "shieldmanager")
	m.shieldmanager:addParam("shield", "Auto Shield", SCRIPT_PARAM_ONOFF, true)
	m.shieldmanager:addParam("value", "Shield if Health under -> %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	m.shieldmanager:addParam("shieldoi", "Shield on Ignite", SCRIPT_PARAM_ONOFF, true)

	m:addSubMenu("IFML - [Zhonya's Manager]", "items")
	m.items:addParam("enableautozhonya", "Auto Zhonya's", SCRIPT_PARAM_ONOFF, false)
	m.items:addParam("autozhonya", "Zhonya's if Health under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	
	m:addSubMenu("IFML - [KS Manager]", "ks")
	m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

	m:addSubMenu("IFML - [Misc Manager]", "vip")
	m.vip:addParam("pretype", "--- Spell Prediction ---", 5, "")
	m.vip:addParam("prediction", "Choose Prediction", SCRIPT_PARAM_LIST, 2, {"VPrediction", "HPrediction" })
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hitchance", "Spel Hitchance [VPrediction]", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	m.vip:addParam("hitinfo", "1=low 2=high 3=slowed 4=stunned/rooted", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hhitchance", "Spell Hitchance [HPrediction]", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
	m.vip:addParam("hitinfo", "1=low 2=mid 3=high", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	
	m:addSubMenu("IFML - [Draw Manager]", "draw")
	m.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, false)

	if SX == true then
	m:addSubMenu("IFML - [Orbwalk Manager]", "orbwalk")
	SxOrb:LoadToMenu(m.orbwalk)
	else
	m:addSubMenu("[SAC detected. SxOrbWalk disabled!]", "orbwalk")
	end
	m:addTS(ts)
	ts.name = "Lux"
	PrintChat ("<font color='#FF9A00'>[Imma firin mah lazor v1.5] by dd2 Loaded! </font>")
end

function OnTick()
	ts:update()
	target = ts.target
	checks()
	combo()
	Killsteal()
	etrigger()
	autoshield()
	autozhonya()
end

function checks()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function OnApplyBuff(source, unit, buff)
	if unit and unit == target and buff.name == "LuxLightBindingMis" then
		targetbinded = true
    end
    if unit and unit == target and buff.name == "luxilluminatingfraulein" then
		targetsaa = true
    end 
    if unit and unit.isMe and buff.name == "summonerdot" then
    	myheroignited = true
    end
end

function OnRemoveBuff(unit, buff)
    if unit and unit == target and buff.name == "LuxLightBindingMis" then
        targetbinded = false
    end
	if unit and unit == target and buff.name == "luxilluminatingfraulein" then
		targetsaa = false
    end
    if unit and unit.isMe and buff.name == "summonerdot" then
    	myheroignited = false
    end
end

function autozhonya()
	if m.items.enableautozhonya and not recalling then
		if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157) 
		end
	end
end

function autoshield()
	if m.shieldmanager.shield and not recalling then
		if myHero.health <= (myHero.maxHealth * m.shieldmanager.value / 100) then CastSpell(_W, mousePos.x, mousePos.z)
		end
	end
end

function etrigger()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and GetDistance(enemy, EObject) + GetDistance(enemy, enemy.minBBox)/2 < Spells.E.width then
			CastSpell(_E)
		end	
	end
end

function OnCreateObj(object)
	if obj and unit then
	    if object.name:find("Lux_Base_E_tar_aoe_green") or obj.name:find("LuxLightstrike_tar_green") or obj.name:find("Lux_Base_E_mis.troy") then
	        EObject = object
	    end
	    if object.name:find("TeleportHome") and GetDistance(object)<100 then
	        recalling = true
	    end
	end
end

function OnDeleteObj(object)
	if obj and unit then
	    if object.name:find("Lux_Base_E_tar_aoe_green") or obj.name:find("LuxLightstrike_tar_green") or obj.name:find("Lux_Base_E_mis.troy") then
	        EObject = nil
	    end
	    if object.name:find("TeleportHome") and GetDistance(object)<100 then
	        recalling = false
	    end
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

-- VPrediction E Cast --
function CastVE(unit)
	local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, Spells.E.delay, Spells.E.width / 2, Spells.E.range, Spells.E.speed, myHero)
	if HitChance >= m.vip.hitchance then
  		CastSpell(_E, CastPosition.x, CastPosition.z)
  	end
end

-- HPrediction E Cast --
function CastHE(unit)
	local EPos, EHitChance = HPred:GetPredict(HPred.Presets['Lux']["E"], unit, myHero)
	if EHitChance >= m.vip.hhitchance then
		CastSpell(_E, EPos.x, EPos.z)
	end
end

-- VPrediction R Cast --
function CastVR(unit)
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Spells.R.delay, Spells.R.width, Spells.R.range, Spells.R.speed, myHero, false)
	if HitChance >= m.vip.hitchance then
  		CastSpell(_R, CastPosition.x, CastPosition.z)
  	end
end

function combo()

	if not ValidTarget(target) then targetbinded = false targetsaa = false end

	if m.key.combokey and ValidTarget(target) then

		local Rdmg = getDmg("R", target, myHero)

		if m.vip.prediction == 1 then
			if Qready and m.combo.useq and GetDistance(target) < Spells.Q.range then
				CastVQ(target)
			end
			if Eready and m.combo.usee and GetDistance(target) < Spells.E.range then
				CastVE(target)
			end
			if m.combo.rmode == 1 then
				if targetbinded and GetDistance(target) < Spells.R.range then
					if Eready and m.combo.usee then
						CastVE(target)
						if Rready and m.combo.user then
							CastSpell(_R, target.x, target.z)
						end
					elseif Rready and m.combo.user then
						CastSpell(_R, target.x, target.z)
					end
				end
			elseif m.combo.rmode == 2 then
				if targetbinded and GetDistance(target) < Spells.R.range then
					if Eready and m.combo.usee then
						CastVE(target)
						if Rready and m.combo.user and target.health < Rdmg then
							CastSpell(_R, target.x, target.z)
						end
					elseif Rready and m.combo.user and target.health < Rdmg then
						CastSpell(_R, target.x, target.z)
					end
				end
			elseif m.combo.rmode == 3 then
				if Rready and m.combo.user and target.health < Rdmg then
					CastVR(target)
				end
			else
				if Rready and m.combo.user then
					CastVR(target)
				end
			end
		else
			if Qready and m.combo.useq and GetDistance(target) < Spells.Q.range then
				CastHQ(target)
			end
			if Eready and m.combo.usee and GetDistance(target) < Spells.E.range then
				CastHE(target)
			end
			if m.combo.rmode == 1 then
				if targetbinded and GetDistance(target) < Spells.R.range then
					if Eready and m.combo.usee then
						CastHE(target)
						if Rready and m.combo.user then
							CastSpell(_R, target.x, target.z)
						end
					elseif Rready and m.combo.user then
						CastSpell(_R, target.x, target.z)
					end
				end
			elseif m.combo.rmode == 2 then
				if targetbinded and GetDistance(target) < Spells.R.range then
					if Eready and m.combo.usee then
						CastHE(target)
						if Rready and m.combo.user and target.health < Rdmg then
							CastSpell(_R, target.x, target.z)
						end
					elseif Rready and m.combo.user and target.health < Rdmg then
						CastSpell(_R, target.x, target.z)
					end
				end
			elseif m.combo.rmode == 3 then
				if Rready and m.combo.user and target.health < Rdmg then
					CastVR(target)
				end
			else
				if Rready and m.combo.user then
					CastVR(target)
				end
			end
		end
		if (myheroignited or ignited) and Wready and m.shieldmanager.shieldoi then 
			CastSpell(_W, mousePos.x, mousePos.z)
		end
		if targetsaa and m.combo.procp then
			if SX then
				if SxOrb:CanAttack() then
					SxOrb:Attack(target)
				end
			elseif SAC then
				if _G.AutoCarry.Orbwalker:CanShoot() then
					myHero:Attack(target)
				end
			end
		end
	end
end

function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do

		if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
		end

		if m.vip.prediction == 1 then
			if Qready and m.ks.useq and enemy.health < getDmg("Q", enemy, myHero) and ValidTarget(enemy, Spells.Q.range) then
				CastVQ(enemy)
			end
			if Eready and m.ks.usee and enemy.health < getDmg("E", enemy, myHero) and ValidTarget(enemy, Spells.E.range) then
				CastVE(enemy)
			end
		else
			if Qready and m.ks.useq and enemy.health < getDmg("Q", enemy, myHero) and ValidTarget(enemy, Spells.Q.range) then
				CastHQ(enemy)
			end
			if Eready and m.ks.usee and enemy.health < getDmg("E", enemy, myHero) and ValidTarget(enemy, Spells.E.range) then
				CastHE(enemy)
			end
		end
	end
end


function OnDraw()
	Drawings()
end

function Drawings()
	if m.draw.drawq then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, Spells.Q.range, 1, ARGB(255, 255, 255, 255))
	end

	if m.draw.draww then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, Spells.W.range, 1, ARGB(255, 255, 255, 255))
	end

	if m.draw.drawe then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, Spells.E.range, 1, ARGB(255, 255, 255, 255))
	end

	if m.draw.drawr then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, Spells.R.range, 1, ARGB(255, 255, 255, 255))
	end
end
