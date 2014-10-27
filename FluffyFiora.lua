if myHero.charName ~= "Fiora" or not VIP_USER then
return
end

require 'SOW'
require 'Vprediction'

local VP = nil
local secondq = false
local lastSkin = 4
local projectilespeed = {["Velkoz"]= 2000,["Xerath"] = 2000.0000,["Ziggs"] = 1500.0000,["KogMaw"] = 1800.0000,["Ashe"] = 2000.0000 ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000,["Lissandra"] = 2000.0000,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000,["Sona"] = 1500.0000,["Caitlyn"] = 2500.0000,["Anivia"] = 1400.0000,["Heimerdinger"] = 1500.0000 ,["Leblanc"] = 1700.0000 ,["Viktor"] = 2300.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Syndra"] = 1800.0000 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Urgot"] = 1300.0000 ,["Karma"] = 1500.0000 ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000,["Quinn"] = 2000.0000,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Annie"] = 1200.0000,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000,["MissFortune"] = 2000.0000,["Cassiopeia"] = 1200.0000,["Lucian"] = 2800.0000,["Kennen"] = 1600.0000 ,["Ryze"] = 2400.0000,["Lux"] = 1600.0000 ,["Ezreal"] = 2000.0000,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Zilean"] = 1200.0000,["Malzahar"] = 2000.0000}
local wlist = {["Renekton"] = "RenektonExecute",["MissFortune"] = "MissFortuneRicochetShot",["Leona"] = "LeonaShieldOfDaybreakAttack",["Garen"] = "GarenSlash2",["Nasus"] = "NasusQAttack",["Shyvana"] = "ShyvanaDoubleAttackHit",["Darius"] = "DariusNoxianTacticsONHAttack",["Gangplank"] = "Parley",["Sivir"] = "RicochetAttack",["Talon"] = "TalonNoxianDiplomacyAttack",["Jax"] = "jaxrelentlessattack"}
local rlist = {["Amumu"] = "CurseoftheSadMummy",["Annie"] = "InfernalGuardian",["Ashe"] = "EnchantedCrystalArrow",["Corki"]="CarpetBomb",["Lucian"]="LucianE",["Darius"]="DariusExecute", ["Garen"]="GarenR",["Ezreal"]="EzrealArcaneShift",["Galio"] = "GalioIdolOfDurand",["Gragas"] = "GragasR",["Sona"] = "SonaR",["Syndra"] = "syndrar",["Tristana"] = "BusterShot",["Malphite"] = "UFSlash",["Veigar"] = "VeigarPrimordialBurst",["Vi"] = "ViR"}
local current = nil
local shanghai = nil
local koreanwind = nil
local cancelled = false
local percent = 0.9
local melee = false
local BuffGT = 0
local ignite = nil
local VIP_User
local version = 1.0
local AUTOUPDATE = true
local SCRIPT_NAME = "FluffyFiora"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local abilitySequence
local qOff, wOff, eOff, rOff = 0,0,0,0

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

function OnLoad()
vars()
menu()
drawtable()
end


function drawtable()
enemyCount = 0
  enemyTable = {}
  for i = 1, heroManager.iCount do
    local champ = heroManager:GetHero(i)  
    if champ.team ~= player.team then
      enemyCount = enemyCount + 1
      enemyTable[enemyCount] = { player = champ, indicatorText = "", damageGettingText = "", ultAlert = false, ready = true}
    end
  end
end

function vars()
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,650)
m = scriptConfig("[Fluffy Fiora]", "Fluffyfiora")
VP = VPrediction()
sow = SOW(VP)
sow:RegisterAfterAttackCallback(hydra)
sow:RegisterOnAttackCallback(CastE)
jungleMinions = minionManager(MINION_JUNGLE, 800, myHero, MINION_SORT_MAXHEALTH_DEC)
enemyMinions = minionManager(MINION_ENEMY, 800, myHero, MINION_SORT_HEALTH_ASC)
Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
_G.oldDrawCircle = rawget(_G, 'DrawCircle')
_G.DrawCircle = DrawCircle2
end

function menu()
m:addSubMenu("[Key Manager]", "keysettings")  
m.keysettings:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
m.keysettings:addParam("junglekey", "Clear", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("V"))
m.keysettings:addParam("forcer", "Force Ultimate Cast", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("C"))
m:addSubMenu("[Lunge / Q Manager]", "qsettings")
m.qsettings:addParam("useq", "Use Lunge / Q", SCRIPT_PARAM_ONOFF, true)
m.qsettings:addParam("useks", "KS with Lunge / Q", SCRIPT_PARAM_ONOFF, true)
m.qsettings:addParam("gm", "Q Range in Gapclose Mode", SCRIPT_PARAM_SLICE, 250, 200, 600, 0)

