require 'rescue_team_outpost.menu.team.CustomTeamSelectMenu'
require 'rescue_team_outpost.menu.TeamsQuestingMenu'

rto_teams = {}

function rto_teams.edit_menu(EdittedTeam)
	PrintInfo("Point TEAMS#13")
  local team_new_name = ""
	local team_new_members = {}
	local name_ok
	
	repeat
		PrintInfo("Point TEAMS#13.1")
		local use_submenu = true
		local filter = function(char)
			local Member = rto_scriptvars.Member.fromChar(char)
			if Member:questing() then return false end
			if EdittedTeam and Member:in_team(EdittedTeam.name) then return 1 end
			if Member:in_any_team() then return false end
      return true
		end
		PrintInfo("Point TEAMS#13.7")
		-- team_new_members = AssemblySelectMenu.run(filter, use_submenu)
		team_new_members = CustomAssemblyMultiSelectMenu.runMultiMenu(filter, use_submenu, SV.rescue_team_outpost.settings.team_members_max)
		PrintInfo("Point TEAMS#13.8")
		if #team_new_members <= 0 then return end -- He must have hit a "Back" button
		PrintInfo("Point TEAMS#13.9")
		if not rto_restriction_pass_new_team_member_count(#team_new_members) then
			PrintInfo("Point TEAMS#13.10")
			UI:WaitShowDialogue(STRINGS:Format(
				"Each team can have between {0} and {1} members, you chose {2}",
				SV.rescue_team_outpost.settings.team_members_min,
				SV.rescue_team_outpost.settings.team_members_max,
				#team_new_members
			))
			PrintInfo("Point TEAMS#13.11")
			return
		end
		PrintInfo("Point TEAMS#13.12")
		
		while true do
			PrintInfo("Point TEAMS#13.13")
			UI:NameMenu("Team name", "ENTER: Confirm / Esc: Cancel", 116, (EdittedTeam and {EdittedTeam.name} or {""})[1])
			UI:WaitForChoice()
			team_new_name = UI:ChoiceResult()
			
      local name_is_unique = not rto_scriptvars.Team.exists(team_new_name)
      local name_remained_the_same = (EdittedTeam and {EdittedTeam.name == team_new_name} or {false})[1]
      local name_is_bad = (team_new_name == nil) or (team_new_name == "")
      name_ok = (name_is_unique or name_remained_the_same) and (not name_is_bad)
			if name_ok then break end
			
			UI:WaitShowDialogue(STRINGS:Format("Sorry, team named {0} already exists!", team_new_name))
		end
		PrintInfo("Point TEAMS#13.14")
	until name_ok
	
	local swap_team = EdittedTeam and EdittedTeam:is_active()
	
  if EdittedTeam then EdittedTeam:unregister() end
	
	local newTeam = rto_scriptvars.Team.fromData({
		name = team_new_name,
		members = team_new_members,
	})
	
	rto_teams.print_teams("edit_menu: After complete, teams: ")
	rto_teams.print_chars_to_teams()
	
	UI:WaitShowDialogue("Wosh!!!")
	UI:WaitShowDialogue(STRINGS:Format("Team {0} registered!", team_new_name))
	
	if swap_team then newTeam:set_active() end
end

function rto_teams.new_quest_menu(Team)
	PrintInfo("Point TEAMS#2")
	local zone_ids = rto_zones.ids()
	choices = ZoneMenu.filter_options_list(zone_ids)
	if #choices <= 0 then return end
	-- table.insert(choices, "Back")
	
	local result = ZoneMenu.run("Venture where?", choices)
	if result == "" then return end
	
	local zone_names = rto_zones.names()
	local zone_name_i_chosen = -1
	local zone_chosen = result.option
	-- Get the UNFILTERED index...
	for i, zone in pairs(zone_ids) do
		if zone == zone_chosen then zone_name_i_chosen = i end
	end
	local zone_name_chosen = zone_names[zone_name_i_chosen]
	if zone_name_chosen == "" then return end
	
	local zone_info = ZoneMenu.zones_full_info[zone_chosen]
	zone_info.id = zone_chosen
	zone_info.name = zone_name_chosen
	
	local quest_options = rto_teams.quest_options_menu(nil, zone_info)
	if quest_options == nil then return end
	
	PrintInfo("rto_teams -> zone_info: " .. COMMON.print_r(zone_info, 1))
	PrintInfo("rto_teams -> quest_options: " .. COMMON.print_r(quest_options, 1))
	Team:quest_start(zone_info, quest_options)
	PrintInfo("rto_teams.new_quest_menu -> Team: " .. COMMON.print_r(Team, 1))
	PrintInfo("rto_teams.new_quest_menu -> Team:get_quest(): " .. COMMON.print_r(Team:get_quest(), 1))
	PrintInfo("rto_teams.new_quest_menu -> Team:_data(): " .. COMMON.print_r(Team:_data(), 1))
	
	UI:WaitShowDialogue(STRINGS:Format("Wosh!!!"))
	UI:WaitShowDialogue(STRINGS:Format("Your team {0} has departed for {1}!", Team.name, zone_name_chosen))
end

function rto_teams.members_menu(Team)
	PrintInfo("Point TEAMS#3")
	CustomTeamSelectMenu.run(Team.name, Team:member_chars(), function(_) return true end, true)
end

function rto_teams.view_all_menu()
	PrintInfo("Point TEAMS#4")
	while true do
		
		local Team = rto_scriptvars.Team.fromName(rto_teams.pick_menu())
		if not Team then return end
		
		rto_teams.team_menu(Team)
	end
end

function rto_teams.view_team_quest_menu(Team)
	local Quest = Team:get_quest()
	PrintInfo("rto_teams.view_team_quest_menu -> Quest: " .. COMMON.print_r(Quest, 1) .. "")
	local departed = Quest.progress.floor > 0
	
	UI:WaitShowDialogue(
		"Team " .. Team.name .. " " ..
		(departed and ("is at floor " .. Quest.progress.floor .. " of ") or "is preparing for ") ..
		"zone "  .. Quest.zone_info.name ..", with the following mindset: "
	)
	
	UI:WaitShowDialogue(
		"Should use items: "  .. Quest.options["use_items"] .. "\n" ..
		"Should use orbs: " .. Quest.options["use_orbs"] .. "\n" ..
		"Will go in zone again and again: " .. Quest.options["loop"] .. "\n" ..
		"Will try to capture other pokemon: " .. Quest.options["capture"] .. "\n" ..
		"Will stop at floor: " .. Quest.options["max_floor"] .. "\n" ..
		"and with the strategy: " .. Quest.options["strategy"]
	)
end

function rto_teams.questing_teams()
	PrintInfo("Point TEAMS#6")
	local questing_teams = {}
	
	local team_names = rto_scriptvars.Team.names()
	for i, team_name in pairs(team_names) do
		local Team = rto_scriptvars.Team.fromName(team_name)
		if Team:questing() then table.insert(questing_teams, Team) end
	end
	
	return questing_teams
end

function rto_teams.view_questing_menu()
	PrintInfo("Point TEAMS#7")
	local questing_teams = rto_teams.questing_teams()
	if #questing_teams <= 0 then UI:WaitShowDialogue("No teams are currently on a quest!") return end
	
	local result = TeamsQuestingMenu.run("Questing Teams", questing_teams)
	if result == "" then return end
	
	local Team = result.option
	local menu_elements = {
		"View quest",
		"Cancel quest",
		"Back",
	}
	local menu_element_i_chosen = COMMON.show_choice_menu(STRINGS:Format("Quest"), menu_elements)
	
	if menu_elements[menu_element_i_chosen] == "View quest" then
		rto_teams.view_team_quest_menu(Team)
	end
	if menu_elements[menu_element_i_chosen] == "Cancel quest" then
		UI:WaitShowDialogue("Calling team back now...")
		Team:quest_cancel()
	end
end

-- Pick a team from the register (excluding current) and set it as active
function rto_teams.set_active_menu()
	PrintInfo("Point TEAMS#8")
	if not rto_teams_count_check() then return end
	local Team = rto_scriptvars.Team.fromName(rto_teams.pick_active_menu())
	if not Team then return end
	
	if Team:is_active() then
		UI:WaitShowDialogue(STRINGS:Format("Active team is already {0}![pause=30] Canceled", Team.name))
		return
	end
	
	Team:set_active()
end

-- Pick a team name from registered teams list, excluding current. Returns the team name
function rto_teams.pick_active_menu()
	PrintInfo("Point TEAMS#9")
	-- local names = COMMON.array_filter(rto_scriptvars.Team.names(), function(_, n) return n ~= rto_teams.active_team_name() end, false)
	-- return rto_teams.pick_menu(names)
	local names = COMMON.array_map(function(k, v)
		return (v ~= rto_teams.active_team_name() and {v} or {{v, false}})[1]
	end, rto_scriptvars.Team.names())
	return rto_teams.pick_menu(names, false)
end

-- Pick a team name from a list. Returns team name
function rto_teams.pick_menu(team_names, highlight_active)
  if team_names == nil then team_names = rto_scriptvars.Team.names() end
	if #team_names <= 0 then return end
  table.insert(team_names, "Back")
	
	local display_names = COMMON.array_values(team_names) -- Copy the array
	if highlight_active or highlight_active == nil then
		local active_team_name = rto_teams.active_team_name()
		for i, team_name in pairs(display_names) do
			if team_name == rto_teams.active_team_name() then
				display_names[i] = rto_teams.active_team_display_name()
			end
		end
	end
	
	local team_name_i_chosen = COMMON.show_choice_menu(STRINGS:Format("Those are your already set up teams!"), display_names)
	if team_name_i_chosen == #team_names +1 then return end -- Back
	
	return team_names[team_name_i_chosen]
end

function rto_teams.team_menu(Team)
	PrintInfo("Point TEAMS#11")
	
	local actions = {
		{"Members",																										},
		{"Edit",																 												},
		{"View Quest",		(not Team:is_active()) and 		 Team:questing()},
		{"Cancel Quest",	(not Team:is_active()) and 		 Team:questing()},
		{"Quest",				(not Team:is_active()) and not Team:questing()},
		{"Choose",				(not Team:is_active())												},
		{"Disband",			(not Team:is_active()) and not Team:questing()},
		{"Back",																												},
	};
	
	actions = COMMON.array_column(
		COMMON.array_filter(actions, function(_, v) return v[2] == nil or v[2] end, false),
		1
	)
	
	local msg = "What about it?"
	if Team:questing() then
		msg = "What about it? It's on a quest"
	elseif Team:is_active() then
		msg = "What about it? (Active team can't be sent to quest)"
	end
	local action_chosen_i = COMMON.show_choice_menu(msg, actions)
	local action_chosen = actions[action_chosen_i]
	
	if action_chosen == "Quest" then						rto_teams.new_quest_menu(Team)
	elseif action_chosen == "View Quest" then 	rto_teams.view_team_quest_menu(Team)
	elseif action_chosen == "Cancel Quest" then
		UI:WaitShowDialogue("Calling team back now...")
		Team:quest_cancel()
	elseif action_chosen == "Members" then 			rto_teams.members_menu(Team)
	elseif action_chosen == "Edit"   then 			rto_teams.edit_menu(Team)
	elseif action_chosen == "Choose" then 			Team:set_active()
	elseif action_chosen == "Disband" then 			rto_teams.unregister_confirm(Team)
	-- elseif action_chosen == "Back" then
	end
end

rto_teams.quest_options_machine_to_human = {
	{"Repeat", 						"loop"},
	{"Max floor limit", 	"max_floor"},
	{"Try to capture", 		"capture"},
	{"Strategy", 					"strategy"},
	{"Use orbs",	 				"use_orbs"},
	{"Use items", 				"use_items"},
}
rto_teams.quest_options_order = {"Repeat", "Max floor limit", "Try to capture", "Strategy", "Use orbs", "Use items", }
rto_teams.quest_options = {
	["Repeat"] 						= {["Choice"] = {["Default"] = "No", "Yes"}},
	["Max floor limit"] 	= {["Input"]	= {["Default"] = "None", ["Type"] = "Int", ["Nullable"] = true, ["Positive"] = true}},
	["Try to capture"] 		= {["Choice"] = {["Default"] = "No", "Yes"}},
	["Strategy"] 					= {["Choice"] = {["Default"] = "Balanced", "Slow", "Fast"}},
	["Use orbs"]	 				= {["Choice"] = {["Default"] = "No", "Yes"}},
	["Use items"] 				= {["Choice"] = {["Default"] = "No", "Yes"}},
}
function rto_teams.quest_options_menu(Team, zone_info)
	PrintInfo("Point TEAMS#12")
  
	-- New options / Edit existing
	local quest_options = {}
	if Team ~= nil then
		local team_quest_options = Team:get_quest().options
		for _, opt in pairs(rto_teams.quest_options_machine_to_human) do
			quest_options[opt[1]] = team_quest_options[opt[2]]
		end
	else
		for _, v in ipairs(rto_teams.quest_options_order) do
			quest_options[v] = COMMON.array_first(rto_teams.quest_options[v])["Default"]
		end
	end
	
	while true do
		
		local menu_elements = {}
		for _, v in ipairs(rto_teams.quest_options_order) do
			table.insert (menu_elements, table.concat({v, quest_options[v]}, ": "))
		end
		
		table.insert (menu_elements, 1, "Start") -- Prepend
		table.insert (menu_elements, "Back") -- Append
		
		
		local menu_element_i_chosen = COMMON.show_choice_menu(STRINGS:Format("Quest"), menu_elements)
		
		if menu_elements[menu_element_i_chosen] == "Back" then return nil end -- break end
		if menu_elements[menu_element_i_chosen] == "Start" then
			local toRet = {}
			for _, opt in pairs(rto_teams.quest_options_machine_to_human) do
				local val = quest_options[opt[1]]
				
				if opt[1] == "Max floor limit" and val == COMMON.array_pairs(rto_teams.quest_options[opt[1]])[1][2]["Default"] then
					val = zone_info.floors
				end
				
				toRet[opt[2]] = val
			end
			return toRet
		end
		
		local option_i_chosen = menu_element_i_chosen - 1
		local option_chosen = rto_teams.quest_options_order[option_i_chosen]
		local option_chosen_cur_val = quest_options[option_chosen]
		
		local option_chosen_info = COMMON.array_pairs(rto_teams.quest_options[option_chosen])[1]
		local opt_type = option_chosen_info[1]
		local switch = {
			["Choice"] = function(available_values)
				local firstV = nil
				local prevV = nil
				local vToSet = nil
				for k, v in pairs(available_values) do
					if firstV == nil then firstV = v end
					
					if prevV == option_chosen_cur_val then vToSet = v break end
					prevV = v
				end
				
				if vToSet == nil then vToSet = firstV end
				quest_options[option_chosen] = vToSet
			end,
			["Input"] = function(option_chosen_info_data)
				
				local inp_type = option_chosen_info_data["Type"] or "String"
				local inp_nullable = option_chosen_info_data["Nullable"] or false
				local inp_default = option_chosen_info_data["Default"] or nil
				
				local inp_positive = nil
				local inp_negative = nil
				local inp_nonzero = nil
				local inp_min = nil
				local inp_max = nil
				
				local inp_minL = nil
				local inp_maxL = nil
				local inp_pattern = nil
				
				if inp_type == "Int" then
					inp_default = option_chosen_info_data["Default"] or 0
					inp_positive = option_chosen_info_data["Positive"] or false
					inp_negative = option_chosen_info_data["Negative"] or false
					inp_nonzero = option_chosen_info_data["Nonzero"] or false
					inp_min = option_chosen_info_data["Min"] or nil
					inp_max = option_chosen_info_data["Max"] or nil
				end
				
				if inp_type == "String" then
					inp_default = option_chosen_info_data["Default"] or 0
					inp_minL = option_chosen_info_data["MinL"] or nil
					inp_maxL = option_chosen_info_data["MaxL"] or nil
					inp_pattern = option_chosen_info_data["Pattern"] or nil -- See more at: https://riptutorial.com/lua/example/20315/lua-pattern-matching
				end
				
				local user_input = nil
				local user_input_validated = nil
				repeat
					UI:NameMenu("Choose " .. option_chosen, "__desc__", 116, "")
					UI:WaitForChoice()
					user_input = UI:ChoiceResult()
					
					if user_input == "" then
						if not inp_nullable then return nil end
						user_input_validated = inp_default
						break
					end
					
					if not inp_nullable and (user_input == nil or user_input == "") then
						UI:WaitShowDialogue("Cannot be empty!")
						return nil
					end
					
					local user_input_validations = {
						["Int"] = function(u_inp)
							
							if tonumber(u_inp) == nil then
								UI:WaitShowDialogue("Must be a number!")
								return nil
							end
							u_inp = tonumber(u_inp)
							if u_inp ~= math.floor(u_inp) then
								UI:WaitShowDialogue("Must be an integer!")
								return nil
							end
							
							if inp_positive and u_inp < 0 then
								UI:WaitShowDialogue("Must be positive!")
								return nil
							end
							if inp_negative and u_inp > 0 then
								UI:WaitShowDialogue("Must be negative!")
								return nil
							end
							if inp_nonzero and u_inp == 0 then
								UI:WaitShowDialogue("Must be nonzero!")
								return nil
							end
							if inp_min and u_inp < inp_min then
								UI:WaitShowDialogue(STRINGS:Format("Must be at least {0}!", tostring(inp_min)))
								return nil
							end
							if inp_max and u_inp > inp_max then
								UI:WaitShowDialogue(STRINGS:Format("Must be at most {0}!", tostring(inp_max)))
								return nil
							end
							
							return u_inp
						end,
						["String"] = function(u_inp)
							
							if type(u_inp) ~= "string" then -- Just to make sure nothing weird happens...
								UI:WaitShowDialogue("Must be a string!")
								return nil
							end
							if inp_minL and string.len(u_inp) < inp_minL then
								UI:WaitShowDialogue(STRINGS:Format("Length must be at least {0}!", tostring(inp_minL)))
								return nil
							end
							if inp_maxL and string.len(u_inp) > inp_maxL then
								UI:WaitShowDialogue(STRINGS:Format("Length must be at most {0}!", tostring(inp_maxL)))
								return nil
							end
							if inp_pattern and not string.match(u_inp, inp_pattern) then
								UI:WaitShowDialogue("Format is invalid!")
								return nil
							end
							
							return u_inp
						end,
					}
					
					local user_input_validation = user_input_validations[inp_type]
					user_input_validated = nil
					if type(user_input_validation) == "function" then
						user_input_validated = user_input_validation(user_input)
					end
					
				until user_input_validated ~= nil
				
				-- if user_input_validated == nil then return end
				quest_options[option_chosen] = user_input_validated
			end,
		}
		local action = switch[opt_type]
		if action ~= nil then
			local option_chosen_info_data = option_chosen_info[2]
			
			if option_chosen == "Max floor limit" and zone_info ~= nil then
				option_chosen_info_data["Min"] = 1
				option_chosen_info_data["Max"] = zone_info.floors
			end
			
			action(option_chosen_info_data)
		end
		
	end
end

function rto_teams.unregister_confirm(Team)
	PrintInfo("Point TEAMS#1")
	UI:ChoiceMenuYesNo(STRINGS:Format("Are you sure you want to delete team {0}?", Team.name))
	UI:WaitForChoice()
	if not UI:ChoiceResult() then return end
	
	Team:unregister()
	
	UI:WaitShowDialogue(STRINGS:Format("Team {0} has been deleted!", Team.name))
end

function rto_teams.active_team_display_name() return _DATA.Save.ActiveTeam:GetDisplayName() end
function rto_teams.active_team_name() return _DATA.Save.ActiveTeam:GetReferenceName() end

--- See: Team -> quest_result_notifications(...)
function rto_teams.show_quest_results_menu()
	PrintInfo("Point TEAMS#14")
	RTODungeonResultsMenu.run(rto_scriptvars.Team.quests_result_notifications())
	rto_scriptvars.Team.process_quests_results()
end

-- DEBUG FUNCTIONS --------------------------------
function rto_teams.print_active_team()
	PrintInfo("Point TEAMS#15")
	PrintInfo("Active Team: " .. rto_teams.active_team_name())
	for i = 0, _DATA.Save.ActiveTeam.Players.Count - 1 do
		local char = _DATA.Save.ActiveTeam.Players[i]
		PrintInfo(" - " .. char.Name .. " (" .. char.LuaData.uid .. ")")
	end
end

function rto_teams.print_teams(prefix)
	PrintInfo("Point TEAMS#16")
	if prefix == nil then prefix = "Teams: " end
	PrintInfo(prefix .. COMMON.print_r(SV.rescue_team_outpost.teams, 1))
end
function rto_teams.print_chars_to_teams(prefix)
	PrintInfo("Point TEAMS#17")
	if prefix == nil then prefix = "chars_to_teams: " end
	PrintInfo(prefix .. COMMON.print_r(SV.rescue_team_outpost.char_to_teamname, 1))
end
