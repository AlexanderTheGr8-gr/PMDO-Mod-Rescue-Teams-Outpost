-- TODO: ???
--[[
	ScriptableMultiPageOptionsMenu
	Based on SkillSelectMenu by MistressNebula

	Opens a menu with multiple pages that allows the player to select an option.
	It contains a run method for quick instantiation, as well as a way to open
	an (almost) exact equivalent of UI:RelearnMenu.
	This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]
require 'origin.common'
require 'rescue_team_outpost.menu.ScriptableMultiPageOptionsMenu'

--- Menu for selecting a zone.
ZoneMenu = Class("ZoneMenu", ScriptableMultiPageOptionsMenu)

--- Creates a new ``ZoneMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``options_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param options_list table an array, list or lua array table containing options.
--- @param confirm_action function the function called when a slot is chosen. It will have a option string passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 152.
--- @param label string the label that will be applied to this menu.
function ZoneMenu:initialize(title, options_list, confirm_action, refuse_action, max_elements, menu_width, label)
	-- param validity check
	local len = 0
	if type(options_list) == 'table' then len = #options_list else len = options_list.Count end
	if len <1 then
		--abort if option list is empty
		error("parameter 'options_list' cannot be an empty collection")
	end

	-- constants
	self.MAX_ELEMENTS = max_elements or 5

	-- parsing data
	self.confirmAction = confirm_action
	self.refuseAction = refuse_action
	self.menuWidth = menu_width or 152
	self.optionList = self:load_options(options_list)
	self.optionsList = self:generate_options()
	label = label or ""

	self.choice = nil -- result

	-- creating the menu
	local origin = RogueElements.Loc(16,16)
	local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
	self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(label, origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action)
	self.menu.ChoiceChangedFunction = function() self:updateSummary() end

	-- creating the summary window
	self:createSummary()
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function ZoneMenu:generate_options()
	local options = {}
	
	for i=1, #self.optionList do
		
		local dungeon_unlock_state = _DATA.Save:GetDungeonUnlock(self.optionList[i])
		local enabled = ZoneMenu.should_zone_be_enabled(self.optionList[i])
		local is_undiscovered = dungeon_unlock_state == RogueEssence.Data.GameProgress.UnlockState.None
		local is_uncompleted = dungeon_unlock_state == RogueEssence.Data.GameProgress.UnlockState.Discovered
		local skip_as_undiscovered = SKIP_UNDISCOVERED and is_undiscovered
		local skip_as_uncompleted = SKIP_UNCOMPLETED and (is_uncompleted or is_undiscovered)
		local completed = not SKIP_UNCOMPLETED and dungeon_unlock_state == RogueEssence.Data.GameProgress.UnlockState.Completed
		local hasOpenQuest = false
		local hasClosedQuest = false
		local hasMission = false
		local chosenAsConsecutive = 									false -- math.random(0, 100) <= 10
		local teamRocksHere = 												false -- math.random(0, 100) <= 10
		local whatsThat = 														false -- math.random(0, 100) <= 5
		local whatsThat2 = 														false -- math.random(0, 100) <= 5
		
		-- Check Mission board
		for _, mission in pairs(SV.TakenBoard) do
			if mission.Zone == self.optionList[i] then
				if mission.Taken then hasOpenQuest = true
				else hasClosedQuest = true end
				-- mission.Floor
				-- mission.Segment
			end
		end
		
		-- Check story missions
		for name, mission in pairs(SV.missions.Missions) do
			if mission.DestZone == self.optionList[i] then
				hasMission = true
			end
		end
		
		local zone = _DATA:GetZone(self.optionList[i])
		local zoneDisplayName = zone.Name:ToLocal() ..
			((not hasOpenQuest) and {''} or {' ' .. rto_icons.misc("Letter opened")})[1] ..
			((not hasClosedQuest) and {''} or {' ' .. rto_icons.misc("Letter closed")})[1] ..
			((not chosenAsConsecutive) and {''} or {' ' .. rto_icons.misc("♥")})[1] ..
			((not teamRocksHere) and {''} or {' ' .. rto_icons.misc("*")})[1] ..
			((not hasMission) and {''} or {' ' .. rto_icons.misc("!")})[1] ..
			((not whatsThat) and {''} or {' ' .. rto_icons.misc("?")})[1] ..
			((not whatsThat2) and {''} or {' ' .. rto_icons.misc("Red Circle")})[1] ..
			''
		
		local status_icon = RogueEssence.Menu.MenuText(
				rto_icons.misc((completed and {"Tick"} or {"Cross"})[1]),
				RogueElements.Loc(10, 1),
				RogueElements.DirH.Right
		)
		local text_zone = RogueEssence.Menu.MenuText(
			zoneDisplayName,
			RogueElements.Loc(2 + 10 + 2, 1),
			(enabled and {Color.White} or {Color.Red})[1]
		)
		
		if not skip_as_undiscovered and not skip_as_uncompleted and (not SKIP_DISABLED or enabled) then
			table.insert(options, RogueEssence.Menu.MenuElementChoice(
				function() self:choose(i) end, -- Choice action
				enabled, -- Enabled
				status_icon, -- Elements #1
				text_zone -- Elements #2
			))
		end
	end
	
	return options
end

--- Updates the summary window.
function ZoneMenu:updateSummary()
	local zonename = self.optionList[self.menu.CurrentChoiceTotal+1]
	
	zone_info = ZoneMenu.zones_full_info[zonename]
	
	self.side_summary_elements_text:SetText((not zone_info.elements and {"--"} or {table.concat(zone_info.elements, "")})[1])
	self.side_summary_levels_text:SetText("Lvl: " .. (not zone_info.levels and {"--"} or {zone_info.levels.min .. "-" .. zone_info.levels.max})[1])
	self.side_summary_floors_text:SetText("Floors: " .. (not zone_info.floors and {"??"} or {zone_info.floors})[1])
	self.side_summary_money_text:SetText("PoKe: " .. ((not zone_info.poke or not zone_info.poke.min) and {"--"} or {zone_info.poke.min .. "-" .. zone_info.poke.max .. rto_icons.misc("$")})[1])
end

--- Updates the summary window.
function ZoneMenu:createSummary()
	local GraphicsManager = RogueEssence.Content.GraphicsManager
	-- -- See SkillSummary
	self.side_summary = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(
		RogueElements.Loc(
			16,
			GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 12 * 2 - 14 * 4
		), --LINE_HEIGHT = 12, VERT_SPACE = 14
		RogueElements.Loc(
			GraphicsManager.ScreenWidth - 16,
			GraphicsManager.ScreenHeight - 8
		)
	))
	
	
	local height_line = 0
	
	height_line = 1
	self.side_summary_elements_string = ""
	self.side_summary_elements_text = RogueEssence.Menu.MenuText(
		self.side_summary_elements_string,
		RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_elements_text)
	
	-- self.side_summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))
	
	height_line = 2
	
	self.side_summary_floors_string = "Floors: "
	self.side_summary_floors_text = RogueEssence.Menu.MenuText(
		self.side_summary_floors_string,
		RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_floors_text)
	
	self.side_summary_levels_string = "Lvl: "
	self.side_summary_levels_text = RogueEssence.Menu.MenuText(
		self.side_summary_levels_string,
		RogueElements.Loc(80, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_levels_text)
	
	height_line = 3
	
	self.side_summary_money_string = "PoKe: "
	self.side_summary_money_text = RogueEssence.Menu.MenuText(
		self.side_summary_money_string,
		RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_money_text)
	
	-- self.side_summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))
	
	height_line = 3
	
	
	self.menu.SummaryMenus:Add(self.side_summary)
	self:updateSummary()