m.qsettings:addParam("forceq", "Force second Q before expire", SCRIPT_PARAM_ONOFF, true)
m.qsettings:addParam("qmode", "Q Mode", SCRIPT_PARAM_LIST, 1, {"Gapclose", "Burst"})
m:addSubMenu("[Riposte / W Manager]", "WSet")  
local aaPredict = false
for i, enemy in ipairs(GetEnemyHeroes()) do
            m.WSet:addSubMenu(enemy.charName, enemy.charName)
            m.WSet[enemy.charName]:addParam("Basic", "Basic Attack", SCRIPT_PARAM_ONOFF, true)
            if wlist[enemy.charName] ~= nil then
                m.WSet[enemy.charName]:addParam("Spell", wlist[enemy.charName], SCRIPT_PARAM_ONOFF, true)
            end
            m.WSet[enemy.charName]:addParam("Smart", "Use Smart W", SCRIPT_PARAM_ONOFF, true)
     aaPredict = true
end
if not aaPredict then
    m.WSet:addParam("aaNotSupported","han = honda ?", SCRIPT_PARAM_INFO, "")
end
m:addSubMenu("[Burst of Speed / E Manager]", "esettings")
m.esettings:addParam("usee", "Use Burst of Speed / E", SCRIPT_PARAM_ONOFF, true)
m.esettings:addParam("qmode", "E Mode", SCRIPT_PARAM_LIST, 1, {"OnAttack", "AA Range"})
m:addSubMenu("[Blade Waltz / R Manager]", "ultimatesettings")
m.ultimatesettings:addParam("alert", "Isolation alerter", SCRIPT_PARAM_ONOFF, true)
m.ultimatesettings:addParam("finish", "Finish Enemy with Blade Waltz / R", SCRIPT_PARAM_ONOFF, true)
m.ultimatesettings:addParam("useau", "Use Auto-Ultimate", SCRIPT_PARAM_ONOFF, true)
m.ultimatesettings:addParam("auv", "Use Auto-Ultimate if it hits", SCRIPT_PARAM_LIST, 1, {"2 Targets", "3 Targets", "4 Targets", "5 Targets" })
m:addSubMenu("[Clear Manager]", "c")
m.c:addParam("useq", "Use Lunge / Q", SCRIPT_PARAM_ONOFF, true)
m.c:addParam("usew", "Use Riposte / W", SCRIPT_PARAM_ONOFF, true)
m.c:addParam("usee", "Burst of Speed / E", SCRIPT_PARAM_ONOFF, true)
m:addSubMenu("[Draw Manager]", "draws")
m.draws:addParam("drawaa", "Draw AA range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawq", "Draw Lunge / Q range", SCRIPT_PARAM_ONOFF, true)
m.draws:addParam("drawr", "Draw Blade Waltz / R range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("LagFree", "Lag Free Circles", 1, false)
m.draws:addParam("disable", "Disable all Drawings", SCRIPT_PARAM_ONOFF, false)
m:addSubMenu("[Additionals]", "adds")
m.adds:addParam("ignite", "Dont use Ignite", SCRIPT_PARAM_ONOFF, false)
m.adds:addParam("al", "Auto level Spells", SCRIPT_PARAM_ONOFF, false)
m.adds:addParam("alp", "Auto level Spells Priority", SCRIPT_PARAM_LIST, 1, {"R>Q>E>W", "R>E>Q>W"})
m:addSubMenu("[Skin Manager]", "skin")
m.skin:addParam("Skin", "Skin Manager", SCRIPT_PARAM_ONOFF, false)
m.skin:addParam("Select", "Select skin", SCRIPT_PARAM_SLICE, 4, 1, 4)
if m.skin.Skin then
    GenModelPacket("Fiora", m.skin.Select)
    lastSkin = m.skin.Select
end
m:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, true)
m:addSubMenu("[Orbwalker]", "orbwalk")
sow:LoadToMenu(m.orbwalk)
m:addTS(ts)
ts.name = "Fluffy"
PrintChat ("<font color='#00BCFF'>[Fluffy Fiora] v1.0 by DeadDevil2 Loaded! </font>")
end
--[[
function OnGainBuff(unit,buff)
	if buff.name == 'fioraqcd' and unit.isMe then
		BuffGT = os.clock() 
	end 
end

function OnLoseBuff(unit, buff)
    if buff.name == 'fioraqcd' and unit.isMe then
        secondq = false
    end
end
]]
function OnTick()
checks()
if m.keysettings.combokey then
CastQ()
end
CastR()
targetmagnet()
checks()
Killsteal()
Autoult()
if m.ultimatesettings.alert then
Alerter()
end
CastErange()
Skin()
Han_WTick()
CST()
--BuffTick()
--levelsequence()
--autolevel()
LFC()
end

