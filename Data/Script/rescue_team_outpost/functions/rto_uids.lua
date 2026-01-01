rto_uids = {}
rto_uids._cache = {}

function rto_uids.cache(results)
  if results == nil then return rto_uids._cache end
  rto_uids._cache = results
end
function rto_uids.cache_valid()
  return _DATA.Save.ActiveTeam.Assembly.Count + _DATA.Save.ActiveTeam.Players.Count == COMMON.count_assoc_array(rto_uids._cache)
end

--- Creates a list of player team uids
--- @param in_uids 		If provided the pokemon is registered there. Otherwise it is registered in a new array
--- @return array 		Either in_uids with the new records appended, or just the new records.
function rto_uids.player_team(in_uids)
  if in_uids == nil then
    in_uids = {}
  end
  
  for char in luanet.each(LUA_ENGINE:MakeList(_DATA.Save.ActiveTeam.Players)) do
    if char.LuaData.uid ~= nil then
      in_uids[char.LuaData.uid] = char
    end
  end
  
  return in_uids
end
	
--[[ --- Creates a list of specified team uids
--- @param in_uids 		If provided the pokemon is registered there. Otherwise it is registered in a new array
--- @return array 		Either in_uids with the new records appended, or just the new records.
function rto_uids.team(team, in_uids)
  if in_uids == nil then
    in_uids = {}
  end
  
  for k, char in pairs(team.members) do
    if char.LuaData.uid ~= nil then
      in_uids[char.LuaData.uid] = char
    end
  end
  
  return in_uids
end ]]

--- Creates a list of assembly uids
--- @param in_uids 		If provided the pokemon is registered there. Otherwise it is registered in a new array
--- @return array 		Either in_uids with the new records appended, or just the new records.
function rto_uids.assembly(in_uids)
  if in_uids == nil then
    in_uids = {}
  end
  
  for i = 0, _DATA.Save.ActiveTeam.Assembly.Count-1, 1 do
    local char = _DATA.Save.ActiveTeam.Assembly[i]
    if char.LuaData.uid ~= nil then
      in_uids[char.LuaData.uid] = char
    end
  end
  
  return in_uids
end

--- Creates a list of all player pokemons (assembly and team) uids
--- @return array 		The new records.
function rto_uids.get()
  
  if not rto_uids.cache_valid() then
    local uids = {}
    rto_uids.player_team(uids)
    rto_uids.assembly(uids)
    rto_uids.cache(uids)
  end
  
  return rto_uids.cache()
end

--- Checks if this uid is already registered
--- @param in_uids 		If provided the check is performed on that array (which would be a cache of the uids), if not, a new uids list is fetched
--- @return array 		The new records.
function rto_uids.registered(uid, in_uids)
  if in_uids == nil then
    in_uids = rto_uids()
  end
  
  return in_uids[uid]
end

--- Set uid for the char in case it doesn't have one already.
--- @param in_uids 		If provided the check is performed on that array (which would be a cache of the uids), if not, a new uids list is fetched
function rto_uids.init_char(char, in_uids)
  if char.LuaData.uid ~= nil then return end
  
  if in_uids == nil then
    in_uids = rto_uids.get()
  end
  
  local tmp_uid
  repeat tmp_uid = math.random(1, 1000000)
  until(not rto_uids.registered(tmp_uid, in_uids))
  
  char.LuaData.uid = tmp_uid
  in_uids[tmp_uid] = char
end

function rto_uids.init_all()
  local uids = rto_uids.get()
  for char in luanet.each(LUA_ENGINE:MakeList(_DATA.Save.ActiveTeam.Players)) do
    rto_uids.init_char(char, uids)
  end
  for i = 0, _DATA.Save.ActiveTeam.Assembly.Count-1, 1 do
    rto_uids.init_char(_DATA.Save.ActiveTeam.Assembly[i], uids)
  end
end
	
function rto_uids.print_all()
  PrintInfo("")
  PrintInfo("---- Pokemon UIDs list")
  local uids = rto_uids.get()
  for uid, char in pairs(uids) do
    PrintInfo("uid: " .. uid .. " -> " .. char.Name)
  end
  PrintInfo("")
end