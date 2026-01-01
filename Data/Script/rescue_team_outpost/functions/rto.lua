--[[
    rto_lua
    A collection of frequently used functions, regarding Rescue Team Outpost
]]--
-- require 'rescue_team_outpost.____'

rto = {}

--[[ function rto_char_questing(char)
	return rto_scriptvars.Member.fromChar(char):questing()
	-- rto_uids.init_char(char)
	
	-- if rto_char_in_active_team(char) then return false end
	
	-- local char_team = SV.rescue_team_outpost.teams[rto_char_teamname(char)]
	-- return (not not char_team) and char_team.questing
end ]]

--[[ function rto_char_teamname(char)
	rto_uids.init_char(char)
	return SV.rescue_team_outpost.char_to_teamname[char.LuaData.uid]
end ]]

--[[ function rto_char_set_teamname(char, team_name)
	rto_uids.init_char(char)
	SV.rescue_team_outpost.char_to_teamname[char.LuaData.uid] = team_name
end ]]