function LFC()
	if not m.draws.LagFree then _G.DrawCircle = _G.oldDrawCircle end
	if m.draws.LagFree then
		_G.DrawCircle = DrawCircle2
	end
end

function BuffTick()
	if (os.clock() - BuffGT) > 3.8 then secondq = true end 
end

function Alerter()
	if m.draws.disable then return end
	    for i = 1, enemyCount do
	        local enemy = enemyTable[i].player
	        if ValidTarget(enemy) and enemy.visible then
		    local Qdmg = getDmg('Q', enemy, myHero)    
			local Rdmg = getDmg('R', enemy, myHero)
			local ARdmg = Rdmg+(4*(Rdmg*0.25))
			local QRdmg	= (Rdmg+(4*(Rdmg*0.25)))+(Qdmg*2)
				if ValidTarget(enemy, 1000) then
					if CountEnemyHeroInRange(800) == 1 then
						if      enemy.health > QRdmg*2  then enemyTable[i].indicatorText = "Isolated - Not Killable" 
			        	elseif  enemy.health > QRdmg  then enemyTable[i].indicatorText = "Isolated - Hardcombo Kill" 
			           	elseif  enemy.health < QRdmg  then enemyTable[i].indicatorText = "Isolated - Easy Combo Kill"
			           	elseif  enemy.health < ARdmg  then enemyTable[i].indicatorText = "Isolated - Ultimate Kill"
			       		end
			       	elseif CountEnemyHeroInRange(800) >= 2 then
			       		enemyTable[i].indicatorText = "Not Isolated" 
			        end
			    end
			end
	    end
end

function JungleClear()
  jungleMinions:update()
  for i, jungleMinion in pairs(jungleMinions.objects) do
    if jungleMinion ~= nil then
      if m.keysettings.junglekey then
        if Qready and m.c.useq and ValidTarget(jungleMinion, 475) then
          CastSpell(_Q, jungleMinion) 
        end
        if Wready and m.c.usew and ValidTarget(jungleMinion, 300) then
           CastSpell(_W)
        end 
        if Eready and m.c.usee and ValidTarget(jungleMinion, 400) then 
            CastSpell(_E)     
        end
      end
    end
  end
end

function Clear()
  enemyMinions:update()
  for i, enemyMinion in pairs(enemyMinions.objects) do
    if enemyMinion ~= nil then
      if m.keysettings.junglekey then
        if Qready and m.c.useq and ValidTarget(enemyMinion, 475) then
          CastSpell(_Q, enemyMinion) 
        end
        if Wready and m.c.usew and ValidTarget(enemyMinion, 300) then
           CastSpell(_W)
        end 
        if Eready and m.c.usee and ValidTarget(enemyMinion, 400) then
            CastSpell(_E)       
        end
      end
    end
  end
end

function checks()
	ts:update()
	target = ts.target
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
end

function hydra()
	if m.keysettings.combokey and ValidTarget(target, 200) and GetDistance(target) <= 200 then CastItem(3074) CastItem(3077)
	end
end

function OnRecvPacket(p)
    if not safecall then
        if p.header == 0x34 then
            p.pos = 1
            if ActiveAttacks[1] == p:DecodeF() then
                p.pos = 9
                if p:Decode1() == 0x11 then
                    ResetW(false)
                end
            end
        end
   end
end

function CastQ()
	if m.qsettings.qmode == 1 then
		if Qready and m.qsettings.useq and ValidTarget(target, 600) and GetDistance(target) <= 600 and GetDistance(target) >= m.qsettings.gm then
			CastSpell(_Q, target)
		end
	elseif m.qsettings.qmode == 2 then
		if Qready and m.qsettings.useq and ValidTarget(target, 600) and GetDistance(target) <= 600 then
			CastSpell(_Q, target)
		end
	end
	if m.qsettings.forceq then
		if secondq then CastSpell(_Q, target) end
	end
end

function CastE()
	if Eready and m.esettings.usee and ValidTarget(target, 620) and GetDistance(target) <= 620 then 
		CastSpell(_E)
	end
end

