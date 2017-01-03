--[[function GetDesire()
	return ( 0.0);
end
]]
local utils = require(GetScriptDirectory() .. "/util")
require( GetScriptDirectory().."/team_status" )
----------------------------------------------------------------------------------------------------

local min = 0
local sec = 0
local rune = 0
local runeCalled = false
local waiting = false
local callTime = 0

function GetDesire()
	local npcBot = GetBot()
	min = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60

	--rune time is over back to business
	if min % 2 == 0 and runeCalled then
		runeCalled = false
		waiting = false
		team_status.ClearCalledRunes()
	end 

	--we've called one go get it
	if runeCalled then
		return BOT_MODE_DESIRE_HIGH
	end

		--don't kill yourself for a rune
	if (npcBot:GetActiveMode() == BOT_MODE_RETREAT or
		npcBot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS or
		npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		npcBot:GetActiveMode() == BOT_MODE_ATTACKING)
	then
		return BOT_MODE_DESIRE_NONE
	end

		-- grab a rune if we walk by it
	if (GetUnitToLocationDistance( npcBot , RAD_BOUNTY_RUNE_SAFE) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_1 ) == RUNE_STATUS_AVAILABLE )
	then   
		rune = RAD_BOUNTY_RUNE_SAFE
    	return BOT_MODE_DESIRE_VERYHIGH 
    elseif (GetUnitToLocationDistance( npcBot , RAD_BOUNTY_RUNE_OFF) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_2 ) == RUNE_STATUS_AVAILABLE )
	then   
		rune = RAD_BOUNTY_RUNE_OFF
    	return BOT_MODE_DESIRE_VERYHIGH
	elseif (GetUnitToLocationDistance( npcBot , DIRE_BOUNTY_RUNE_SAFE) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_3 ) == RUNE_STATUS_AVAILABLE )
	then   
		rune = DIRE_BOUNTY_RUNE_SAFE
    	return BOT_MODE_DESIRE_VERYHIGH
	elseif (GetUnitToLocationDistance( npcBot , DIRE_BOUNTY_RUNE_OFF) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_4 ) == RUNE_STATUS_AVAILABLE )
	then    
		rune = DIRE_BOUNTY_RUNE_OFF
    	return BOT_MODE_DESIRE_VERYHIGH
    elseif (GetUnitToLocationDistance( npcBot , POWERUP_RUNE_TOP) < 1000 and
		GetRuneStatus( RUNE_POWERUP_1 ) == RUNE_STATUS_AVAILABLE )
	then    
		rune = POWERUP_RUNE_TOP
    	return BOT_MODE_DESIRE_VERYHIGH
    elseif (GetUnitToLocationDistance( npcBot , POWERUP_RUNE_BOT) < 1000 and
		GetRuneStatus( RUNE_POWERUP_2 ) == RUNE_STATUS_AVAILABLE )
	then    
		rune = POWERUP_RUNE_BOT
    	return BOT_MODE_DESIRE_VERYHIGH
    end

    --[[
    its rune time, find your closest rune and call it
    a timer runs based off your distance to rune and calls it
    so closest bot will get the rune
    ]]
	if min % 2 == 1 and sec > 45 
	then
		local options = {}

		for _,v in pairs(utils.tableRuneSpawns[GetTeam()]) do
			table.insert(options, v)
		end

		for _,v in pairs(utils.tableRuneSpawns[POWERUP_RUNES]) do
			table.insert(options, v)
		end

		rune = utils.NearestRuneSpawn( npcBot, options )
		for _,v in pairs(team_status.GetCalledRunes()) do
			if v == rune then
				return BOT_MODE_DESIRE_NONE
			end
		end

		if not waiting then
			callTime = DotaTime() + GetUnitToLocationDistance(npcBot, rune) / 3000
			wating = true
		end

		if waiting and DotaTime() < callTime then
			return BOT_MODE_DESIRE_NONE
		end
		team_status.CallRune(rune)
		runeCalled = true
		return BOT_MODE_DESIRE_HIGH 
	end

	return BOT_MODE_DESIRE_NONE
end

----------------------------------------------------------------------------------------------------

function OnStart()
	
end

----------------------------------------------------------------------------------------------------

function OnEnd() 

end

----------------------------------------------------------------------------------------------------

function Think()
	local npcBot = GetBot()
	-- grab a rune if we walk by it
	if (GetUnitToLocationDistance( npcBot , RAD_BOUNTY_RUNE_SAFE) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_1 ) == RUNE_STATUS_AVAILABLE )
	then   
    	npcBot:Action_PickUpRune(RUNE_BOUNTY_1);
    	return
    elseif (GetUnitToLocationDistance( npcBot , RAD_BOUNTY_RUNE_OFF) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_2 ) == RUNE_STATUS_AVAILABLE )
	then   
    	npcBot:Action_PickUpRune(RUNE_BOUNTY_2);
    	return
	elseif (GetUnitToLocationDistance( npcBot , DIRE_BOUNTY_RUNE_SAFE) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_3 ) == RUNE_STATUS_AVAILABLE )
	then   
    	npcBot:Action_PickUpRune(RUNE_BOUNTY_3);
    	return
	elseif (GetUnitToLocationDistance( npcBot , DIRE_BOUNTY_RUNE_OFF) < 1000 and
		GetRuneStatus( RUNE_BOUNTY_4 ) == RUNE_STATUS_AVAILABLE )
	then    
    	npcBot:Action_PickUpRune(RUNE_BOUNTY_4);
    	return
    elseif (GetUnitToLocationDistance( npcBot , POWERUP_RUNE_TOP) < 1000 and
		GetRuneStatus( RUNE_POWERUP_1 ) == RUNE_STATUS_AVAILABLE )
	then    
    	npcBot:Action_PickUpRune(RUNE_POWERUP_1);
    	return
    elseif (GetUnitToLocationDistance( npcBot , POWERUP_RUNE_BOT) < 1000 and
		GetRuneStatus( RUNE_POWERUP_2 ) == RUNE_STATUS_AVAILABLE )
	then    
    	npcBot:Action_PickUpRune(RUNE_POWERUP_2);
    	return
    end


    if GameTime() < 200 then
    	npcBot:Action_MoveToLocation( utils.NearestRuneSpawn(npcBot, utils.tableRuneSpawns[GetTeam()]))
		return
    end

    if rune ~= nil and rune ~= 0 then
	   	npcBot:Action_MoveToLocation( rune )
	else
		print("rune error!")
	end
end