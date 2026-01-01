rto_zones = {}

-- Returns true if the string is a valid zone index, false otherwise
function rto_zones.zone_exists(zone)
	return not not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:ContainsKey(zone)
end

-- Returns the ZoneEntrySummary associated to the given zone
function rto_zones.zone_summary(zone)
		if rto_zones.zone_exists(zone) then
				return _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(zone)
		end
		return nil
end

function rto_zones.zone_data(zone)
		if rto_zones.zone_exists(zone) then
				return _DATA:GetZone(zone)
		end
		return nil
end

-- function rto_zones.zone_data_segment_steps(zone, segment)
-- 	PMDC.LevelGen.SaveVarsZoneStep
-- 	PMDC.LevelGen.FloorNameDropZoneStep
-- 	RogueEssence.LevelGen.MoneySpawnZoneStep
-- 	RogueEssence.LevelGen.ItemSpawnZoneStep
-- 	RogueEssence.LevelGen.TeamSpawnZoneStep
-- 	RogueEssence.LevelGen.SpreadStepZoneStep
-- 	RogueEssence.LevelGen.TileSpawnZoneStep
-- 	RogueEssence.LevelGen.SpreadStepRangeZoneStep
-- 	PMDC.LevelGen.FloorNameDropZoneStep
-- end

function rto_zones.zone_data_segments(zone)
		if rto_zones.zone_exists(zone) then
				return _DATA:GetZone(zone).Segments
		end
		return nil
end

function rto_zones.zone_summary_toString(zone_summary)
	local toString =
		"zone_summary.Name:ToLocal(): " .. zone_summary.Name:ToLocal() .. "\n" ..
		"zone_summary.ExpPercent: " .. zone_summary.ExpPercent .. "\n" ..
		"zone_summary.Level: " .. zone_summary.Level .. "\n" ..
		"zone_summary.LevelCap: " .. (zone_summary.LevelCap and 'Y' or 'N') .. "\n" ..
		"zone_summary.KeepSkills: " .. (zone_summary.KeepSkills and 'Y' or 'N') .. "\n" ..
		"zone_summary.TeamRestrict: " .. (zone_summary.TeamRestrict and 'Y' or 'N') .. "\n" ..
		"zone_summary.TeamSize: " .. zone_summary.TeamSize .. "\n" ..
		"zone_summary.MoneyRestrict: " .. (zone_summary.MoneyRestrict and 'Y' or 'N') .. "\n" ..
		"zone_summary.BagRestrict: " .. (zone_summary.BagRestrict and 'Y' or 'N') .. "\n" ..
		"zone_summary.KeepTreasure: " .. (zone_summary.KeepTreasure and 'Y' or 'N') .. "\n" ..
		"zone_summary.BagSize: " .. zone_summary.BagSize .. "\n" ..
		"zone_summary.Rescues: " .. zone_summary.Rescues .. "\n" ..
		"zone_summary.CountedFloors: " .. zone_summary.CountedFloors .. "\n" ..
	-- "zone_summary.Rogue: " .. zone_summary.Rogue) -- RogueEssence.Data.RogueStatus .. "\n" ..
		"zone_summary.Grounds: # " .. zone_summary.Grounds.Count .. "\n" ..
		""
	
	if zone_summary.Grounds.Count > 0 then
		for i = 0, zone_summary.Grounds.Count-1 do
			local ground = zone_summary.Grounds[i]
			toString = toString .. "[" .. i .. "]: " .. COMMON.print_r(ground, 1) .. "\n"
		end
	end
	
	return toString
end

function rto_zones.ids()
	local zone_ids = {}
	
	local eDI = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]
	local eDIkeys = eDI:GetOrderedKeys(true)
	for i = 0, eDIkeys.Count -1 do
		table.insert(zone_ids, eDIkeys[i])
	end
	
	return zone_ids
end

function rto_zones.names()
	local zone_names = {}
	
	local eDI = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]
	local eDIkeys = eDI:GetOrderedKeys(true)
	for i = 0, eDIkeys.Count -1 do
		table.insert(zone_names, rto_zones.zone_summary(eDIkeys[i]).Name:ToLocal())
	end
	
	return zone_names
end

function rto_zones.debug_zone_data_segments_steps(zone)
	local ret = ''
	local zone_data = _DATA:GetZone(zone)
	for segmentData in luanet.each(_DATA:GetZone(zone).Segments) do
		local segSteps = segmentData.ZoneSteps
		for i = 0, segSteps.Count-1, 1 do
			local step = segSteps[i]
			ret = ret .. COMMON.get_class_full(step) .. "\n"
		end
	end
	
	return ret
end