function CastR()
	if Rready and m.keysettings.forcer then
		CastSpell(_R, target)
	end
end

function CastErange()
	if m.esettings.usee == 2 then
		if Eready and m.combosettings.usee and ValidTarget(target) and GetDistance(target) <= 150 then 
			CastSpell(_E)
		end
	end
end

function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
	if Ignite ~= nil and not m.adds.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy) end
	local Rdmg = getDmg('R', enemy, myHero)
	local Qdmg = getDmg('Q', enemy, myHero)
	local ARdmg = Rdmg+(4*(Rdmg*0.25))
		if usingult then return end
		if CountEnemyHeroInRange(800) == 1 then
			if ValidTarget(enemy, 400) and m.ultimatesettings.finish then
				if Rready and enemy.health <= ARdmg then
					CastSpell(_R, enemy)
				end
			end
		end
		if CountEnemyHeroInRange(800) >= 2 then
			if ValidTarget(enemy, 400) and m.ultimatesettings.finish then
				if Rready and enemy.health <= Rdmg then
					CastSpell(_R, enemy)
				end
			end
		end
		if ValidTarget(enemy, 600) and m.qsettings.useks then
			if Qready and enemy.health <= Qdmg then
				CastSpell(_Q, enemy)
			end
		end
	end
end

function CountEnemyHeroInRange(range)
	local enemyInRange = 0
	for i = 1, heroManager.iCount, 1 do
		local hero = heroManager:getHero(i)
		if ValidTarget(hero,range) then
			enemyInRange = enemyInRange + 1
		end
	end
	return enemyInRange
end 

function Autoult()
	if m.ultimatesettings.useau then
		if m.ultimatesettings.auv == 1 then
			if CountEnemyHeroInRange(400) >= 2 then
				CastSpell(_R)
			end
		elseif m.ultimatesettings.auv == 2 then
			if CountEnemyHeroInRange(4005) >= 3 then
				CastSpell(_R)
			end
		elseif m.ultimatesettings.auv == 3 then
			if CountEnemyHeroInRange(400) >= 4 then
				CastSpell(_R)
			end
		elseif m.ultimatesettings.auv == 4 then
			if CountEnemyHeroInRange(400) >= 5 then
				CastSpell(_R)
			end
		end
	end
end

function targetmagnet()
    if m.keysettings.combokey and ValidTarget(target, 200) and m.magnet then
	local dist = GetDistanceSqr(target)
	if dist < 70000 and dist > 5400 then 
		stayclose(target, true)
	elseif dist <= 5400 then
		stayclose(target, false)
	end
    end
end

function stayclose(unit, mode)
	if mode then
		local myVector = Vector(myHero.x, myHero.y, myHero.z)
		local targetVector = Vector(unit.x, unit.y, unit.z)
		local orbwalkPoint1 = targetVector + (myVector-targetVector):normalized()*120
		local orbwalkPoint2 = targetVector - (myVector-targetVector):normalized()*120
		if GetDistanceSqr(orbwalkPoint1) < GetDistanceSqr(orbwalkPoint2) then
			sow:OrbWalk(unit, orbwalkPoint1)
		else
			sow:OrbWalk(unit, orbwalkPoint2)
		end
	else
		sow:OrbWalk(unit, myHero)
	end
end

local skinFix = 0
function Skin()
    if m.skin.Select ~= lastSkin and m.skin.Skin then
        GenModelPacket("Fiora", m.skin.Select)
        lastSkin = m.skin.Select
        skinFix = 1
    end
    if not m.skin.Skin and skinFix > 0 then
        GenModelPacket("Fiora", 4)
        lastSkin = 4
    end
end

-- Shalzut
function GenModelPacket(champ, skinId)
    p = CLoLPacket(0x97)
    p:EncodeF(myHero.networkID)
    p.pos = 1
    t1 = p:Decode1()
    t2 = p:Decode1()
    t3 = p:Decode1()
    t4 = p:Decode1()
    p:Encode1(t1)
    p:Encode1(t2)
    p:Encode1(t3)
    p:Encode1(bit32.band(t4,0xB))
    p:Encode1(1)--hardcode 1 bitfield
    p:Encode4(skinId)
    for i = 1, #champ do
        p:Encode1(string.byte(champ:sub(i,i)))
    end
    for i = #champ + 1, 64 do
        p:Encode1(0)
    end
    p:Hide()
    RecvPacket(p)
end

