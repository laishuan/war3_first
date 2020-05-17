-- config.lua

local config = {}

config.isDevleping = true
config.pathRead = "D:/workspace_war3/war3_first/tools/slk.csv"
config.pathWrite = "D:/workspace_war3/war3_first/tools/AutoSLK.lua"
config.pathKeys = "D:/workspace_war3/war3_first/tools/keys.csv"

config.unitKeys = {"AGI","AGIplus","Art","Attachmentanimprops","Awakentip","Buttonpos_1","Buttonpos_2","Farea1","Farea2","HP","Harea1","Harea2","Hfact1","Hfact2","Hotkey","INT","INTplus","LoopingSoundFadeIn","LoopingSoundFadeOut","MissileHoming_1","MissileHoming_2","Missilearc_1","Missilearc_2","Missileart_1","Missilespeed_1","Missilespeed_2","Name","Primary","Propernames","Qarea1","Qarea2","Qfact1","Qfact2","Requirescount","Revive","Revivetip","RngBuff1","RngBuff2","STR","STRplus","ScoreScreenIcon","Specialart","abilList","acquire","armor","atkType1","atkType2","auto","backSw1","backSw2","bldtm","blend","blue","bountydice","bountyplus","bountysides","buffRadius","buffType","buildingShadow","campaign","canBuildOn","canFlee","canSleep","cargoSize","castbsw","castpt","collision","cool1","cool2","customTeamColor","damageLoss1","damageLoss2","death","deathType","def","defType","defUp","dice1","dice2","dmgUp1","dmgUp2","dmgplus1","dmgplus2","dmgpt1","dmgpt2","dropItems","elevPts","elevRad","fatLOS","file","fileVerFlags","fmade","fogRad","formation","fused","goldRep","goldcost","green","heroAbilList","hideHeroBar","hideHeroDeathMsg","hideHeroMinimap","hideOnMinimap","hostilePal","impactSwimZ","impactZ","inEditor","isBuildOn","isbldg","launchSwimZ","launchX","launchY","launchZ","level","lumberRep","lumberbountydice","lumberbountyplus","lumberbountysides","lumbercost","mana0","manaN","maxPitch","maxRoll","maxSpd","minRange","minSpd","modelScale","moveFloor","moveHeight","movetp","nameCount","nbmmIcon","nbrandom","nsight","occH","orientInterp","pathTex","points","preventPlace","prio","propWin","race","rangeN1","rangeN2","red","regenHP","regenMana","regenType","reptm","repulse","repulseGroup","repulseParam","repulsePrio","requirePlace","requireWaterRadius","run","scale","scaleBull","selCircOnWater","selZ","shadowH","shadowOnWater","shadowW","shadowX","shadowY","showUI1","showUI2","sides1","sides2","sight","spd","special","spillDist1","spillDist2","spillRadius1","spillRadius2","splashTargs1","splashTargs2","stockMax","stockRegen","stockStart","targCount1","targCount2","targType","targs1","targs2","teamColor","tilesetSpecific","tilesets","turnRate","type","uberSplat","unitShadow","unitSound","upgrades","useClickHelper","walk","weapTp1","weapTp2","weapType1","weapType2","weapsOn","DependencyOr","Requires1","Requires2","Tip","Ubertip","Attachmentlinkprops","Boneprops","EditorSuffix","animProps","MovementSoundLabel","Requires","BuildingSoundLabel","Researches","Trains","Targetart","Missileart_2","Casterupgradeart","Casterupgradename","Casterupgradetip","Makeitems","Description","Upgrade","Builds","Sellunits","Sellitems","RandomSoundLabel"}
config.itemKeys = {"Art","Buttonpos_1","Buttonpos_2","Description","HP","Level","Name","Tip","Ubertip","abilList","armor","class","colorB","colorG","colorR","cooldownID","drop","droppable","file","goldcost","ignoreCD","lumbercost","morph","oldLevel","pawnable","perishable","pickRandom","powerup","prio","scale","selSize","sellable","stockMax","stockRegen","stockStart","usable","uses","Hotkey","Requires"}
config.destructableKeys = {"EditorSuffix","HP","MMBlue","MMGreen","MMRed","Name","UserList","armor","buildTime","canPlaceDead","canPlaceRandScale","category","cliffHeight","colorB","colorG","colorR","deathSnd","fatLOS","file","fixedRot","flyH","fogRadius","fogVis","goldRep","lightweight","lumberRep","maxPitch","maxRoll","maxScale","minScale","numVar","occH","onCliffs","onWater","pathTex","pathTexDeath","portraitmodel","radius","repairTime","selSize","selcircsize","selectable","shadow","showInMM","targType","texFile","texID","tilesetSpecific","tilesets","useClickHelper","useMMColor","walkable",}
config.doodadKeys = {"MMBlue","MMGreen","MMRed","Name","UserList","animInFog","canPlaceRandScale","category","defScale","file","fixedRot","floats","ignoreModelClick","maxPitch","maxRoll","maxScale","minScale","numVar","onCliffs","onWater","pathTex","selSize","shadow","showInFog","showInMM","soundLoop","tilesetSpecific","tilesets","useClickHelper","useMMColor","vertB1","vertG1","vertR1","visRadius","walkable","vertB2","vertG2","vertR2","vertB3","vertG3","vertR3","vertB4","vertG4","vertR4","vertB5","vertB6","vertB7","vertG5","vertG6","vertG7","vertR5","vertR6","vertR7","vertB10","vertB8","vertB9","vertG10","vertG8","vertG9","vertR10","vertR8","vertR9"}
config.abilityKeys = {"Animnames","Area1","Art","BuffID1","Buttonpos_1","Buttonpos_2","Cast1","Casterattachcount","Cool1","Cost1","DataA1","DataB1","DataC1","DataD1","Dur1","EditorSuffix","EfctID1","HeroDur1","Hotkey","MissileHoming","Missilearc","Missileart","Missilespeed","Name","Order","Orderoff","Orderon","Researchbuttonpos_1","Researchbuttonpos_2","Rng1","SpecialArt","Targetattachcount","Tip1","Ubertip1","UnButtonpos_1","UnButtonpos_2","Unorder","Untip1","Unubertip1","checkDep","code","hero","item","levelSkip","levels","priority","race","reqLevel","targs1","Requires","Unart","Unhotkey","TargetArt","Targetattach","EffectArt","ResearchArt","Researchhotkey","Researchtip","Researchubertip","UnitID1","Requiresamount","DataE1","DataF1","Specialattach","LightningEffect","DataG1","DataH1","DataI1","Effectsoundlooped","Effectsound","CasterArt","Area2","Area3","BuffID2","BuffID3","Cast2","Cast3","Cool2","Cool3","Cost2","Cost3","DataB2","DataB3","Dur2","Dur3","EfctID2","EfctID3","HeroDur2","HeroDur3","Rng2","Rng3","Tip2","Tip3","Ubertip2","Ubertip3","UnitID2","UnitID3","Untip2","Untip3","Unubertip2","Unubertip3","targs2","targs3","Casterattach","DataA2","DataA3","DataC2","DataC3","DataD2","DataD3","Areaeffectart","DataE2","DataE3","DataF2","DataF3","DataG2","DataG3","DataH2","DataH3","DataI2","DataI3","Area4","BuffID4","Cast4","Cool4","Cost4","DataA4","DataB4","DataC4","DataD4","DataE4","DataF4","DataG4","Dur4","EfctID4","HeroDur4","Rng4","Tip4","Ubertip4","Untip4","Unubertip4","targs4","UnitID4","Targetattach1","Targetattach2","Targetattach3","Targetattach4","Targetattach5"}
config.buffKeys = {"EditorName","MissileHoming","Missilearc","Missilespeed","Spelldetail","TargetArt","Targetattach","Targetattachcount","code","isEffect","race","Buffart","Bufftip","Buffubertip","SpecialArt","Specialattach","EffectArt","Effectsoundlooped","EditorSuffix","Targetattach1","Targetattach2","Targetattach3","Missileart","Effectsound","Effectattach","LightningEffect","Targetattach4","Targetattach5"}
config.upgradeKeys = {"Art1","Buttonpos_1","Buttonpos_2","EditorSuffix1","Hotkey1","Name1","Requires1","Requiresamount1","Tip1","Ubertip1","base1","base2","base3","base4","class","code1","code2","code3","code4","effect1","effect2","effect3","effect4","global","goldbase","goldmod","inherit","lumberbase","lumbermod","maxlevel","mod1","mod2","mod3","mod4","race","timebase","timemod","Art2","EditorSuffix2","Hotkey2","Name2","Requires2","Requiresamount2","Tip2","Ubertip2","Art3","EditorSuffix3","Hotkey3","Name3","Requires3","Requiresamount3","Tip3","Ubertip3"}

config.split = ";"

local templateHash = {
	hero = "Hmkg", --山丘之王
	build = "owtw", -- 兽族防御塔
	commonUnit = "hfoo", -- 人族步兵
	Aap1 = 'Aap1', -- 憎恶技能
	item = "rat6", --攻击爪子
	destructable = "LTex", --炸药桶
	doodad = "APms", -- 蘑菇
	ability = "Aply", --变🐏
	buff = "BHbd", --暴风雪
	upgrade = "Rhpm", -- 背包
}

config.getTemplate = function (category, data, keys)
	local attrHash = {}
	for k,v in pairs(keys) do
		attrHash[v] = data[k+1]
	end
	if category ~= "unit" and category ~= "ability" then
		return templateHash[category]
	elseif category == "unit" then
		if tonumber(attrHash.isbldg) == 1 then
			return templateHash.build
		elseif attrHash.heroAbilList ~= "null" then
			return templateHash.hero
		elseif attrHash.UnitID1 == "uplg" then
			return templateHash.Aapl
		else
			return templateHash.commonUnit
		end
	elseif category == "ability" then
		if attrHash.UnitID1 == "uplg" then
			return templateHash.Aap1
		else
			return templateHash.ability
		end
	end
end

return config