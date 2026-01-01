--[[
    common.lua
    A collection of frequently used functions
]]--
require 'rescue_team_outpost.functions.rto'
require 'rescue_team_outpost.functions.rto_icons'
require 'rescue_team_outpost.functions.rto_scriptvars'
require 'rescue_team_outpost.functions.rto_teams'
require 'rescue_team_outpost.functions.rto_uids'
require 'rescue_team_outpost.functions.rto_zones'
require 'rescue_team_outpost.menu.team.CustomAssemblySelectMenu'

-- Overrides ----------------------
function COMMON.ShowTeamAssemblyMenu(obj, init_fun)
  SOUND:PlaySE("Menu/Skip")
  
	AssemblyMultiSelectMenu.runMultiMenu(function(char)
		local Member = rto_scriptvars.Member.fromChar(char)
		local teamname = SV.rescue_team_outpost.char_to_teamname[char.LuaData.uid]
		return Member:in_active_team() or teamname == nil or not teamname
	end, true)
	-- UI:AssemblyMenu()
  -- UI:WaitForChoice()
  -- result = UI:ChoiceResult()
	
  -- if result then
  --   GAME:WaitFrames(10)
	-- 	SOUND:PlayBattleSE("EVT_Assembly_Bell")
	-- 	GROUND:ObjectSetAnim(obj, 6, -1, -1, RogueElements.Dir8.Down, 3)
	-- 	GAME:FadeOut(false, 20)
	-- 	init_fun()
  --   GAME:FadeIn(20)
  -- end
end
-- --------------------------------

function COMMON.ProgressResultType2string(result_type)
	if result_type == nil then return nil
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Unknown 		then return 'Unknown'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Downed 			then return 'Downed'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Failed 			then return 'Failed'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Cleared 		then return 'Cleared'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Escaped 		then return 'Escaped'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.TimedOut 		then return 'TimedOut'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.GaveUp 			then return 'GaveUp'
	elseif result_type == RogueEssence.Data.GameProgress.ResultType.Rescuing 		then return 'Rescuing'
	end
	return nil
end

