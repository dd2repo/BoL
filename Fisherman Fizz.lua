--[[
  Script: Fizz the fish v0.17
  Author: DeadDevil2     


  TODO
  - Dmg Calculation
  - Draw Kil Text
  - Auto level sequenze

]]
if not VIP_USER then
    PrintChat(">> VIP Authentication Failed! You are not authorised to run this script. Unloading.<<")
  return
end

if VIP_USER then
  PrintChat(">> VIP Authentication Successful! Loading the VIP Version, please stand by... <<")
end 

if myHero.charName ~= "Fizz" then
return
end

require 'Collision'
require 'VPrediction'
require 'SOW'
require 'Prodiction'

local VIP_User
local version = 1.0
local AUTOUPDATE = true
local SCRIPT_NAME = "FishermanFizz"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local ts = nil
local prex = 1



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

local Spells = {
        Q = {range = 550,   delay = 0.5, width = 0,   speed = math.huge},
        W = {range = 900,   delay = 0.5, width = 80,  speed = 1450},
        E = {range = 700,   delay = 0.5, width = 100, speed = 1300},
        R = {range = 1275,  delay = 0.5, width = 250, speed = 1200}

}

local JumpSlot = 
{
  ['Fizz'] = _E,
}

local JumpSpots = 
{
  ['Fizz'] = 
  {
    {From = Vector(6478.0454101563, -64.045028686523, 8342.501953125),  To = Vector(6751, 56.019004821777, 8633), CastPos = Vector(6751, 56.019004821777, 8633)},
    {From = Vector(6447, 56.018882751465, 8663),  To = Vector(6413, -62.786361694336, 8289), CastPos = Vector(6413, -62.786361694336, 8289)},
    {From = Vector(6195.8334960938, -65.304061889648, 8559.810546875),  To = Vector(6327, 56.517200469971, 8913), CastPos = Vector(6327, 56.517200469971, 8913)},
    {From = Vector(7095, 56.018997192383, 8763),  To = Vector(7337, 55.616943359375, 9047), CastPos = Vector(7337, 55.616943359375, 9047)},
    {From = Vector(7269, 55.611968994141, 9055),  To = Vector(7027, 56.018997192383, 8767), CastPos = Vector(7027, 56.018997192383, 8767)},
    {From = Vector(5407, 55.045528411865, 10095),  To = Vector(5033, -63.082427978516, 10119), CastPos = Vector(5033, -63.082427978516, 10119)},
    {From = Vector(5047, -63.08129119873, 10113),  To = Vector(5423, 55.007797241211, 10109), CastPos = Vector(5423, 55.007797241211, 10109)},
    {From = Vector(4747, -62.445854187012, 9463),  To = Vector(4743, -63.093593597412, 9837), CastPos = Vector(4743, -63.093593597412, 9837)},
    {From = Vector(4769, -63.086654663086, 9677),  To = Vector(4775, -63.474864959717, 9301), CastPos = Vector(4775, -63.474864959717, 9301)},
    {From = Vector(6731, -64.655540466309, 8089),  To = Vector(7095, 56.051624298096, 8171), CastPos = Vector(7095, 56.051624298096, 8171)},
    {From = Vector(7629.0434570313, 55.042400360107, 9462.6982421875),  To = Vector(8019, 53.530429840088, 9467), CastPos = Vector(8019, 53.530429840088, 9467)},
    {From = Vector(7994.2685546875, 53.530174255371, 9477.142578125),  To = Vector(7601, 55.379856109619, 9441), CastPos = Vector(7601, 55.379856109619, 9441)},
    {From = Vector(6147, 54.117427825928, 11063),  To = Vector(6421, 54.63500213623, 10805), CastPos = Vector(6421, 54.63500213623, 10805)},
    {From = Vector(5952.1977539063, 54.240119934082, 11382.287109375),  To = Vector(5889, 39.546829223633, 11773), CastPos = Vector(5889, 39.546829223633, 11773)},
    {From = Vector(6003.1401367188, 39.562377929688, 11827.516601563),  To = Vector(6239, 54.632926940918, 11479), CastPos = Vector(6239, 54.632926940918, 11479)},
    {From = Vector(3947, 51.929698944092, 8013),  To = Vector(3647, 54.027297973633, 7789), CastPos = Vector(3647, 54.027297973633, 7789)},
    {From = Vector(1597, 54.923656463623, 8463),  To = Vector(1223, 50.640468597412, 8455), CastPos = Vector(1223, 50.640468597412, 8455)},
    {From = Vector(1247, 50.737510681152, 8413),  To = Vector(1623, 54.923782348633, 8387), CastPos = Vector(1623, 54.923782348633, 8387)},
    {From = Vector(2440.49609375, 53.364398956299, 10038.1796875),  To = Vector(2827, -64.97053527832, 10205), CastPos = Vector(2827, -64.97053527832, 10205)},
    {From = Vector(2797, -65.165946960449, 10213),  To = Vector(2457, 53.364398956299, 10055), CastPos = Vector(2457, 53.364398956299, 10055)},
    {From = Vector(2797, 53.640556335449, 9563),  To = Vector(3167, -63.810096740723, 9625), CastPos = Vector(3167, -63.810096740723, 9625)},
    {From = Vector(3121.9699707031, -63.448329925537, 9574.16015625),  To = Vector(2755, 53.722351074219, 9409), CastPos = Vector(2755, 53.722351074219, 9409)},
    {From = Vector(3447, 55.021110534668, 7463),  To = Vector(3581, 54.248985290527, 7113), CastPos = Vector(3581, 54.248985290527, 7113)},
    {From = Vector(3527, 54.452239990234, 7151),  To = Vector(3372.861328125, 55.13143157959, 7507.2211914063), CastPos = Vector(3372.861328125, 55.13143157959, 7507.2211914063)},
    {From = Vector(2789, 55.241321563721, 6085),  To = Vector(2445, 60.189605712891, 5941), CastPos = Vector(2445, 60.189605712891, 5941)},
    {From = Vector(2573, 60.192783355713, 5915),  To = Vector(2911, 55.503971099854, 6081), CastPos = Vector(2911, 55.503971099854, 6081)},
    {From = Vector(3005, 55.631782531738, 5797),  To = Vector(2715, 60.190528869629, 5561), CastPos = Vector(2715, 60.190528869629, 5561)},
    {From = Vector(2697, 60.190807342529, 5615),  To = Vector(2943, 55.629695892334, 5901), CastPos = Vector(2943, 55.629695892334, 5901)},
    {From = Vector(3894.1960449219, 53.4684715271, 7192.3720703125),  To = Vector(3641, 54.714691162109, 7495), CastPos = Vector(3641, 54.714691162109, 7495)},
    {From = Vector(3397, 55.605663299561, 6515),  To = Vector(3363, 53.412925720215, 6889), CastPos = Vector(3363, 53.412925720215, 6889)},
    {From = Vector(3347, 53.312397003174, 6865),  To = Vector(3343, 55.605716705322, 6491), CastPos = Vector(3343, 55.605716705322, 6491)},
    {From = Vector(3705, 53.67945098877, 7829),  To = Vector(4009, 51.996047973633, 8049), CastPos = Vector(4009, 51.996047973633, 8049)},
    {From = Vector(7581, -65.361351013184, 5983),  To = Vector(7417, 54.716590881348, 5647), CastPos = Vector(7417, 54.716590881348, 5647)},
    {From = Vector(7495, 53.744125366211, 5753),  To = Vector(7731, -64.48851776123, 6045), CastPos = Vector(7731, -64.48851776123, 6045)},
    {From = Vector(7345, -52.344753265381, 6165),  To = Vector(7249, 55.641929626465, 5803), CastPos = Vector(7249, 55.641929626465, 5803)},
    {From = Vector(7665.0073242188, 54.999004364014, 5645.7431640625),  To = Vector(7997, -62.778995513916, 5861), CastPos = Vector(7997, -62.778995513916, 5861)},
    {From = Vector(7995, -61.163398742676, 5715),  To = Vector(7709, 56.321662902832, 5473), CastPos = Vector(7709, 56.321662902832, 5473)},
    {From = Vector(8653, 55.073780059814, 4441),  To = Vector(9027, -61.594711303711, 4425), CastPos = Vector(9027, -61.594711303711, 4425)},
    {From = Vector(8931, -62.612571716309, 4375),  To = Vector(8557, 55.506855010986, 4401), CastPos = Vector(8557, 55.506855010986, 4401)},
    {From = Vector(8645, 55.960289001465, 4115),  To = Vector(9005, -63.280235290527, 4215), CastPos = Vector(9005, -63.280235290527, 4215)},
    {From = Vector(8948.08203125, -63.252712249756, 4116.5078125),  To = Vector(8605, 56.22159576416, 3953), CastPos = Vector(8605, 56.22159576416, 3953)},
    {From = Vector(9345, 67.37971496582, 2815),  To = Vector(9375, 67.509948730469, 2443), CastPos = Vector(9375, 67.509948730469, 2443)},
    {From = Vector(9355, 67.649841308594, 2537),  To = Vector(9293, 63.953853607178, 2909), CastPos = Vector(9293, 63.953853607178, 2909)},
    {From = Vector(8027, 56.071315765381, 3029),  To = Vector(8071, 54.276405334473, 2657), CastPos = Vector(8071, 54.276405334473, 2657)},
    {From = Vector(7995.0229492188, 54.276401519775, 2664.0703125),  To = Vector(7985, 55.659393310547, 3041), CastPos = Vector(7985, 55.659393310547, 3041)},
    {From = Vector(5785, 54.918552398682, 5445),  To = Vector(5899, 51.673694610596, 5089), CastPos = Vector(5899, 51.673694610596, 5089)},
    {From = Vector(5847, 51.673683166504, 5065),  To = Vector(5683, 54.923862457275, 5403), CastPos = Vector(5683, 54.923862457275, 5403)},
    {From = Vector(6047, 51.67359161377, 4865),  To = Vector(6409, 51.673400878906, 4765), CastPos = Vector(6409, 51.673400878906, 4765)},
    {From = Vector(6347, 51.673400878906, 4765),  To = Vector(5983, 51.673580169678, 4851), CastPos = Vector(5983, 51.673580169678, 4851)},
    {From = Vector(6995, 55.738128662109, 5615),  To = Vector(6701, 61.461639404297, 5383), CastPos = Vector(6701, 61.461639404297, 5383)},
    {From = Vector(6697, 61.083110809326, 5369),  To = Vector(6889, 55.628131866455, 5693), CastPos = Vector(6889, 55.628131866455, 5693)},
    {From = Vector(11245, -62.793098449707, 4515),  To = Vector(11585, 52.104347229004, 4671), CastPos = Vector(11585, 52.104347229004, 4671)},
    {From = Vector(11491.91015625, 52.506042480469, 4629.763671875),  To = Vector(11143, -63.063579559326, 4493), CastPos = Vector(11143, -63.063579559326, 4493)},
    {From = Vector(11395, -62.597496032715, 4315),  To = Vector(11579, 51.962089538574, 4643), CastPos = Vector(11579, 51.962089538574, 4643)},
    {From = Vector(11245, 53.017200469971, 4915),  To = Vector(10869, -63.132637023926, 4907), CastPos = Vector(10869, -63.132637023926, 4907)},
    {From = Vector(10923.66015625, -63.288948059082, 4853.9931640625),  To = Vector(11295, 53.402942657471, 4913), CastPos = Vector(11295, 53.402942657471, 4913)},
    {From = Vector(10595, 54.870422363281, 6965),  To = Vector(10351, 55.198459625244, 7249), CastPos = Vector(10351, 55.198459625244, 7249)},
    {From = Vector(10415, 55.269580841064, 7277),  To = Vector(10609, 54.870502471924, 6957), CastPos = Vector(10609, 54.870502471924, 6957)},
    {From = Vector(12645, 53.343021392822, 4615),  To = Vector(12349, 56.222766876221, 4849), CastPos = Vector(12349, 56.222766876221, 4849)},
    {From = Vector(12395, 52.525123596191, 4765),  To = Vector(12681, 53.853294372559, 4525), CastPos = Vector(12681, 53.853294372559, 4525)},
    {From = Vector(11918.497070313, 57.399909973145, 5471),  To = Vector(11535, 54.801097869873, 5471), CastPos = Vector(11535, 54.801097869873, 5471)},
    {From = Vector(11593, 54.610706329346, 5501),  To = Vector(11967, 56.541202545166, 5477), CastPos = Vector(11967, 56.541202545166, 5477)},
    {From = Vector(11140.984375, 65.858421325684, 8432.9384765625),  To = Vector(11487, 53.453464508057, 8625), CastPos = Vector(11487, 53.453464508057, 8625)},
    {From = Vector(11420.7578125, 53.453437805176, 8608.6923828125),  To = Vector(11107, 65.090522766113, 8403), CastPos = Vector(11107, 65.090522766113, 8403)},
    {From = Vector(11352.48046875, 57.916156768799, 8007.10546875),  To = Vector(11701, 55.458843231201, 8165), CastPos = Vector(11701, 55.458843231201, 8165)},
    {From = Vector(11631, 55.45885848999, 8133),  To = Vector(11287, 58.037368774414, 7979), CastPos = Vector(11287, 58.037368774414, 7979)},
    {From = Vector(10545, 65.745803833008, 7913),  To = Vector(10555, 55.338600158691, 7537), CastPos = Vector(10555, 55.338600158691, 7537)},
    {From = Vector(10795, 55.354972839355, 7613),  To = Vector(10547, 65.771072387695, 7893), CastPos = Vector(10547, 65.771072387695, 7893)},
    {From = Vector(10729, 55.352409362793, 7307),  To = Vector(10785, 54.87170791626, 6937), CastPos = Vector(10785, 54.87170791626, 6937)},
    {From = Vector(10745, 54.871494293213, 6965),  To = Vector(10647, 55.350120544434, 7327), CastPos = Vector(10647, 55.350120544434, 7327)},
    {From = Vector(10099, 66.309921264648, 8443),  To = Vector(10419, 66.106910705566, 8249), CastPos = Vector(10419, 66.106910705566, 8249)},
    {From = Vector(9203, 63.777507781982, 3309),  To = Vector(9359, -63.260040283203, 3651), CastPos = Vector(9359, -63.260040283203, 3651)},
    {From = Vector(9327, -63.258842468262, 3675),  To = Vector(9185, 65.192367553711, 3329), CastPos = Vector(9185, 65.192367553711, 3329)},
    {From = Vector(10045, 55.140678405762, 6465),  To = Vector(10353, 54.869094848633, 6679), CastPos = Vector(10353, 54.869094848633, 6679)},
    {From = Vector(10441.002929688, 65.793014526367, 8315.2333984375),  To = Vector(10133, 64.52165222168, 8529), CastPos = Vector(10133, 64.52165222168, 8529)},
    {From = Vector(8323, 54.89501953125, 9137),  To = Vector(8207, 53.530456542969, 9493), CastPos = Vector(8207, 53.530456542969, 9493)},
    {From = Vector(8295, 53.530418395996, 9363),  To = Vector(8359, 54.895038604736, 8993), CastPos = Vector(8359, 54.895038604736, 8993)},
    {From = Vector(8495, 52.768348693848, 9763),  To = Vector(8401, 53.643203735352, 10125), CastPos = Vector(8401, 53.643203735352, 10125)},
    {From = Vector(8419, 53.59920501709, 9997),  To = Vector(8695, 51.417175292969, 9743), CastPos = Vector(8695, 51.417175292969, 9743)},
    {From = Vector(7145, 55.597702026367, 5965),  To = Vector(7413, -66.513969421387, 6229), CastPos = Vector(7413, -66.513969421387, 6229)},
    {From = Vector(6947, 56.01900100708, 8213),  To = Vector(6621, -62.816535949707, 8029), CastPos = Vector(6621, -62.816535949707, 8029)},
    {From = Vector(6397, 54.634998321533, 10813),  To = Vector(6121, 54.092365264893, 11065), CastPos = Vector(6121, 54.092365264893, 11065)},
    {From = Vector(6247, 54.6325340271, 11513),  To = Vector(6053, 39.563938140869, 11833), CastPos = Vector(6053, 39.563938140869, 11833)},
    {From = Vector(4627, 41.618049621582, 11897),  To = Vector(4541, 51.561706542969, 11531), CastPos = Vector(4541, 51.561706542969, 11531)},
    {From = Vector(5179, 53.036727905273, 10839),  To = Vector(4881, -63.11701965332, 10611), CastPos = Vector(4881, -63.11701965332, 10611)},
    {From = Vector(4897, -63.125648498535, 10613),  To = Vector(5177, 52.773872375488, 10863), CastPos = Vector(5177, 52.773872375488, 10863)},
    {From = Vector(11367, 50.348838806152, 9751),  To = Vector(11479, 106.51720428467, 10107), CastPos = Vector(11479, 106.51720428467, 10107)},
    {From = Vector(11489, 106.53769683838, 10093),  To = Vector(11403, 50.349449157715, 9727), CastPos = Vector(11403, 50.349449157715, 9727)},
    {From = Vector(12175, 106.80973052979, 9991),  To = Vector(12143, 50.354927062988, 9617), CastPos = Vector(12143, 50.354927062988, 9617)},
    {From = Vector(12155, 50.354919433594, 9623),  To = Vector(12123, 106.81489562988, 9995), CastPos = Vector(12123, 106.81489562988, 9995)},
    {From = Vector(9397, 52.484146118164, 12037),  To = Vector(9769, 106.21959686279, 12077), CastPos = Vector(9769, 106.21959686279, 12077)},
    {From = Vector(9745, 106.2202835083, 12063),  To = Vector(9373, 52.484580993652, 12003), CastPos = Vector(9373, 52.484580993652, 12003)},
    {From = Vector(9345, 52.689178466797, 12813),  To = Vector(9719, 106.20919799805, 12805), CastPos = Vector(9719, 106.20919799805, 12805)},
    {From = Vector(4171, 109.72004699707, 2839),  To = Vector(4489, 54.030017852783, 3041), CastPos = Vector(4489, 54.030017852783, 3041)},
    {From = Vector(4473, 54.04020690918, 3009),  To = Vector(4115, 110.06342315674, 2901), CastPos = Vector(4115, 110.06342315674, 2901)},
    {From = Vector(2669, 105.9382019043, 4281),  To = Vector(2759, 57.061370849609, 4647), CastPos = Vector(2759, 57.061370849609, 4647)},
    {From = Vector(2761, 57.062965393066, 4653),  To = Vector(2681, 106.2310256958, 4287), CastPos = Vector(2681, 106.2310256958, 4287)},
    {From = Vector(1623, 108.56233215332, 4487),  To = Vector(1573, 56.13228225708, 4859), CastPos = Vector(1573, 56.13228225708, 4859)},
    {From = Vector(1573, 56.048126220703, 4845),  To = Vector(1589, 108.56234741211, 4471), CastPos = Vector(1589, 108.56234741211, 4471)},
    {From = Vector(2355.4450683594, 60.167724609375, 6366.453125),  To = Vector(2731, 54.617771148682, 6355), CastPos = Vector(2731, 54.617771148682, 6355)},
    {From = Vector(2669, 54.488224029541, 6363),  To = Vector(2295, 60.163955688477, 6371), CastPos = Vector(2295, 60.163955688477, 6371)},
    {From = Vector(2068.5336914063, 54.921718597412, 8898.5322265625),  To = Vector(2457, 53.765918731689, 8967), CastPos = Vector(2457, 53.765918731689, 8967)},
    {From = Vector(2447, 53.763805389404, 8913),  To = Vector(2099, 54.922241210938, 8775), CastPos = Vector(2099, 54.922241210938, 8775)},
    {From = Vector(1589, 49.631057739258, 9661),  To = Vector(1297, 38.928337097168, 9895), CastPos = Vector(1297, 38.928337097168, 9895)},
    {From = Vector(1347, 39.538192749023, 9813),  To = Vector(1609, 50.499561309814, 9543), CastPos = Vector(1609, 50.499561309814, 9543)},
    {From = Vector(3997, -63.152000427246, 10213),  To = Vector(3627, -64.785446166992, 10159), CastPos = Vector(3627, -64.785446166992, 10159)},
    {From = Vector(3709, -63.07014465332, 10171),  To = Vector(4085, -63.139434814453, 10175), CastPos = Vector(4085, -63.139434814453, 10175)},
    {From = Vector(9695, 106.20919799805, 12813),  To = Vector(9353, 95.629013061523, 12965), CastPos = Vector(9353, 95.629013061523, 12965)},
    {From = Vector(5647, 55.136940002441, 9563),  To = Vector(5647, -65.224411010742, 9187), CastPos = Vector(5647, -65.224411010742, 9187)},
    {From = Vector(2315, 108.66681671143, 4377),  To = Vector(2403, 56.444217681885, 4743), CastPos = Vector(2403, 56.444217681885, 4743)},
    {From = Vector(10345, 54.86909866333, 6665),  To = Vector(10009, 55.126476287842, 6497), CastPos = Vector(10009, 55.126476287842, 6497)},
    {From = Vector(12419, 54.801849365234, 6119),  To = Vector(12787, 57.748607635498, 6181), CastPos = Vector(12787, 57.748607635498, 6181)},
    {From = Vector(12723, 57.326282501221, 6253),  To = Vector(12393, 54.80948638916, 6075), CastPos = Vector(12393, 54.80948638916, 6075)},

  }

}

