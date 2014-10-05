--[[
	Script: Noscope Nidalee v0.17
	Author: DeadDevil2
	v0.1 	Initial release
	v0.2	Added VIP and Additionals
	v0.3	Added Lag Free Circles
	v0.4    Added Formswitch if Hunted
	v0.5    Changed Q Logic
	v0.6    Changed E Logic Added Item Support
	v0.7	Reworked Whole Script
	v0.8    MScript Support & Repo
	v0.9    Fixed Some little Bugs
	v0.10   Added Perfect Jump (seong ho is awesome btw <3
	v0.11   Fixed more bugs...
	v0.12   Fixed Q in Combo
	v0.13   Added Meele Magnet for Cougarform(OP)
	v0.14   Fixed Cougar Q Bugs
	v0.15   Added Some KS Stuff
	v0.16  	Reworked Prodiction Spear Logic
	v0.17 	Fixed the E KS Bug
 _   _                                  _   _ _     _       _           
| \ | |                                | \ | (_)   | |     | |          
|  \| | ___  ___  ___ ___  _ __   ___  |  \| |_  __| | __ _| | ___  ___ 
| . ` |/ _ \/ __|/ __/ _ \| '_ \ / _ \ | . ` | |/ _` |/ _` | |/ _ \/ _ \
| |\  | (_) \__ \ (_| (_) | |_) |  __/ | |\  | | (_| | (_| | |  __/  __/
\_| \_/\___/|___/\___\___/| .__/ \___| \_| \_/_|\__,_|\__,_|_|\___|\___|
                          | |                                           
                          |_| 
                                                         
]]
if not VIP_USER then
    PrintChat(">> VIP Authentication Failed! You are not authorised to run this script. Unloading.<<")
	return
end

if VIP_USER then
	PrintChat(">> VIP Authentication Successful! Loading the VIP Version, please stand by... <<")
end 

if myHero.charName ~= "Nidalee" then
return
end

require 'Collision'
require 'VPrediction'
require 'SOW'
require 'Prodiction'

local Prodict = ProdictManager.GetInstance()
local CastProQ
local coll
local ts = {}
local m = {}
local ignite = nil

local VIP_User
local version = 0.17
local AUTOUPDATE = true
local SCRIPT_NAME = "NoscopeNidalee"
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


Spells = {
        Q = {range = 1400, delay = 0.125, width = 30, speed = 1300},
        W = {range = 900, delay = 0.500, width = 80, speed = 1450},
        E = {range = 600},
        CW = {range = 375},
        ECW = {range = 750},
        CE = {range = 300}
}

local JumpSlot = 
{
	['Nidalee'] = _W,
}

local JumpSpots = 
{
	['Nidalee'] = 
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

local function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

local function CastQ(unit, pos, spell)
	if not COUGARFORM then
	 	if GetDistance(pos) - getHitBoxRadius(unit)/2 < 1500 then 
			local willCollide = coll:GetMinionCollision(pos, myHero)
			if not willCollide then CastSpell(_Q, pos.x, pos.z) end
		end
	else
		return
	end
end
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
	collinfo()
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
	hunting = false
	sow = SOW(VP)
	sow:RegisterOnAttackCallback(CastCougarQ)
	Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil
end

function menu()
	m = scriptConfig("MScripting - Noscope Nidalee", "Noscopenidalee")
	
	m:addSubMenu("Combo Manager", "combosettings")
	m.combosettings:addSubMenu("Humanform Combo", "humancombo")
	m.combosettings.humancombo:addParam("usehq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.humancombo:addParam("usehw", "Use W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addSubMenu("Cougarform Combo", "cougarcombo")
	m.combosettings.cougarcombo:addParam("usecq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.cougarcombo:addParam("usecw", "Use W", SCRIPT_PARAM_ONOFF, true)
	m.combosettings.cougarcombo:addParam("usece", "Use E", SCRIPT_PARAM_ONOFF, true)
	m.combosettings:addParam("platzhalter", "", 5, "")
	m.combosettings:addParam("huntedinfo", "--- Passive Manager ---", 5, "")
	m.combosettings:addParam("autocougar", "Switch to Cougar if target is Hunted", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("Cinfo", "Only switchs if target is in extended Pounce range", 5, "")
	m.combosettings:addParam("platzhalter", "", 5, "")
	m.combosettings:addParam("magetinfo", "--- Meele Magnet ---", 5, "")
	m.combosettings:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, false)
	m.combosettings:addParam("Cinfo", "Only for Cougar in meele Range to avoid aa cancel", 5, "")
	m.combosettings:addParam("Cinfo", "Pls check the Thread for further explanation", 5, "")
	
	m:addSubMenu("Item Manager", "items")
	m.items:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	m.items:addParam("platzhalter", "", 5, "")
	m.items:addParam("apitemsinfo", "--- AP Items ---", 5, "")
	m.items:addParam("dfg", "Deathfire Grasp", SCRIPT_PARAM_LIST, 2, {"Never", "Cougar", "Human", "Always" })
	m.items:addParam("bft", "Blackfire Torch", SCRIPT_PARAM_LIST, 1, {"Never", "Cougar", "Human", "Always" })
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
	
	m:addSubMenu("Heal Manager", "healmanager")
	m.healmanager:addParam("healinfo", "--- Self Heal ---", 5, "")
	m.healmanager:addParam("enableheal", "Auto Heal", SCRIPT_PARAM_ONOFF, true)
	m.healmanager:addParam("heal", "Heal if Health under -> %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	m.healmanager:addParam("platzhalter", "", 5, "")
	m.healmanager:addParam("ahealinfo", "--- Ally Heal ---", 5, "")
	m.healmanager:addParam("platzhalter", "SoonTM <3", 5, "")
	m.healmanager:addParam("platzhalter", "", 5, "")
	m.healmanager:addParam("healswitch", "Switch Forms for Heal", SCRIPT_PARAM_ONOFF, false)
	m:addSubMenu("KS Manager", "ks")
	m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usecq", "Use Cougar Q", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usecw", "Use Cougar W", SCRIPT_PARAM_ONOFF, true)
	m.ks:addParam("usece", "Use Cougar E", SCRIPT_PARAM_ONOFF, true)
	
	m:addSubMenu("Drawings", "draw")
	m.draw:addParam("drawq", "Draw Spear Range", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("drawaa", "Draw AA Range", SCRIPT_PARAM_ONOFF, false)
	m.draw:addParam("drawspot", "Draw close Jumpspots", SCRIPT_PARAM_ONOFF, false)
	m:addSubMenu("VIP Menu", "vip")
	m.vip:addParam("pretype", "--- Spear Prediction ---", 5, "")
	m.vip:addParam("prediction", "Choose Prediction", SCRIPT_PARAM_LIST, 2, {"Vprediction", "Prodiction" })
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("hitchance", "Q Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	m.vip:addParam("hitinfo", "1=low 2=high 3=slowed 4=stunned/rooted", 5, "")
	m.vip:addParam("platzhalter", "", 5, "")
	m.vip:addParam("pretype", "--- Lag Free Circles ---", 5, "")
	m.vip:addParam("LagFree", "Activate Lag Free Circles", 1, false)
	m.vip:addParam("CL", "Length before snapping", 4, 75, 75, 2000, 0)
	m.vip:addParam("CLinfo", "The lower your length the better system you need", 5, "")
	sow:LoadToMenu(m.orbwalk)
	
	m:addTS(ts)
	ts.name = "Noscope"
	
	m:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	m:addParam("escapekey", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	m:addParam("harass", "Toogle Auto Harass with Spears", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
	m:addParam("jumpkey", "Perfect Jump", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("Y"))
	--m:addParam("circlesize", "circle size", SCRIPT_PARAM_SLICE, 75, 1, 200)
	--m:addParam("procrange", "proc range", SCRIPT_PARAM_SLICE, 50, 1, 200)

	PrintChat ("<font color='#FF9A00'>Noscope Nidalee v0.17 by DeadDevil2 Loaded! </font>")
end

function collinfo()
	CastProQ = Prodict:AddProdictionObject(_Q, 1500, 1300, 0.125, 30, myHero, CastQ)
	coll = Collision(1500, 1300, 0.125, 30)
	for I = 1, heroManager.iCount do
		local hero = heroManager:GetHero(I)
		if hero.team ~= myHero.team then
			CastProQ:CanNotMissMode(true, hero)
		end
	end
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
	ts:update()
	target = ts.target
	checks()
	autoheal()
	combo()
	range()
	autozhonya()
	harass()
	harasspro()
	LFC()
	Huntedcheck()
	TargetHunted()
	Items()
	PerfectJump()
	escape()
	targetmagnet()
	Killsteal()
end

function nidadmg(spell, object)
	if spell == "spear" then
		local dist = GetDistance(object)
		local dmg = ((25*(1+(dist/1500)*2)+25*(1+(dist/1500)*2)*myHero:GetSpellData(_Q).level+myHero.ap*(0.4*(1+(dist/1500)*2)))*(100/(100+(object.magicArmor*myHero.magicPenPercent-myHero.magicPen)))
	end
end


function targetmagnet()
    if m.combokey and COUGARFORM and target and m.combosettings.magnet then
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

function checks()
	if myHero:GetSpellData(_Q).name == "Takedown" or myHero:GetSpellData(_W).name == "Pounce" or myHero:GetSpellData(_E).name == "Swipe" then
		COUGARFORM = true
	end
	if myHero:GetSpellData(_Q).name == "JavelinToss" or myHero:GetSpellData(_W).name == "Bushwhack" or myHero:GetSpellData(_E).name == "PrimalSurge" then
		COUGARFORM = false 
	end
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

--[[
 _____           __          _          _                       
|  __ \         / _|        | |        | |                      
| |__) |__ _ __| |_ ___  ___| |_       | |_   _ _ __ ___  _ __  
|  ___/ _ \ '__|  _/ _ \/ __| __|  _   | | | | | '_ ` _ \| '_ \ 
| |  |  __/ |  | ||  __/ (__| |_  | |__| | |_| | | | | | | |_) |
|_|   \___|_|  |_| \___|\___|\__|  \____/ \__,_|_| |_| |_| .__/ 
                                                         | |    
                                                         |_|  
]]

function escape()
	if m.escapekey then
			myHero:MoveTo(mousePos.x, mousePos.z)
		if COUGARFORM then
			if Wready then
				CastSpell(_W, mousePos.x, mousePos.z)
			end
		elseif Rready then
			CastSpell(_R)
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

function TargetHunted(unit)
 return TargetHaveBuff('nidaleepassivehunted', unit)
end

function OnGainBuff(unit, buff)
    if buff.name == 'nidaleepassivehunting' and unit.isMe then
    	hunting = true
    end
end

function OnLoseBuff(unit, buff)
    if buff.name == 'nidaleepassivehunting' and unit.isMe then
        hunting = false
    end
end

function Huntedcheck()
	if hunting then
		if not COUGARFORM then
			if m.combosettings.autocougar and m.combokey and target and ValidTarget(target, 650) and TargetHunted(target) and Rready then
				CastSpell(_R)
			end	
		end
	else
	return
	end
end

function LFC()
	if not m.vip.LagFree then _G.DrawCircle = _G.oldDrawCircle end
	if m.vip.LagFree then
		_G.DrawCircle = DrawCircle2
	end
end

function range()
	ts:update()
	if COUGARFORM then
		ts.range = 700
	else
	    ts.range = 1500
	end
end

function autoheal()
	if not COUGARFORM then
		if m.healmanager.enableheal and Eready and myHero.health <= (myHero.maxHealth * m.healmanager.heal / 100) then
			CastSpell (_E)
		
		end
	elseif Rready and m.healmanager.healswitch and m.healmanager.enableheal and myHero.health <= (myHero.maxHealth * m.healmanager.heal / 100) then
		CastSpell (_R)
		
	end
end
	
function autozhonya()
	if m.items.enableautozhonya then
		if myHero.health <= (myHero.maxHealth * m.items.autozhonya / 100) then CastItem(3157)
		end
	end
end

function CastCougarQ()
	if m.combokey and Qready and m.combosettings.cougarcombo.usecq and target and ValidTarget(target) then CastSpell(_Q) end 
end
--[[
  _____                _           
 / ____|              | |          
| |     ___  _ __ ___ | |__   ___  
| |    / _ \| '_ ` _ \| '_ \ / _ \ 
| |___| (_) | | | | | | |_) | (_) |
 \_____\___/|_| |_| |_|_.__/ \___/ 
 ]]                                                                 
function combo()
	if not target then 
		return 
	end
	if m.combokey then 
		if COUGARFORM then
			---- Cast Spell Q
		--	if Qready and m.combosettings.cougarcombo.usecq then
		--		sow:RegisterOnAttackCallback(CastCougarQ)
		--	end
			---- Cast Spell E
			if Eready and target and GetDistance(target) < Spells.CE.range and m.combosettings.cougarcombo.usece then
				CastSpell(_E, target.x, target.z)
			end
			---- Cast Spell W
			if Wready and target and ValidTarget(target) and GetDistance(target) > 160 and m.combosettings.cougarcombo.usecw then
				CastSpell(_W, target.x, target.z)
				
			end
			---- HUMANFORM NOW
		else
			---- Cast Spell Q Vprediction
			if m.vip.prediction == 1 then
				if Qready and ValidTarget(target, 1400) and target and m.combosettings.humancombo.usehq then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 30, 1400, 1300, myHero, true)
					if HitChance >= m.vip.hitchance and GetDistance(target) <= 1400 then 
						CastSpell(_Q, CastPosition.x, CastPosition.z)
					end
				end
			end
			---- Cast Spell Q Prodiction
			if m.vip.prediction == 2 then
				if Qready and target and ValidTarget(target, 1400) and m.combosettings.humancombo.usehq then
					local pos, info = Prodiction.GetPrediction(target, 1500, 1300, 0.125, 30, myHero)
					if pos then
						CastProQ:EnableTarget(target, true)
					end
				end
			end
			---- Cast Spell W
			if Wready and m.combosettings.humancombo.usehw then 
				CastSpell(_W, target)
			end
		end
	end
end


function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
		end
		if COUGARFORM and m.ks.usecq and ValidTarget(enemy, 250) then
			local QDmg = getDmg('QM', enemy, myHero) or 0
			if Qready and enemy.health <= QDmg then -- fuck getdmg srsly
				CastSpell(_Q)
				myHero:Attack(enemy)
			end
		end
		if COUGARFORM and m.ks.usece and ValidTarget(enemy, 310) then
			local EDmg = getDmg('EM', enemy, myHero) or 0
			if Eready and enemy.health <= EDmg then
				CastSpell(_E, enemy.x, enemy.z)
			end
		end
		if COUGARFORM and m.ks.usecw and ValidTarget(enemy, 400) then
			local WDmg = getDmg('WM', enemy, myHero) or 0
			if Wready and enemy.health <= WDmg then
				CastSpell(_W, enemy.x, enemy.z)
			end
		end
	end	
end


function Items()
	if not target then 
		return 
	end
	if m.combokey and m.items.useitems then 
		if COUGARFORM then
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
		elseif ValidTarget(target, 525) then
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
		
--[[	
 _                             
| |                            
| |__   __ _ _ __ __ _ ___ ___ 
| '_ \ / _` | '__/ _` / __/ __|
| | | | (_| | | | (_| \__ \__ \
|_| |_|\__,_|_|  \__,_|___/___/

 ]]                             
                               
function harass()
	if not target then return end
	if m.vip.prodiction == 2 then return end
	if not COUGARFORM then
	    if m.harass then
			--- Cast Spell Q
			if Qready and ValidTarget(target, 1400) and target and m.harass then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 30, 1400, 1300, myHero, true)
				if HitChance >= m.vip.hitchance and GetDistance(target) <= 1400 then 
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end		
			end
		end
	end
end

function harasspro()
	if not target then return end
	if not COUGARFORM then
	    if m.harass and m.vip.prodiction == 2 then
		---- Cast Spell Q FUNCTION
			if Qready and target and m.harass then
				CastProQ:EnableTarget(target, true)
			end
		end
	end
end

local inCircle = false
local currentFrom = nil
local currentTo = nil
local proc = false

function OnWndMsg(Msg, Key)
    	if Msg == WM_LBUTTONDOWN and inCircle and GetDistance(currentFrom, mousePos) < 75 then
		proc = true
		DelayAction(function() proc = false end, 0.025) 
	end
end

function PerfectJump()
	if m.jumpkey then
		if not COUGARFORM and Rready then
			CastSpell(_R)
		end
		if inCircle and proc and Wready then
			CastSpell(_W, currentTo.x, currentTo.z)
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
		for i = 1, #JumpSpots['Nidalee'], 1 do
			local distFrom = GetDistance(JumpSpots['Nidalee'][i].From)
			local distTo = GetDistance(JumpSpots['Nidalee'][i].To)
			if distFrom < 1000 then
				DrawCircle2(JumpSpots['Nidalee'][i].From.x, JumpSpots['Nidalee'][i].From.y, JumpSpots['Nidalee'][i].From.z, 75, ARGB(255, 0, 255, 0))
				DrawCircle2(JumpSpots['Nidalee'][i].To.x, JumpSpots['Nidalee'][i].To.y, JumpSpots['Nidalee'][i].To.z, 75, ARGB(255, 0, 255, 0))
			end
				if distFrom < 50 then
				inCircle = true
				currentFrom = JumpSpots['Nidalee'][i].From
				currentTo = JumpSpots['Nidalee'][i].To
			end
			if distTo < 50 then
				inCircle = true
				currentFrom = JumpSpots['Nidalee'][i].To
				currentTo = JumpSpots['Nidalee'][i].From
			end
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
	DrawJumpSpots()
	Drawings()
end

function Drawings()
if m.draw.drawq and not COUGARFORM then
	DrawCircle(myHero.x, myHero.y, myHero.z, 1400, ARGB(255, 255, 255, 255))
end
if m.draw.drawaa and not COUGARFORM then
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