-- choices Can either be an array of strings, or array of arrays, where each sub-array is {string, bool}, and the 2nd value indicates if the choice is disabled. Must contain the "cancel" choice as last.
-- callbacks Contains scripts for the choises to be run after a choice is made.
function COMMON.show_choice_menu(menu_prompt, choices, callbacks)
	UI:BeginChoiceMenu(menu_prompt, choices, 1, #choices, callbacks)
	UI:WaitForChoice()
	return UI:ChoiceResult()
end

function COMMON.silent_add_to_team(char)
	_DATA.Save.ActiveTeam.Assembly:Remove(char);
	_DATA.Save.ActiveTeam.Players:Add(char);
end

function COMMON.array_first(arr)
	if type(arr) == "table" then
		for _, v in pairs(arr) do return v end
	end
	return nil
end

function COMMON.array_last(arr)
	local ret = nil
	if type(arr) == "table" then
		for _, v in pairs(arr) do ret = v end
	end
	return v
end

function COMMON.array_pairs(arr)
	local ret_pairs = {}
	if type(arr) == "table" then
		for k, v in pairs(arr) do table.insert(ret_pairs, {k, v}) end
	end
	return ret_pairs
end

-- If called with 2 params, len and val is used.
function COMMON.array_fill(i, len, val)
	local def_val = 0
	if (val == nil) and len == nil then val = def_val; len = i; i = nil; end -- Single var: length
	if val == nil then val = len; len = i; i = nil; end -- Two vars: length, value
	
	local ret = {}
	for j = i, len do
		ret[j] = val
	end
	
	return ret
end

function COMMON.array_combine(keys, values)
	if type(keys) ~= "table" or type(values) ~= "table" or #keys ~= #values then
		PrintError("COMMON.array_combine: Invalid parameters")
		return {}
	end
	
	local ret = {}
	for i, k in ipairs(keys) do
		ret[k] = values[i]
	end
	return ret
end

function COMMON.array_map(callback, arr)
	if type(arr) ~= "table" then return {} end
	
	local ret = {}
	for k, v in pairs(arr) do table.insert(ret, callback(k, v)) end
	return ret
end

function COMMON.array_values(arr)
	local ret = {}
	if type(arr) == "table" then
		for _, v in pairs(arr) do table.insert(ret, v) end
	end
	return ret
end

function COMMON.array_keys(arr)
	local keys = {}
	if type(arr) == "table" --[[ and COMMON.count_assoc_array(arr) > 0 ]] then
		for k, _ in pairs(arr) do table.insert(keys, k) end
	end
	return keys
end

function COMMON.array_column(arr, column_name)
	local ret = {}
	
	if type(arr) == "table" --[[ and COMMON.count_assoc_array(arr) > 0 ]] then
		for _, v in pairs(arr) do
			if type(v) == "table" and v[column_name] ~= nil then
				table.insert(ret, v[column_name])
			end
		end
	end
	
	return ret
end

function COMMON.array_has_value(arr, val, k_or_v)
	if type(arr) ~= "table" or #arr <= 0 then return false end
	
	if k_or_v == nil then k_or_v = "v" end
	
	for k, v in pairs(arr) do
		if 			(k_or_v == "kv" or k_or_v == "k") and k == val then
			return true
		elseif 	(k_or_v == "kv" or k_or_v == "v") and v == val then
			return true
		end
	end
	
	return false
end

function COMMON.array_merge(...)
	local arg = {...}
	local to_ret = arg[1]
	
	for i = 2, #arg do
		for k,v in pairs(arg[i]) do
			to_ret[k] = v
		end
	end
	
	return to_ret
end

function COMMON.array_sum(a)
	local sum = 0
	for k,v in pairs(a) do
		sum = sum + v
	end
	return sum
end

-- preserve_keys: For cases where you need to preserve numeric keys, for example to run this #length, leave preserve_keys to false
function COMMON.array_filter(arr, cb, preserve_keys)
	preserve_keys = (preserve_keys ~= nil and {preserve_keys} or {true})[1]
	
	local ret = {}
	if type(arr) == "table" --[[ and COMMON.count_assoc_array(arr) > 0 ]] then
		for k, v in pairs(arr) do
			if cb(k, v) then
				if not preserve_keys then
					table.insert(ret, v)
				else
					ret[k] = v
				end
			end
		end
	end
	
	return ret
end

function COMMON.array_unique(a)
	local unique_keys = {}
	if type(a) == "table" --[[ and COMMON.count_assoc_array(a) > 0 ]] then
		for k,v in pairs(a) do
			unique_keys[v] = true
		end
	end
	
	local unique_values = {}
	if type(a) == "table" --[[ and COMMON.count_assoc_array(a) > 0 ]] then
		for k,v in pairs(unique_keys) do table.insert(unique_values, k) end
	end
	
	return unique_values
end

-- WARNING!!! ONLY available for arrays with values that CAN be set as table indexes...
function COMMON.array2D_flat(a)
	local res = {}
	if type(a) == "table" --[[ and COMMON.count_assoc_array(a) > 0 ]] then
		for i=1, #a do
			if type(a[i]) == "table" then
				for j=1, #a[i] do
					table.insert(res, a[i][j])
				end
			else
				table.insert(res, a[i])
			end
		end
	end
	return res
end

function COMMON.count_assoc_array(arr)
	local count = 0
	if type(arr) == "table" then
		for _ in pairs(arr) do count = count + 1 end
	end
	return count
end

function COMMON.get_class(csobject)
	local cl = COMMON.get_class_full(csobject)
	for a in cl:gmatch('([^.]+)$') do
		return a
	end
end

function COMMON.get_class_full(csobject)
	if not csobject then return "nil" end
	local metadata = getmetatable(csobject)
	local namet
	if not metadata then namet = nil else namet = getmetatable(csobject).__name end
	if not namet then return type(csobject) end
	for a in namet:gmatch('([^,]+)') do
		return a
	end
end

-- Debug

timers = {}
timer_stats = {}
function COMMON.stopwatch_stt(label) timers[label] = os.clock() end
function COMMON.stopwatch_stp(label) local ms = (os.clock() - timers[label]) * 1000; COMMON.stopwatch_sumup(label, ms) PrintInfo(string.format("Time #%s: %5.f ms", label, ms)); timers[label] = nil end
function COMMON.stopwatch_sumup(label, ms)
	timer_stats[label] = (timer_stats[label] or {})
	timer_stats[label].sum = (timer_stats[label].sum or 0) + ms
	timer_stats[label].count = (timer_stats[label].count or 0) + 1
end
function COMMON.stopwatch_toggle(label) if not timers[label] then COMMON.stopwatch_stt(label) else COMMON.stopwatch_stp(label) end end
function COMMON.stpwtch(label) COMMON.stopwatch_toggle(label) end
function COMMON.stopwatch_stats()
	for k, v in pairs(timer_stats) do
		PrintInfo(string.format("#%s: x%4d    Sum: %5s s    Avg: %5s s", k, v.count, string.format("%2.2f", v.sum/1000), string.format("%2.2f", v.sum/1000/v.count)))
	end
end

-- Safety net (To avoid infinite loops)
COMMON.print_r_max_depth = 10
function COMMON.print_r(var, ret, indC, _depth)
	ret = (ret ~= nil and {ret} or {false})[1]
	indC = (indC ~= nil and {indC} or {0})[1]
	_depth = (_depth ~= nil and {_depth} or {0})[1]
	
	if _depth > COMMON.print_r_max_depth then
		PrintInfo( "COMMON.print_r: max depth (" .. COMMON.print_r_max_depth .. ") reached")
		return ''
	end
	
	local retF = function(str)
		if ret then return str end
		PrintInfo(str)
	end
	
	local ind = ""
	local tab = "    "
	local endL = (indC <= 0 and {""} or {"\n"})[1]
	
	if indC > 0 then
		for i = 1, indC do ind = ind..tab end
	end
	
	if type(var) == "boolean" then
		return retF( ((var == true) and {"true"} or {"false"})[1]..endL )
	elseif type(var) == "nil" then
		return retF( "nil"..endL )
	elseif type(var) == "function" then
		return retF( "--SOME FUNCTION--"..endL )
	elseif type(var) == "userdata" then
		-- local meta = getmetatable(var)
		local clazz = COMMON.get_class(var)
		
		local str = "[UsDat: "..clazz.."] "
		if clazz == "Character" then str=str.. var.Name end
		
		if clazz == "Object[]" then
			local objData = {}
			for var_i in luanet.each(var) do
				if var_i == var then table.insert(objData, "--SELF--")
				else table.insert(objData, (var_i ~= nil and {var_i} or {"nil"})[1]) end
			end
			str=str.. "values: "..COMMON.print_r(objData, 1, indC, _depth + 1)
		end
		
		-- str=str.. "\n"..ind..tab
		str=str.. endL
		
		if var.LuaData then
			if var.LuaData == var then str=str.. ind.. tab .. "LuaData: --SELF--".. endL
			else str=str.. "LuaData: "..COMMON.print_r(var.LuaData, 1, (indC+1), _depth + 1) end
		end
		
		-- str=str.. "Metadata: "..COMMON.print_r(meta, 1, (indC + 1), _depth + 1)
		
		return retF( str )
	elseif type(var) == "table" then
		local str = "Array (".."\n"
		for k, v in pairs(var) do
			
			local kStr
			if type(k) == "table" 				then kStr = "--SOME TABLE--"
			elseif type(k) == "userdata" 	then kStr = "--SOME USERDATA--"
			elseif type(k) == "function" 	then kStr = "--SOME FUNCTION--"
			else 															 kStr = k end
			
			if v == var then str = str..ind..tab..kStr.." → --SELF--".."\n"
			else str = str..ind..tab..kStr.." → "..COMMON.print_r(v, 1, (indC + 1), _depth + 1) end
		end
		return retF( str..ind..")"..endL )
	else
		return retF( var..endL )
	end
end

local PIB_buffer = {}
local PIB_buffered_lines = 0
-- local PIB_buffer_chars = 0
local PIB_max_lines = 50
-- local PIB_max_chars = 512
function COMMON.PrintInfoBuffered(str)
	PIB_buffered_lines = PIB_buffered_lines + 1
	PIB_buffer[PIB_buffered_lines] = str
	-- PIB_buffer_chars ...
	if PIB_buffered_lines >= PIB_max_lines then
		COMMON._PrintInfoBuffered_doPrint()
	end
end

function COMMON._PrintInfoBuffered_doPrint()
	if PIB_buffered_lines == 0 then return end
	
	-- Avoid this:
	-- for i = 1, PIB_buffered_lines do
	-- 	PrintInfo(PIB_buffer[i])
	-- end
	
	-- Do that instead:
	PrintInfo(table.concat(PIB_buffer, "\n"))
	
	PIB_buffer = {}
	PIB_buffered_lines = 0
end