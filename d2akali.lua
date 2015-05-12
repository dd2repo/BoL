if myHero.charName ~= "Akali" then
return
end

require 'SxOrbWalk'

local selectedTar = nil
local VP = nil
local version = 1.2
local AUTOUPDATE = true
local SCRIPT_NAME = "d2akali"
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

function OnLoad()
Vars()
Menu()
end

function Vars()
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,900)
m = scriptConfig("[D2 Akali v1.2]", "d2akali")
orb = SxOrb
Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
end

function Menu()
m:addSubMenu("Combo Settings", "combosettings")
m.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("logic", "Combo logic", SCRIPT_PARAM_LIST, 1, {"Spam everything", "Only E if Q is on target", "Force R > Q > E" })
m:addSubMenu("Item Settings", "items")
m.items:addParam("usedfg", "RIP Deathfire Grasp", SCRIPT_PARAM_ONOFF, true)
m.items:addParam("usebt", "RIP Blackfire Torch", SCRIPT_PARAM_ONOFF, true)
m.items:addParam("usehg", "Use Hextech Gunblade", SCRIPT_PARAM_ONOFF, true)
m.items:addParam("usebc", "Use Bilgewater Cutlass", SCRIPT_PARAM_ONOFF, true)
m.items:addParam("logic", "Item logic", SCRIPT_PARAM_LIST, 1, {"Combo", "Always" })
m.items:addParam("enableautozhonya", "Auto Zhonya's", SCRIPT_PARAM_ONOFF, false)
m.items:addParam("autozhonya", "Zhonya's if Health under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
m:addSubMenu("Stealth Settings", "stealthsettngs")
m.stealthsettngs:addParam("w", "Use % HP stealh logic", SCRIPT_PARAM_ONOFF, true)
m.stealthsettngs:addParam("usew", "Use W if your HP is under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
m.stealthsettngs:addParam("w2", "Use X enemys stealh logic", SCRIPT_PARAM_ONOFF, true)
m.stealthsettngs:addParam("usew2", "Use W if X enemys in range", SCRIPT_PARAM_LIST, 1, {"2 enemys", "3 enemys", "4 enemys", "5 enemys" })
m:addSubMenu("KS Settings", "ks")
m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
m:addSubMenu("Drawings", "draws")
m.draws:addParam("drawq", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawe", "Draw E range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawr", "Draw R range", SCRIPT_PARAM_ONOFF, false)
m:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
--m:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, true)
m:addParam("target", "Left click target selection", SCRIPT_PARAM_ONOFF, true)
m:addSubMenu("Orbwalker", "orbwalk")
orb:LoadToMenu(m.orbwalk)
m:addTS(ts)
ts.name = "Selection"
PrintChat ("<font color='#F20000'>[D2 Akali v1.2] loaded!</font>")
end

function OnTick()
checks()
--targetmagnet()
Killsteal()
Combo()
CST()
Autostealth()
Items()
autozhonya()
end

function checks()
ts:update()
Qready = (myHero:CanUseSpell(_Q) == READY)
Wready = (myHero:CanUseSpell(_W) == READY)
Eready = (myHero:CanUseSpell(_E) == READY)
Rready = (myHero:CanUseSpell(_R) == READY)
target = ts.target
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

function Autostealth()
    if m.stealthsettngs.w2 then
        if m.stealthsettngs.usew2 == 1 then
            if CountEnemyHeroInRange(900) >= 2 then
                CastSpell(_W, myHero.x, myHero.z)
            end
        elseif m.stealthsettngs.usew2 == 2 then
            if CountEnemyHeroInRange(900) >= 3 then
                CastSpell(_W, myHero.x, myHero.z)
            end
        elseif m.stealthsettngs.usew2 == 3 then
            if CountEnemyHeroInRange(900) >= 4 then
                CastSpell(_W, myHero.x, myHero.z)
            end
        elseif m.stealthsettngs.usew2 == 4 then
            if CountEnemyHeroInRange(900) >= 5 then
                CastSpell(_W, myHero.x, myHero.z)
            end
        end
    end
    if m.stealthsettngs.w then
        if myHero.health <= (myHero.maxHealth * m.stealthsettngs.usew / 100) then 
            CastSpell(_W, myHero.x, myHero.z)
        end
    end
end

function autozhonya()
    if m.items.enableautozhonya then
        if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157) CastItem(3090) 
        end
    end
end

function AkaliMota(unit)
 return TargetHaveBuff('AkaliMota', unit)
end

function Items()
    if ValidTarget(target) and m.combokey then
        local tdis = GetDistance(target)
        if Qready or (m.items.logic == 1 and (Eready or Qready or Rready)) then
            if m.items.usehg and tdis < 700 then CastItem(3146, target) end
            if m.items.usebc and tdis < 700 then CastItem(3144, target) end
        end
    end
end

function Combo()
    if not target then return end
    if ValidTarget(target) and m.combokey then
        local tdis  = GetDistance(target)
        local hbuff = AkaliMota(target)
        if m.combosettings.logic == 1 then
            if m.combosettings.useq and tdis < 600 and Qready then
                CastSpell(_Q, target)
            end
            if m.combosettings.usee and tdis < 300 and Eready then
                CastSpell(_E, target)
            end
            if m.combosettings.user and tdis < 800 and Rready then
                CastSpell(_R, target)
            end
        elseif m.combosettings.logic == 2 then
            if m.combosettings.useq and tdis < 600 and Qready then
                CastSpell(_Q, target)
            end 
            if m.combosettings.usee and tdis < 300 and Eready and hbuff then
                CastSpell(_E, target)
            end
            if m.combosettings.user and tdis < 800 and Rready then
                CastSpell(_R, target)
            end
        elseif m.combosettings.logic == 3 then
            if Qready and Eready and Rready and tdis < 800 then
                CastSpell(_R, target)
            end
            if (myHero.level < 6 or myHero:GetSpellData(_R).currentCd > 0) and Qready and tdis < 600 then
                CastSpell(_Q, target)
            end
            if (myHero.level < 6 or hbuff) and Eready and tdis < 300 then
                CastSpell(_E)
            end
        end
    end
end

function Killsteal()
    for _, enemy in pairs(GetEnemyHeroes()) do
    if not enemy then return end
    local tdis  = GetDistance(enemy)
    local qdmg = myHero:CalcMagicDamage(enemy, (20*myHero:GetSpellData(_Q).level+15+.4*myHero.ap))
    local edmg = myHero:CalcMagicDamage(enemy, (25*myHero:GetSpellData(_E).level+5+0.3*myHero.ap+0.6*myHero.totalDamage))
    local rdmg = myHero:CalcMagicDamage(enemy, (75*myHero:GetSpellData(_R).level+25+.5*myHero.ap))

        if ValidTarget(enemy) then

            if m.ks.q and enemy.health < qdmg and tdis < 600 and Qready then
                CastSpell(_Q, enemy)
            end

            if m.ks.e and enemy.health < edmg and tdis < 300 and Eready then
                CastSpell(_E)
            end

            if m.ks.r and enemy.health < rdmg and tdis < 800 and Rready then
                CastSpell(_R, enemy)
            end

            if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
            end
        end
    end 
end
--[[
function targetmagnet()
    if m.combokey and target and ValidTarget(target, 300) and m.magnet then
        local dist = GetDistanceSqr(target)
        if dist < 300^2 and dist > 80^2 then 
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
            orb:OrbWalk(unit, orbwalkPoint1)
        else
            orb:OrbWalk(unit, orbwalkPoint2)
        end
    else
        orb:OrbWalk(unit, myHero)
    end
end
]]
function CST()
    local Target = nil
    if selectedTar then Target = selectedTar
    else Target = ts.target
    end
end

function OnWndMsg(Msg, Key)
    if m.target then
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
                    print("<font color=\"#FFFFFF\">Akali: Target <b>UNSELECTED</b>: "..starget.charName.."</font>")
                else
                    selectedTar = starget               
                    print("<font color=\"#FFFFFF\">Akali: New target <b>selected</b>: "..starget.charName.."</font>")
                end
            end
        end
    end
end

function OnDraw()
    if m.draws.drawq then
        DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 255, 255, 255))
    end
    if m.draws.drawe then
        DrawCircle(myHero.x, myHero.y, myHero.z, 300, ARGB(255, 255, 255, 255))
    end
    if m.draws.drawr then
        DrawCircle(myHero.x, myHero.y, myHero.z, 800, ARGB(255, 255, 255, 255))
    end
end