ActiveAttacks = {}
Han_Pre = {}
local safecall = true
function Han_W(unit, spell)
    if safecall then
        local hotan = GetDistance(spell.endPos)
        local janga = GetDistance(unit)
        if hotan < 50 and not unit.isMe then
            if projectilespeed[unit.charName] ~= nil and (spell.name:find("Attack") ~= nil) and hotan < 1 and unit.team ~= myHero.team and unit.type == myHero.type and m.WSet[unit.charName].Basic and m.WSet[unit.charName].Smart then
                safecall = false
                cancelled = false
                shanghai = GetTickCount()-GetLatency()
                koreanwind =  (1/ (unit.attackSpeed*(1 / (spell.windUpTime * unit.attackSpeed))))* 1000
                local delay = koreanwind + (janga/(projectilespeed[unit.charName]/1000))*percent
                current = unit
                local wCalc = {castTime = (shanghai+delay)-GetLatency()}
                table.insert(Han_Pre, wCalc)
                table.insert(ActiveAttacks, unit.networkID)
            elseif Wready and (spell.name:find("Attack") ~= nil) and hotan < 1 and unit.team ~= myHero.team and unit.type == myHero.type and m.WSet[unit.charName].Basic and m.WSet[unit.charName].Smart then
                melee = true
                safecall = false
                cancelled = false
                shanghai = GetTickCount()-GetLatency()
                koreanwind =  (1/ (unit.attackSpeed*(1 / (spell.windUpTime * unit.attackSpeed))))* 1000
                local wCalc = {castTime = (shanghai+koreanwind)-GetLatency()-100}
                table.insert(Han_Pre, wCalc)
                table.insert(ActiveAttacks, unit.networkID)
            elseif Wready and unit.team ~= myHero.team and unit.type == myHero.type and (((spell.name:find("Attack") ~= nil) and GetDistance(spell.endPos) < 1 and m.WSet[unit.charName].Basic) or (m.WSet[unit.charName].Spell and wlist[unit.charName] ~= nil and (spell.name:find(wlist[unit.charName]) ~= nil))) then
                CastSpell(_W)
            end
        end
    end
end

function Han_WTick()
    for i, wCalc in ipairs(Han_Pre) do
        if not melee then 
            wCalc.castTime = shanghai + koreanwind + ((((GetDistance(current)/(projectilespeed[current.charName]/1000))*percent))-GetLatency()) 
        end
        if GetTickCount() >= wCalc.castTime and not cancelled then
            ResetW(true)
        end
    end
end

function ResetW(trong)
    if Wready and trong then CastSpell(_W) end
    table.remove(ActiveAttacks, 1)
    table.remove(Han_Pre, 1)
    cancelled = true
    current = nil
    shanghai = nil
    koreanwind = nil
    melee = false
    safecall = true
end

function OnProcessSpell(unit, spell)
    Han_W(unit, spell)
end

function CST()
	local Target = nil
	if selectedTar then Target = selectedTar
	else Target = ts.target
	end
end
--thanks to bilbao
function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then
		local minD = 10
		local starget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= minD or starget == nil then
					minD = GetDistance(enemy, mousePos)
					starget = enemy
				end
			end
		end		
		if starget and minD < 500 then
			if selectedTar and starget.charName == selectedTar.charName then
				selectedTar = nil
				print("<font color=\"#00BCFF\">Fiora: Target <b>unselected</b>: "..starget.charName.."</font>")
			else
				selectedTar = starget				
				print("<font color=\"#00BCFF\">Fiora: New target <b>selected</b>: "..starget.charName.."</font>")
			end
		end
	end
end

function OnDraw()
Circles()
Drawkilltext()
end

function Drawkilltext()
  for i = 1, enemyCount do
      local enemy = enemyTable[i].player

    if ValidTarget(enemy) and enemy.visible then
      local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
      local pos = { X = barPos.x - 35, Y = barPos.y - 50 }
              
      DrawText(enemyTable[i].indicatorText, 20, pos.X + 20, pos.Y, (enemyTable[i].ready and ARGB(255, 0, 255, 0)) or ARGB(255, 255, 220, 0))
      DrawText(enemyTable[i].damageGettingText, 20, pos.X + 20, pos.Y + 15, ARGB(255, 255, 0, 0))
    end
   end
end

function Circles()
if m.draws.disable then return end
	if m.draws.drawq then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 255, 255, 255))
	end
	if m.draws.drawr then
		DrawCircle(myHero.x, myHero.y, myHero.z, 400, ARGB(255, 255, 255, 255))
	end
	if m.draws.drawaa then
		DrawCircle(myHero.x, myHero.y, myHero.z, 170, ARGB(255, 255, 255, 255))
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
