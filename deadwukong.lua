if myHero.charName ~= "MonkeyKing" then
return
end

require 'SOW'
require 'Vprediction'

local selectedTar = nil
local VP = nil
local version = 1.0
local AUTOUPDATE = true
local SCRIPT_NAME = "deadwukong"
local selectedTar = nil
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
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,315)
m = scriptConfig("DEADSERIES - WUKONG", "deadwukong")
VP = VPrediction()
sow = SOW(VP)
sow:RegisterAfterAttackCallback(hydra)
--sow:RegisterOnAttackCallback(CastQ)
Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil

m:addSubMenu("Combo Settings", "combosettings")
m.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

m:addSubMenu("Ultimate Settings", "ultimatesettings")
m.ultimatesettings:addParam("useau", "Use Auto-Ultimate", SCRIPT_PARAM_ONOFF, true)
m.ultimatesettings:addParam("auv", "Use Auto-Ultimate if it hits", SCRIPT_PARAM_LIST, 1, {"2 Targets", "3 Targets", "4 Targets", "5 Targets" })

m:addSubMenu("KS Settings", "ks")
m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("user", "Use Ultimate", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

m:addSubMenu("Drawings", "draws")
m.draws:addParam("drawq", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawe", "Draw E range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawr", "Draw R range", SCRIPT_PARAM_ONOFF, false)

m:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
m:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, true)
m:addParam("target", "Left Click Target Selection", SCRIPT_PARAM_ONOFF, true)

m:addSubMenu("Orbwalker", "orbwalk")
sow:LoadToMenu(m.orbwalk)
m:addTS(ts)
ts.name = "Selection"
PrintChat ("<font color='#00BCFF'>DEADSERIES - WUKONG LOADED!</font>")
end

function OnGainBuff(unit, buff)
    if buff.name == 'MonkeyKingSpinToWin' and unit.isMe then
        usingult = true
    end
end

function OnLoseBuff(unit, buff)
    if buff.name == 'MonkeyKingSpinToWin' and unit.isMe then
        usingult = false
    end
end

function OnTick()
checks()
targetmagnet()
checks()
Killsteal()
CastQ()
CastE()
CST()
Autoult()
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

function Autoult()
    if m.ultimatesettings.useau and not usingult then
        if m.ultimatesettings.auv == 1 then
            if CountEnemyHeroInRange(315) >= 2 then
                CastSpell(_R)
            end
        elseif m.ultimatesettings.auv == 2 then
            if CountEnemyHeroInRange(315) >= 3 then
                CastSpell(_R)
            end
        elseif m.ultimatesettings.auv == 3 then
            if CountEnemyHeroInRange(315) >= 4 then
                CastSpell(_R)
            end
        elseif m.ultimatesettings.auv == 4 then
            if CountEnemyHeroInRange(315) >= 5 then
                CastSpell(_R)
            end
        end
    end
end

function hydra()
    if m.combokey and target and ValidTarget(target, 200) and GetDistance(target) <= 200 then CastItem(3074) CastItem(3077)
    end
end

function CastQ()
    if not usingult then
        if m.combokey and Qready and m.combosettings.useq and target and ValidTarget(target, 290) and GetDistance(target) <= 290 then
            CastSpell(_Q)
        end
    end
end

function CastE()
    if not usingult then
        if m.combokey and Eready then
            ts.range = 620
            ts:update()
            if ValidTarget(ts.target, 620) then
                CastSpell(_E, ts.target)
            end
            ts.range = 315
            ts:update()
        end
    end
end

function Killsteal()
    for _, enemy in pairs(GetEnemyHeroes()) do
        if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
        end
        if ValidTarget(enemy, 315) and m.ks.user and not usingult then
            local RDmg = getDmg('R', enemy, myHero) or 0
            if Rready and enemy.health <= RDmg*4 then
                CastSpell(_R)
            end
        end
        if m.ks.usee and ValidTarget(enemy, 610) then
            local EDmg = getDmg('E', enemy, myHero) or 0
            if Eready and enemy.health <= EDmg then
                CastSpell(_E, enemy)
            end
        end
    end 
end

function targetmagnet()
    if m.combokey and target and ValidTarget(target, 300) and m.magnet then
    local dist = GetDistanceSqr(target)
    if dist < 300^2 and dist > 50^2 then 
        stayclose(target, true)
    elseif dist <= 50^2 then
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
                    print("<font color=\"#FFFFFF\">Wukong: Target <b>UNSELECTED</b>: "..starget.charName.."</font>")
                else
                    selectedTar = starget               
                    print("<font color=\"#FFFFFF\">Wukong: New target <b>selected</b>: "..starget.charName.."</font>")
                end
            end
        end
    end
end

function OnDraw()
    if m.draws.drawq then
        DrawCircle(myHero.x, myHero.y, myHero.z, 300, ARGB(255, 255, 255, 255))
    end
    if m.draws.drawe then
        DrawCircle(myHero.x, myHero.y, myHero.z, 625, ARGB(255, 255, 255, 255))
    end
    if m.draws.drawr then
        DrawCircle(myHero.x, myHero.y, myHero.z, 315, ARGB(255, 255, 255, 255))
    end
end