end


--- Creates a basic ``ZoneMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param options_list table an array, list or lua array table containing options.
--- @return table or string If not selected: "". Otherwise the selected option as: {i = i, option = option}
function ZoneMenu.run(title, options_list)
	local ret = ""
	local choose = function(i, option) if not option or option == '' then ret = "" else ret = {i = i, option = option} end end
	local refuse = function() _MENU:RemoveMenu() end
	local max_elements = 6 -- 6: Enough for a thorough summary under  |  8: Just a tight summary under
	local menu_width = 180 -- Zone names + →  150: 1 icon  |  180: Some icons | 200: Most of screen
	
	local menu = ZoneMenu:new(title, options_list, choose, refuse, max_elements, menu_width)
	UI:SetCustomMenu(menu.menu)
	UI:WaitForChoice()
	return ret
end

function ZoneMenu.filter_options_list(options_list)
	local SKIP_DISABLED = true
	local SKIP_UNDISCOVERED = true
	local SKIP_UNCOMPLETED = false
	
	local filtered_optionList = {}
	
	ZoneMenu.init_zones_info(options_list)
	-- PrintInfo("ZoneMenu.filter_options_list(..): ZoneMenu.zones_full_info: " .. COMMON.print_r(ZoneMenu.zones_full_info, 1))
	
	for i=1, #options_list do
		
		local dungeon_unlock_state = _DATA.Save:GetDungeonUnlock(options_list[i])
		local enabled = ZoneMenu.should_zone_be_enabled(options_list[i])
		local is_undiscovered = dungeon_unlock_state == RogueEssence.Data.GameProgress.UnlockState.None
		local is_uncompleted = dungeon_unlock_state == RogueEssence.Data.GameProgress.UnlockState.Discovered
		local skip_as_undiscovered = SKIP_UNDISCOVERED and is_undiscovered
		local skip_as_uncompleted = SKIP_UNCOMPLETED and (is_uncompleted or is_undiscovered)
		
		if not skip_as_undiscovered and not skip_as_uncompleted and (not SKIP_DISABLED or enabled) then
			table.insert(filtered_optionList, options_list[i])
		end
	end
	
	return filtered_optionList
