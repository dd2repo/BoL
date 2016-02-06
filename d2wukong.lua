if myHero.charName ~= "MonkeyKing" then
return
end

local SX = false
local Hydra = false
local SAC = false
local selectedTar = nil
local VP = nil
local version = 1.6
local AUTOUPDATE = true
local SCRIPT_NAME = "d2wukong"
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
    if _G.Reborn_Loaded ~= nil then
        SAC = true
        print ("D2 Wukong: SAC Reborn detected.")
    else SX = true
        print ("D2 Wukong: SAC cannot be found. Will load SxOrbWalk.")
        if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
            require 'SxOrbWalk'
        else print ("D2 Wukong: You need to download SxOrbWalk. Loading Script failed..") return 
        end
    end
vars()
menu()
end

function vars()
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,315)
    m = scriptConfig("[D2 Wukong v1.6]", "d2wukong")
    orb = SxOrb
    if SX then orb:RegisterAfterAttackCallback(hydra) end
    Ignite  = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
    PrintChat ("<font color='#00BCFF'>[D2 Wukong v1.1] loaded!</font>")
end


function menu()
m:addSubMenu("Combo Settings", "combosettings")
m.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("useqaa", "Use Q as AA reset only (meele only)", SCRIPT_PARAM_ONOFF, true)
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
--m:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, true)
m:addParam("target", "Left Click Target Selection", SCRIPT_PARAM_ONOFF, true)

    if SX == true then
    m:addSubMenu("Orbwalker", "orbwalk")
    orb:LoadToMenu(m.orbwalk)
    else
    m:addSubMenu("[SAC detected. SxOrbWalk disabled!]", "orbwalk")
    end

m:addTS(ts)
ts.name = "Selection"
end

function OnIssueOrder(source, order, position, target)
    if _G.Reborn_Initialised and SAC then
        if _G.AutoCarry.Keys.AutoCarry and source.isMe and order == 3 then -- 2 = move, 3 = attack
            if GetDistance(position) - target.boundingRadius < myHero.range + myHero.boundingRadius and Hready and Hydra ~= nil then -- Check that they are in our AA range
                CastSpell(Hydra) -- This will cast before the "order" is actually sent to the server
            end
        end
    else
        return
    end
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

function OnCreateObj(object)
    if object.name == 'MonkeyKing_Base_R_Cas_Glow.troy' then
        usingult2 = true
    end
    if object.name == 'MonkeyKing_Base_R_Cas.troy' then
        usingult3 = true
    end
end

function OnDeleteObj(object)
    if object.name == 'MonkeyKing_Base_R_Cas_Glow.troy' then
        usingult2 = false
    end
    if object.name == 'MonkeyKing_Base_R_Cas.troy' then
        usingult3 = false
    end
end

function OnTick()

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
    for i=6,11 do
        local itemName = myHero:GetSpellData(i).name
        if itemName == "ItemTiamatCleave" then 
            Hydra = i
            Hready = (myHero:CanUseSpell(Hydra) == READY)
        end
    end
    target = ts.target
end


function Autoult()
    if m.ultimatesettings.useau and not (usingult or usingult2 or usingult3) then
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

function CastQ2()
    CastSpell(0)
end

function hydra()
    if m.combokey and target and ValidTarget(target, 200) and GetDistance(target) <= 200 and Hready then CastSpell(Hydra)
    end
end

function CastQ()
    if not (usingult or usingult2 or usingult3) then
        if m.combokey and Qready and m.combosettings.useq and target and ValidTarget(target, 290) and GetDistance(target) <= 290 and not m.combosettings.useqaa then
            CastSpell(_Q)
        elseif m.combosettings.useqaa and Qready and m.combosettings.useq and target and m.combokey then
            if _G.Reborn_Initialised and SAC then 
                _G.AutoCarry.Plugins:RegisterOnAttacked(CastQ2)
            end
        end 
    end
end

function CastE()
    if not (usingult or usingult2 or usingult3) then
        if m.combokey and Eready and m.combosettings.usee then
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
        if ValidTarget(enemy, 315) and m.ks.user and not (usingult or usingult2 or usingult3) then
            local RDmg = getDmg('R', enemy, myHero) or 0
            if Rready and enemy.health <= RDmg*4 then
                CastSpell(_R)
            end
        end
        if m.ks.usee and ValidTarget(enemy, 610) and not (usingult or usingult2 or usingult3) then
            local EDmg = getDmg('E', enemy, myHero) or 0
            if Eready and enemy.health <= EDmg then
                CastSpell(_E, enemy)
            end
        end
    end 
end

--[[
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