function OnLoad()
  vars()
  menu()
  drawtable()
end

function vars()
  VP = VPrediction()
  ts = TargetSelector(TARGET_LOW_HP, 1250, DAMAGE_MAGIC, true)
  Qready = false
  Wready = false
  Eready = false
  Rready = false
  _G.oldDrawCircle = rawget(_G, 'DrawCircle')
  _G.DrawCircle = DrawCircle2
  hunting = false
  sow = SOW(VP)
  sow:RegisterOnAttackCallback(CastOnAttackW)
  Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
  jungleMinions = minionManager(MINION_JUNGLE, 800, myHero, MINION_SORT_MAXHEALTH_DEC)
  enemyMinions = minionManager(MINION_ENEMY, 800, myHero, MINION_SORT_HEALTH_ASC)
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

function menu()
  m = scriptConfig("[Fisherman Fizz]", "FishermanFizz")

  m:addSubMenu("[Key Manager]", "keysettings")  
  m.keysettings:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
  m.keysettings:addParam("jumpkey", "Perfect Jump", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("Y"))
  m.keysettings:addParam("junglekey", "Clear", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("V"))
  m.keysettings:addParam("forcer", "Force Ultimate Cast", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("C"))
  
  m:addSubMenu("[Combo Manager]", "combosettings")
  m.combosettings:addParam("useq", "Use Urchin Strike / Q", SCRIPT_PARAM_ONOFF, true)
  m.combosettings:addParam("usew", "Use Seastone Trident / W", SCRIPT_PARAM_ONOFF, true)
  m.combosettings:addParam("usewaa", "Use W only OnAttack", SCRIPT_PARAM_ONOFF, false)
  m.combosettings:addParam("usee", "Use Playful&Trickster / E", SCRIPT_PARAM_ONOFF, true)
  m.combosettings:addParam("edelay", "Trickster Delay", SCRIPT_PARAM_SLICE, 1, 0.2, 0.7, 2)
  m.combosettings:addParam("usei", "Use Ignite for Hard Combo", SCRIPT_PARAM_ONOFF, true)
  m.combosettings:addParam("magnet", "Stick to Target", SCRIPT_PARAM_ONOFF, false)

  m:addSubMenu("[Ultimate Manager]", "ultisettings")
  m.ultisettings:addParam("user", "Use Chum the Waters / R", SCRIPT_PARAM_ONOFF, true)
  m.ultisettings:addParam("rrcast", "Target Range", SCRIPT_PARAM_LIST, 1, {"Full", "Mid", "Close" })
  
  m:addSubMenu("[Item Manager]", "items")
  m.items:addParam("useitems", "Use Items", SCRIPT_PARAM_LIST, 1, {"Combo", "Always", "Never" })
  m.items:addParam("platzhalter", "", 5, "")
  m.items:addParam("apitemsinfo", "--- AP Items ---", 5, "")
  m.items:addParam("dfg", "Use Deathfire Grasp", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("bft", "Use Blackfire Torch", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("platzhalter", "", 5, "")
  m.items:addParam("hybriditemsinfo", "--- Hybrid Items ---", 5, "")
  m.items:addParam("hg", "Use Hextech Gunblade", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("hybriditemsinfo", "--- AD Items ---", 5, "")
  m.items:addParam("yg", "Use Youmuu's Ghostblade", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("blade", "Use Blade of the Ruined King", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("cutlass", "Use Bilgewater Cutlass", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("sod", "Use Sword of the Divine", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("platzhalter", "", 5, "")
  m.items:addParam("supportitemsinfo", "--- Support Items ---", 5, "")
  m.items:addParam("fqc", "Use Frost Queen's Claim", SCRIPT_PARAM_ONOFF, true)
  m.items:addParam("platzhalter", "", 5, "")
  m.items:addParam("hybriditemsinfo", "--- Defensive Items ---", 5, "")
  m.items:addParam("enableautozhonya", "Auto Zhonya's", SCRIPT_PARAM_ONOFF, false)
  m.items:addParam("autozhonya", "Use Zhonya's if Health under -> %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
  
  m:addSubMenu("[Killsteal Manager]", "ks")
  m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
  m.ks:addParam("useq", "Use Urchin Strike / Q", SCRIPT_PARAM_ONOFF, true)
  m.ks:addParam("usew", "Use Seastone Trident / W", SCRIPT_PARAM_ONOFF, true)
  m.ks:addParam("usee", "Use Playful&Trickster / E", SCRIPT_PARAM_ONOFF, true)
  m.ks:addParam("user", "Use Chum the Waters / R", SCRIPT_PARAM_ONOFF, false)

  m:addSubMenu("[Clear Manager]", "c")
  m.c:addParam("useq", "Use Urchin Strike / Q", SCRIPT_PARAM_ONOFF, true)
  m.c:addParam("usew", "Use Seastone Trident / W", SCRIPT_PARAM_ONOFF, true)
  m.c:addParam("usee", "Use Playful&Trickster / E", SCRIPT_PARAM_ONOFF, true)
  
  m:addSubMenu("[Drawings]", "draw")
  m.draw:addParam("drawq", "Draw Urchin Strike / Q Range", SCRIPT_PARAM_ONOFF, false)
  m.draw:addParam("drawe", "Draw Playful&Trickster / E Range", SCRIPT_PARAM_ONOFF, false)
  m.draw:addParam("drawr", "Draw Chum the Waters / R Range", SCRIPT_PARAM_ONOFF, false)
  m.draw:addParam("drawaa", "Draw AA Range", SCRIPT_PARAM_ONOFF, false)
  m.draw:addParam("drawspot", "Draw close Jumpspots", SCRIPT_PARAM_ONOFF, false)

  m:addSubMenu("[Additionals]", "vip")
  m.vip:addParam("LagFree", "Activate Lag Free Circles", 1, false)
  m.vip:addParam("CL", "Length before snapping", 4, 75, 75, 2000, 0)
  m.vip:addParam("CLinfo", "The lower your length the better system you need", 5, "")

  m:addSubMenu("[Orbwalker]", "orbwalk")
  sow:LoadToMenu(m.orbwalk)
  
  m:addTS(ts)
  ts.name = "Fishing"
  
  --m:addParam("circlesize", "circle size", SCRIPT_PARAM_SLICE, 75, 1, 200)
  --m:addParam("procrange", "proc range", SCRIPT_PARAM_SLICE, 50, 1, 200)
  PrintChat ("<font color='#FF9A00'>[Fisherman Fizz] by DeadDevil2 Loaded! </font>")
end
                               
function OnTick()
  ts:update()
  Target = ts.target
  checks()
  Combo()
  autozhonya()
  LFC()
  Items()
  PerfectJump()
  Targetmagnet()
  Killsteal()
  TargetDistance()
  JungleClear()
  Clear()
  Killtext()
end

function Targetmagnet()
  if m.keysettings.combokey and ValidTarget(Target, 250) and m.combosettings.magnet then
    local dist = GetDistanceSqr(Target)
    if dist < 250^2 and dist > 80^2 then 
        stayclose(Target, true)
    elseif dist <= 80^2 then
      stayclose(Target, false)
    end
  end
end

function stayclose(unit, mode)
  if mode then
    local myVector = Vector(myHero.x, myHero.y, myHero.z)
    local TargetVector = Vector(unit.x, unit.y, unit.z)
    local orbwalkPoint1 = TargetVector + (myVector-TargetVector):normalized()*100
    local orbwalkPoint2 = TargetVector - (myVector-TargetVector):normalized()*100
    if GetDistanceSqr(orbwalkPoint1) < GetDistanceSqr(orbwalkPoint2) then
      sow:OrbWalk(unit, orbwalkPoint1)
    else
      sow:OrbWalk(unit, orbwalkPoint2)
    end
  else
    sow:OrbWalk(unit, myHero)
  end
end

function checks()
  Qready = (myHero:CanUseSpell(_Q) == READY)
  Wready = (myHero:CanUseSpell(_W) == READY)
  Eready = (myHero:CanUseSpell(_E) == READY)
  Rready = (myHero:CanUseSpell(_R) == READY)
  Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function LFC()
  if not m.vip.LagFree then _G.DrawCircle = _G.oldDrawCircle end
  if m.vip.LagFree then
    _G.DrawCircle = DrawCircle2
  end
end

function autozhonya()
  if m.items.enableautozhonya then
    if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157)
    end
  end
end

function Killtext()
    for i = 1, enemyCount do
        local enemy = enemyTable[i].player
        if ValidTarget(enemy) and enemy.visible then
             
        local Qdmg      = getDmg("Q", enemy, myHero)
        local Wdmg      = getDmg("W", enemy, myHero)
        local Edmg      = getDmg("E", enemy, myHero)
        local Rdmg      = getDmg("R", enemy, myHero)
        local Idmg      = getDmg("IGNITE", enemy, myHero)
        local DFGdmg    = getDmg("DFG", enemy, myHero)

        --if Qready and Wready and Eready and Rready and DFGready then

        local FullDMG   = 0.2*(Qdmg+Wdmg+Edmg+Rdmg)+DFGdmg

            if      enemy.health > FullDMG  then enemyTable[i].indicatorText = "Not Killable"
            elseif  enemy.health < FullDMG  then enemyTable[i].indicatorText = "Hard Combo Kill" 
            end
        end
    end
end



function Combo()
  if not Target then 
    return 
  end
  if m.keysettings.combokey then
    if Qdis then CastQ() end 
    if Edis then CastE() end
    if m.ultisettings.rrcast == 1 then
      if Rdis then CastR() end
    elseif m.ultisettings.rrcast == 2 then
      if Edis then CastR() end
    elseif m.ultisettings.rrcast == 3 then
      if Qdis then CastR() end
    end
  end
end

function TargetDistance()
  if ValidTarget(Target) then
  local tdis    = GetDistance(Target)
  Qdis  = tdis < 500
  Edis  = tdis < 700
  Ddis  = tdis < 750
  Rdis  = tdis < 1275
  AAdis = tdis < 125 
  end
end

function CastOnAttackW()
  if Wready and ValidTarget(Target) then CastSpell(_W) end 
end

function CastQ()
  if Qready and ValidTarget(Target, Qrange) then
    CastSpell(_Q, Target) 
    if not wactive and not m.combosettings.usewaa then CastSpell(_W) end
  end
end

function prexcheck()
if ValidTarget(Target) == nil or not Edis then prex = true end
end

function CastE()
prexcheck()
  if prex and Eready and Edis and ValidTarget(Target) then
    prex = false
    CastSpell(_E, Target.x, Target.z)               
    DelayAction(function()    
    local pos, info = Prodiction.GetCircularAOEPrediction(Target, Erange, Espeed, Edelay, Ewidth)
      if not prex and pos and info.hitchance ~= 0 then      
        CastSpell(_E, pos.x, pos.z)            
        prex = true
      else
        prex = true
      end
    end, m.combosettings.edelay)
  end
end

function getHitBoxRadius(unit)
  return GetDistance(unit, unit.minBBox)
end

function CastR()
  if Rready and ValidTarget(Target, Rrange) then
    local pos, info = Prodiction.GetPrediction(Target, Rrange, Rspeed, Rdelay, Rwidth)
    if pos and info.hitchance >= 1 and GetDistance(pos) - getHitBoxRadius(Target)/2 < 1275 then
      CastSpell(_R, pos.x, pos.z)
    else
      return
    end
  end
end

function OnGainBuff(unit, buff)
    if buff.name == 'FizzSeastonePassive' and unit.isMe then
      wactive = true
    end
end

function OnLoseBuff(unit, buff)
    if buff.name == 'FizzSeastonePassive' and unit.isMe then
        wactive = false
    end
end

function Killsteal()
  for _, enemy in pairs(GetEnemyHeroes()) do
    if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
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
          local pos, info = Prodiction.GetCircularAOEPrediction(jungleMinion, Erange, Espeed, Edelay, Ewidth)
           if pos and info.hitchance ~= 0 then  
            CastSpell(_E)
          end         
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
          local pos, info = Prodiction.GetCircularAOEPrediction(enemyMinion, Erange, Espeed, Edelay, Ewidth)
           if pos and info.hitchance ~= 0 then  
            CastSpell(_E)
          end         
        end
      end
    end
  end
end

function Items()
  if not Target or m.items.useitems == 3 then 
    return 
  end
  if m.keysettings.combokey and (m.items.useitems == 1 and (Qready and Wready or Qready or Eready or Rready) or m.items.useitems == 2) then 
        if ValidTarget(Target, 625) then
        if m.items.dfg then CastItem(3128, Target) end
        if m.items.hg then CastItem(3146, Target) end
        if m.items.yg then CastItem(3142) end
        if m.items.blade then CastItem(3153, Target) end
        if m.items.cutlass then CastItem(3144, Target) end
        if m.items.sod then CastItem(3131) end
        if m.items.fqc  then CastItem(3092, Target.x,Target.z) end
        if m.items.bft then CastItem(3188, Target) end
    end
  end
end
    
function OnWndMsg(Msg, Key)
  if Msg == WM_LBUTTONDOWN and inCircle and GetDistance(currentFrom, mousePos) < 75 then
    proc = true
    DelayAction(function() proc = false end, 0.025) 
  end
end

function PerfectJump()
  if m.keysettings.jumpkey then
    if inCircle and proc and Eready then
      CastSpell(_E, currentTo.x, currentTo.z)
    else
      myHero:MoveTo(mousePos.x, mousePos.z)
    end
  end     
end

function DrawJumpSpots()
  inCircle = false
  currentFrom = nil
  currentTo = nil
  if m.draw.drawspot then
    for i = 1, #JumpSpots['Fizz'], 1 do
      local distFrom = GetDistance(JumpSpots['Fizz'][i].From)
      local distTo = GetDistance(JumpSpots['Fizz'][i].To)
      if distFrom < 1000 then
        DrawCircle2(JumpSpots['Fizz'][i].From.x, JumpSpots['Fizz'][i].From.y, JumpSpots['Fizz'][i].From.z, 75, ARGB(255, 0, 255, 0))
        DrawCircle2(JumpSpots['Fizz'][i].To.x, JumpSpots['Fizz'][i].To.y, JumpSpots['Fizz'][i].To.z, 75, ARGB(255, 0, 255, 0))
      end
        if distFrom < 50 then
        inCircle = true
        currentFrom = JumpSpots['Fizz'][i].From
        currentTo = JumpSpots['Fizz'][i].To
      end
      if distTo < 50 then
        inCircle = true
        currentFrom = JumpSpots['Fizz'][i].To
        currentTo = JumpSpots['Fizz'][i].From
      end
    end
  end
end

function OnDraw()
  DrawJumpSpots()
  Drawings()
  Drawkilltext() 
end

function Drawings()
  if m.draw.drawq then
    DrawCircle(myHero.x, myHero.y, myHero.z, 550, ARGB(255, 255, 255, 255))
  end
  if m.draw.drawe then
    DrawCircle(myHero.x, myHero.y, myHero.z, 700, ARGB(255, 255, 255, 255))
  end
  if m.draw.drawr then
    DrawCircle(myHero.x, myHero.y, myHero.z, 1275, ARGB(255, 255, 255, 255))
  end
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