end

ZoneMenu.zones_full_info = nil
function ZoneMenu.init_zones_info(zones)
	if ZoneMenu.zones_full_info ~= nil then return end
	
	ZoneMenu.zones_full_info = {}
	for i=1, #zones do
		local zone_info = ZoneMenu.zone_all_segments_get_info(zones[i])
		
		if zone_info.elements then
			for i=1, #zone_info.elements do
				zone_info.elements[i] = rto_icons.element(zone_info.elements[i])
			end
		end
		
		if zone_info.levels then
			if zone_info.levels.min > zone_info.levels.max then
				zone_info.levels.min = "??"
				zone_info.levels.max = "??"
			end
		end
		
		ZoneMenu.zones_full_info[zones[i]] = zone_info
	end
end

function ZoneMenu.should_zone_be_enabled(zone_id)
	local zone_full_info = ZoneMenu.zones_full_info[zone_id]
	
	if zone_full_info.elements == nil or #zone_full_info.elements == 0 												then return false end
	if zone_full_info.levels == nil or zone_full_info.levels.min > zone_full_info.levels.max 	then return false end
	if zone_full_info.floors == nil 																													then return false end
	
	return true
end

function ZoneMenu.zone_all_segments_get_info(zone_id)
	local zone_info = {}
	
	local pokemon_zone_info = ZoneMenu.zone_all_segments_get_data(zone_id, "RogueEssence.LevelGen.TeamSpawnZoneStep", function(step, accum, context)
		local to_ret = {
			elements = accum.elements or {},
			floors = context.segmentData.FloorCount + (accum.floors or 0),
			levels = {
				min = accum.levels and accum.levels.min or 100,
				max = accum.levels and accum.levels.max or 0,
			},
		}
		
		-- Check Spawns
		local spawnlist = step.Spawns
		for j=0, spawnlist.Count-1, 1 do
			
			-- This actually refers to..... THE FLOOOOORSSSSSS!!!!! :S :S :S omg...
			-- local range = spawnlist:GetSpawnRange(j)
			-- to_ret.levels.min = math.min(to_ret.levels.min, range.Min)
			-- to_ret.levels.max = math.max(to_ret.levels.max, range.Max)
			
			
			local spawn = spawnlist:GetSpawn(j).Spawn -- RogueEssence.LevelGen.MobSpawn
			
			to_ret.levels.min = math.min(to_ret.levels.min, spawn.Level.Min)
			to_ret.levels.max = math.max(to_ret.levels.max, spawn.Level.Max)
			
			local mData = _DATA:GetMonster(spawn.BaseForm.Species)
			for form in luanet.each(mData.Forms) do
				table.insert(to_ret.elements, form.Element1)
				if form.Element2 ~= 'none' then
					table.insert(to_ret.elements, form.Element2)
				end
			end
			
		end
		
		to_ret.elements = COMMON.array_unique(to_ret.elements)
		return to_ret
	end)
	--[[
		pokemon_zone_info.elements = COMMON.array_unique(COMMON.array2D_flat(pokemon_zone_info.elements))
		pokemon_zone_info.floors = COMMON.array_sum(COMMON.array2D_flat(pokemon_zone_info.floors))
		
		local levels = {min = 100, max = 0,	}
		for i=1, #pokemon_zone_info.levels do
			levels.min = math.min(levels.min, pokemon_zone_info.levels[i].min)
			levels.max = math.max(levels.max, pokemon_zone_info.levels[i].max)
		end
		pokemon_zone_info.levels = levels
	]]
	
	local money_zone_info = ZoneMenu.zone_all_segments_get_data(zone_id, "RogueEssence.LevelGen.MoneySpawnZoneStep", function(step, accum, context)
		-- TODO: What if a dungeon has multiple steps?? ... RIP
		local to_ret = {
			poke = {
				min = accum.poke and accum.poke.min or 0,
				max = accum.poke and accum.poke.max or 0,
				--[[ calc = function(floor_no, StartAmount, AddAmount, team_potency)
					local newMin = StartAmount.Min + AddAmount.Min * floor_no * team_potency
					local newMax = StartAmount.Max + AddAmount.Max * floor_no * team_potency
					
					return RogueElements.RandRange(newMin, newMax):Pick(_DATA.Save.Rand);
				end ]]
			}
		}
		
		-- step.ModStates -- List of modifiers of the player team pokemons... Instrisics etc... ??
		
		-- TODO: Is this the way to get dungeon floors info?? O,o
		local max_floors = ((pokemon_zone_info and pokemon_zone_info.floors) and {pokemon_zone_info.floors} or {0})[1]
		
		to_ret.poke.min = step.StartAmount.Min + step.AddAmount.Min * 0 					or to_ret.poke.min
		to_ret.poke.max = step.StartAmount.Max + step.AddAmount.Max * max_floors 	or to_ret.poke.max
		return to_ret
	end)
	
	local item_zone_info = ZoneMenu.zone_all_segments_get_data(zone_id, "RogueEssence.LevelGen.ItemSpawnZoneStep", function(step, accum, context)
		-- TODO: What if a dungeon has multiple steps?? ...
		local to_ret = {}
		--[[ local to_ret = {
			poke = {
				min = accum.poke and accum.poke.min or 0,
				max = accum.poke and accum.poke.max or 0,
			}
		} ]]
		-- step.Spawns ???
		-- to_ret. ... = ...
		
		-- Keys: ammo / boosters / evo / fakes / held / necessities / orbs / snacks / special / throwable / tms / uncategorized
		--[[ for key in luanet.each(LUA_ENGINE:MakeList(step.Spawns.Keys)) do
			local cat_spawns = Spawns[key].Spawns
			cat_spawns.Count
			
			for
			
			item_id =
			
			//get all items within the spawnrangelist that intersect the current ID
			SpawnList<InvItem> slicedList = Spawns[key].Spawns.GetSpawnList(item_id);

			// add the spawnlist under the current key, with the key having the spawnrate for this id
			if (slicedList.CanPick && Spawns[key].SpawnRates.ContainsItem(item_id) && Spawns[key].SpawnRates[item_id] > 0)
					spawns.Add(key, slicedList, Spawns[key].SpawnRates[item_id]);
			
		end ]]
	
		return to_ret
	end)
	
	
	return COMMON.array_merge(zone_info, pokemon_zone_info, money_zone_info, item_zone_info)