--[[
	-- Initializes the data slot for the supplied segment if not already present
	function RECRUIT_LIST.generateDungeonListSV(zone, segment)
		RECRUIT_LIST.generateDungeonListBaseSV()
		if not rto_zones.zone_exists(zone) then return end            -- abort if zone does not exist
		SV.Services.RecruitList[zone] = SV.Services.RecruitList[zone] or {}

		-- update old data if present
		local defaultFloor = 0
		if type(SV.Services.RecruitList[zone][segment]) == "number" then
				defaultFloor = SV.Services.RecruitList[zone][segment]
				SV.Services.RecruitList[zone][segment] = nil
		end

		if not SV.Services.RecruitList[zone][segment] then
				local segment_data = _DATA:GetZone(zone).Segments[segment]
				if segment_data == nil then return end         -- abort if segment does not exist
						SV.Services.RecruitList[zone][segment] = {
								floorsCleared = defaultFloor,           -- number of floors cleared in the dungeon
								totalFloors = segment_data.FloorCount,  -- total amount of floors in this segment
								completed = false,                      -- true if the dungeon has been completed
								name = "Segment "..tostring(segment)    -- segment display name
						}

				local name = RECRUIT_LIST.build_segment_name(segment_data)
				SV.Services.RecruitList[zone][segment].name = name
		end
	end
	-- returns the name of the provided segment
	function RECRUIT_LIST.build_segment_name(segment_data)
		local segSteps = segment_data.ZoneSteps
		local sub_name = {}
		local exit = false
		-- look for a title property to extract the name from
		for j = 0, segSteps.Count-1, 1 do
				local step = segSteps[j]
				if COMMON.get_class_full(step) == "PMDC.LevelGen.FloorNameDropZoneStep" then
						exit = true
						local name = step.Name:ToLocal()
						for substr in name:gmatch(("[^\r\n]+")) do
								table.insert(sub_name,substr)
						end
				end
				if exit then break end
		end

		local stringbuild = sub_name[1] --no i don't come from Java as well what makes you think that
		-- build the name out of the found property
		for i=2, #sub_name, 1 do
				-- look for a floor counter in this string piece
				local result = string.match(sub_name[i], "(%a?){0}")
				if result == nil then -- if not found
						stringbuild = stringbuild.." "..sub_name[i] -- add to the name string
				end
		end
		return stringbuild
	end

	function RECRUIT_LIST.updateSegmentName(zone, segment)
		if not rto_zones.zone_exists(zone) then return end
		local segment_data = _DATA:GetZone(zone).Segments[segment]
		if segment_data == nil then return end

		local name = RECRUIT_LIST.build_segment_name(segment_data)
		SV.Services.RecruitList[zone][segment].name = name
	end
	-- Returns the number of floors cleared on the provided segment
	function RECRUIT_LIST.getFloorsCleared(zone, segment)
		RECRUIT_LIST.generateDungeonListSV(zone, segment)
		if SV.Services.RecruitList[zone] == nil then return 0 end
		if SV.Services.RecruitList[zone][segment] == nil then return 0 end
		return SV.Services.RecruitList[zone][segment].floorsCleared
	end
	-- Returns a segment's spawn list data structure
	function RECRUIT_LIST.getSegmentData(zone, segment)
		RECRUIT_LIST.generateDungeonListSV(zone, segment)
		if SV.Services.RecruitList[zone] == nil then return nil end
		return SV.Services.RecruitList[zone][segment]
	end


	-- returns the current map as a table of properties {string zone, int segment, int floor}
	function RECRUIT_LIST.getCurrentMap()
		local mapData = {
				zone = _ZONE.CurrentZoneID,
				segment = _ZONE.CurrentMapID.Segment,
				floor = GAME:GetCurrentFloor().ID + 1
		}
		return mapData
	end


	function RECRUIT_LIST.compileFullDungeonList(zone, segment)
		local species = {}  -- used to compact multiple entries that contain the same species
		local list = {}     -- list of all keys in the list. populated only at the end

		RECRUIT_LIST.generateDungeonListSV(zone, segment)
		local segmentData = _DATA:GetZone(zone).Segments[segment]
		local segSteps = segmentData.ZoneSteps
		local highest = RECRUIT_LIST.getFloorsCleared(zone,segment)
		for i = 0, segSteps.Count-1, 1 do
				local step = segSteps[i]
				if COMMON.get_class_full(step) == "RogueEssence.LevelGen.TeamSpawnZoneStep" then
						local entry_list = {}

						-- Check Spawns
						local spawnlist = step.Spawns
						for j=0, spawnlist.Count-1, 1 do
								local range = spawnlist:GetSpawnRange(j)
								local spawn = spawnlist:GetSpawn(j).Spawn -- RogueEssence.LevelGen.MobSpawn
								local entry = {
										elements = {{
												data = spawn,
												dungeon = {zone = zone, segment = segment},
												range = {
														min = range.Min+1,
														max = math.min(range.Max, segmentData.FloorCount)
												}
										}},
										type = "spawn",
										species = spawn.BaseForm.Species,
										mode = RECRUIT_LIST.not_seen, -- defaults to "???". this will be calculated later
										enabled = false               -- false by default. this will be calculated later
								}
								entry.min = entry.elements[1].range.min
								entry.max = entry.elements[1].range.max
								-- check if the mon is recruitable
								local recruitable = true
								local features = spawn.SpawnFeatures
								for f = 0, features.Count-1, 1 do
										if COMMON.get_class_full(features[f]) == "PMDC.LevelGen.MobSpawnUnrecruitable" then
												recruitable = false
												entry.mode = RECRUIT_LIST.unrecruitable
										end
								end
								if recruitable or RECRUIT_LIST.showUnrecruitable() then
										table.insert(entry_list, entry)
								end
						end

						-- Check Specific Spawns
						spawnlist = step.SpecificSpawns -- SpawnRangeList
						for j=0, spawnlist.Count-1, 1 do
								local range = spawnlist:GetSpawnRange(j)
								local spawns = spawnlist:GetSpawn(j):GetPossibleSpawns() -- SpawnList
								for s=0, spawns.Count-1, 1 do
										local spawn = spawns:GetSpawn(s)

										local entry = {
												elements = {{
														data = spawn,
														dungeon = {zone = zone, segment = segment},
														range = {
																min = range.Min+1,
																max = math.min(range.Max, segmentData.FloorCount)
														}
												}},
												type = "spawn",
												species = spawn.BaseForm.Species,
												mode = RECRUIT_LIST.not_seen, -- defaults to "???". this will be calculated later
												enabled = false               -- false by default. this will be calculated later
										}
										entry.min = entry.elements[1].range.min
										entry.max = entry.elements[1].range.max
										-- check if the mon is recruitable
										local recruitable = true
										local features = spawn.SpawnFeatures
										for f = 0, features.Count-1, 1 do
												if COMMON.get_class_full(features[f]) == "PMDC.LevelGen.MobSpawnUnrecruitable" then
														recruitable = false
														entry.mode = RECRUIT_LIST.unrecruitable
												end
										end
										if recruitable or RECRUIT_LIST.showUnrecruitable() then
												table.insert(entry_list, entry)
										end
								end
						end

						-- Mix everything up
						for _, entry in pairs(entry_list) do
								-- keep only if under explored limit
								if entry.mode > RECRUIT_LIST.hide and entry.min <= highest then
										species[entry.species] = species[entry.species] or {}
										table.insert(species[entry.species], entry)
								end
						end
				end
		end

		for _, entry in pairs(species) do
				-- sort species-specific list by first appearance
				table.sort(entry, function (a, b)
						return a.min < b.min
				end)
				local current = entry[1]

				-- fuse entries whose floor boundaries touch or overlap
				-- put final entries in output list
				if #entry>1 then
						for i = 2, #entry, 1 do
								local next = entry[i]
								if current.max+1 >= next.min then
										current.max = math.max(current.max, next.max)
										for _, element in pairs(next.elements) do table.insert(current.elements, element) end
								else
										table.insert(list,current)
										current = next
								end
						end
				end
				table.insert(list,current)
		end

		-- sort output list by min floor, max floor and then dex
		table.sort(list, function (a, b)
				if a.min == b.min then
						if a.max == b.max then
								return _DATA:GetMonster(a.species).IndexNum < _DATA:GetMonster(b.species).IndexNum
						end
						return a.max < b.max
				end
				return a.min < b.min
		end)

		for _,elem in pairs(list) do
				local unlockState = _DATA.Save:GetMonsterUnlock(elem.species)

				if elem.mode ~= RECRUIT_LIST.unrecruitable then
						-- check if the mon has been seen or obtained
						if unlockState == RogueEssence.Data.GameProgress.UnlockState.Discovered then
								elem.mode = RECRUIT_LIST.seen
								elem.enabled = true
						elseif unlockState == RogueEssence.Data.GameProgress.UnlockState.Completed then
								if RECRUIT_LIST.check_multi_form(elem.species) then
										elem.mode = RECRUIT_LIST.obtainedMultiForm --special color for multi-form mons
								else
										elem.mode = RECRUIT_LIST.obtained
								end
								elem.enabled = true
						end
				else
						if unlockState == RogueEssence.Data.GameProgress.UnlockState.None then
								elem.mode = RECRUIT_LIST.unrecruitable_not_seen
						else elem.enabled = true end
				end
		end
		return list
	end

]]
