function widget:GetInfo()
  return {
    name      = "Dota shop",
    desc      = "Buy creep",
    author    = "N0U",
    date      = "Nov 29, 2012",
    license   = "GNU GPL, v2 or later",
    layer     = -9, 
    enabled   = true  --  loaded by default?
  }
end

if (Spring.GetModOptions().zkmode ~= "dota") then
  return
end

local Chili
 
 --SendToUnsynced -> write in widgetglobal
 --[[
[20:35:47] <Anarchid> 1) get the data in synced context
[20:35:47] <Anarchid> 2) send it to gadget unsynced context
[20:35:47] <Anarchid> 3) in gadget unsynced, filter data for the local player, and write to some gadget-accessible location
[20:35:47] <Anarchid> 4) in widget, process this data and do whatever you want
]]

-- http://code.google.com/p/zero-k/source/diff?spec=svn8389&r=8389&format=side&path=/trunk/mods/zk/LuaRules/Gadgets/start_unit_setup.lua&old_path=/trunk/mods/zk/LuaRules/Gadgets/start_unit_setup.lua&old=8378
-- http://code.google.com/p/zero-k/source/diff?spec=svn7194&r=7194&format=side&path=/trunk/mods/zk/LuaUI/Widgets/gui_take_remind.lua
--[[
local commSeries = msg:sub(12) --get the name of selected commander
806			commChoice[playerID] = name	807			_G.commSeries = commSeries --send comm name to unsynced part. Reference: http://answers.springlobby.info/questions/6/how-do-i-receive-synced-events-in-unsynced-luarules
808			SendToUnsynced("CommSelected",playerID) --activate an event called "CommSelected" that can be detected in unsynced part
809			_G.commSeries = nil --empty this vessel
810			commChoice[playerID] = commSeries --remember this name for spawning commander at "GameStart()"
]]

 -- MEMBERS
local helloWorldLabel
local warriorButton
 
 -- SCRIPT FUNCTIONS
 -- WIDGET CODE
 
local function buyUnit(chiliButton, x, y, button, mods) 
	Spring.SendLuaRulesMsg("dotashop_buy_"..chiliButton.dotashop_unit)
	--Spring.SendLuaGaiaMsg("buy_warrior")
	--Spring.SendCommands("buy_warrior")
end
 
local buttownSize=50

local lastX=10
local lastY=10
local buttons={}

local function newButtonLine()
	lastX=10
	lastY=lastY+buttownSize+5
end

local function dotashop_creepupdate(name,cost,ones)
	--local creep=allyShop.creeps[i]
	local btn=buttons[name]
	if btn==nil then return end
	
	local tooltip="Buy '"..name.."' "
	if ones then
		tooltip=tooltip.."only for one wave"
	end
	
	tooltip=tooltip.."\nCost: "..tostring(cost)
	btn.tooltip=tooltip
end

local function dotashop_defenseupdate(lvl,cost)
	local btn=buttons["defense"]
	local tooltip
	if cost==0 then
		tooltip="You improved protection to the maximum"
	else
		tooltip="Next level: "..tostring(lvl).."\nCost: "..tostring(cost)
	end
	
	btn.tooltip=tooltip
end

local function dotashop_comupdate(name,lvl,cost)
	local btn=buttons[name]
	if btn==nil then return end
	local tooltip=btn.baseText.."\nCost: "..tostring(cost)
	btn.tooltip=tooltip
end

local function dotashop_storageupdate(size,cost)
	buttons["storage"].tooltip="Next storage size: "..tostring(size).."\nCost: "..tostring(cost)
end


local function addButton(texture,unit,baseText)
	local button  = Chili.Button:New {
			parent = helloWorldWindow,
			x = lastX,
			y = lastY,
			width = buttownSize,
			height = buttownSize,
			padding = {0, 0, 0, 0},
			--margin = {0, 0, 0, 0},
			--minWidth = 40,
			--minHeight = 40,
			isDisabled = false,
			fontsize = 13,
			textColor = {1,1,1,1},
			OnMouseDown = {buyUnit},
			dotashop_unit=unit,
			caption="",
			tooltip="",
			baseText=baseText
	}
	local image= Chili.Image:New {
				x=0,
				y=0,
				width="100%",
				height="100%",
				keepAspect = true,	--isState;
				file = "unitpics/"..texture,
				parent = button,
	}
	
	lastX=lastX+button.width+5
	
	buttons[unit]=button
end

function widget:Initialize()	
 	if (not WG.Chili) then
 		widgetHandler:RemoveWidget()
 		return
 	end
 	
 	widgetHandler:RegisterGlobal("dotashop_creepupdate", dotashop_creepupdate) 
 	widgetHandler:RegisterGlobal("dotashop_defenseupdate", dotashop_defenseupdate)  	
 	widgetHandler:RegisterGlobal("dotashop_comupdate", dotashop_comupdate)  	
 	widgetHandler:RegisterGlobal("dotashop_storageupdate", dotashop_storageupdate)  	
 	
 	
 	Chili      = WG.Chili
 	local screen0 = Chili.Screen0

 	helloWorldWindow = Chili.Window:New{
 		x = '50%',
 		y = '50%',	
 		dockable = true,
 		parent = screen0,
 		caption = "Dota shop",
 		width = 20+7*(buttownSize+5)-5,
 		height = 20+buttownSize*2,
 	--	backgroundColor = {0.8,0.8,0.8,0.9},
 	}	
 	
 	addButton("armwar.png","warrior","Buy Warrir\nCost: 400m")
 	addButton("corak.png","bandit","Buy Glave\nCost: 250m") 	
 	addButton("armzeus.png","zeus","Buy Zeus\nCost: 700m") 	
 		 	
 	--addButton("core_spectre.png","aspis","Buy Aspis\nCost: 1200m") 	
 	addButton("corthud.png","thug","Buy Thug\nCost: 700m") 		
 	addButton("corcrash.png","vandal","Buy Tarantula\nCost: 600m") 		
 	addButton("armkam.png","banshee","Buy Banshee\nCost: 1500m") 	
 	addButton("armsptk.png","recluse","") 	
 	
	newButtonLine()
	addButton("armmstor.png","storage","Increase metal storage\nCost: 80% of the curent storage") 	
	addButton("armanni.png","defense","Update base defense (Max 4 times) \nCost: 300m, 350m, 500m, 750m") 	
	--newButtonLine()
	addButton("armcrabe.png","crabe","Buy Crabe only for one wave\nCost: 1300m") 
	addButton("armbrawl.png","brawler","Buy Brawler only for one wave\nCost: 1500m") 	
	addButton("cormak.png","outlaw","Buy Outlwar only for one wave\nCost: 300m") 
	addButton("dante.png","dante","Buy Outlwar only for one wave\nCost: 300m")
	--newButtonLine()
	addButton("module_dmg_booster.png","attackLvl","Increase commander damage") 
	addButton("module_heavy_armor.png","defLvl","Increase commander defense") 		
	--addButton("module_adv_targeting.png","rangeLvl","Increase commander attack range\nCost: 100 + 100*lvl*lvl") 
	addButton("weaponmod_autoflechette.png","attackSpeedLvl","Increase commander attack speed") 		
	
 end