end


function ZoneMenu.zone_all_segments_get_data(zone_id, step_id, step_callback--[[ , steps_merge_callback ]])
	-- local to_return = {}
	local accum = {}
	
	-- if steps_merge_callback == nil then
	-- 	steps_merge_callback = function(a, b) return COMMON.array_merge(a, b) end
	-- end
	
	local zData = _DATA:GetZone(zone_id)
	
	-- PrintInfo("ZoneMenu.zone_all_segments_get_data(): zData.Segments.Count: " .. COMMON.print_r(zData.Segments.Count, 1))
	
	for ii = 0, zData.Segments.Count-1, 1 do
		-- local to_return_segment = {}
		local segmentData = zData.Segments[ii]
		local segSteps = segmentData.ZoneSteps
		-- PrintInfo("ZoneMenu.zone_all_segments_get_data(): segSteps.Count: " .. COMMON.print_r(segSteps.Count, 1))
		for i = 0, segSteps.Count-1, 1 do
			local step = segSteps[i]
			
			-- PrintInfo("ZoneMenu.zone_all_segments_get_data(): COMMON.get_class_full(step): " .. COMMON.print_r(COMMON.get_class_full(step), 1))
			if COMMON.get_class_full(step) == step_id then
				-- to_return_segment = steps_merge_callback(to_return_segment, step_callback(step, {
				-- 	zone_id=zone_id,
				-- 	segment_i=segment_i,
				-- 	step_id=step_id,
				-- 	step_callback=step_callback,
				-- 	segmentData=segmentData,
				-- }))
				accum = step_callback(step, accum, {
					zone_id=zone_id,
					segment_i=segment_i,
					step_id=step_id,
					step_callback=step_callback,
					segmentData=segmentData,
				})
			end
		end
		
		-- table.insert(to_return, to_return_segment)
	end
	
	-- return to_return
	return accum
end