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

--- Menu for viewing questing team(s).
TeamsQuestingMenu = Class("TeamsQuestingMenu", ScriptableMultiPageOptionsMenu)

--- Creates a new ``TeamsQuestingMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``options_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param options_list table an array, list or lua array table containing options.
--- @param confirm_action function the function called when a slot is chosen. It will have a option string passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 152.
--- @param label string the label that will be applied to this menu.
function TeamsQuestingMenu:initialize(title, options_list, confirm_action, refuse_action, max_elements, menu_width, label)
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
function TeamsQuestingMenu:generate_options()
	local options = {}
	
	for i=1, #self.optionList do
		
		local enabled = true
		local skip = false
		
		-- local status_icon = RogueEssence.Menu.MenuText(
		-- 		rto_icons.misc((completed and {"Tick"} or {"Cross"})[1]),
		-- 		RogueElements.Loc(10, 1),
		-- 		RogueElements.DirH.Right
		-- )
		local text = RogueEssence.Menu.MenuText(
			self.optionList[i].name,
			RogueElements.Loc(0, 1),
			(enabled and {Color.White} or {Color.Red})[1]
		)
		
		if not skip then
			table.insert(options, RogueEssence.Menu.MenuElementChoice(
				function() self:choose(i) end, -- Choice action
				enabled, -- Enabled
				-- status_icon, -- Elements #1
				text -- Elements #2
			))
		end
	end
	
	return options
end

--- Updates the summary window.
function TeamsQuestingMenu:updateSummary()
	--[[ zone_info example: Array (
			id → ambush_forest
			name → Ambush Forest
			poke → Array (
					max → 428
					min → 120
			)
			elements → Array (
					1 → 
					2 → 
					3 → 
					4 → 
					5 → 
					6 → 
					7 → 
					8 → 
					9 → 
					10 → 
					11 → 
			)
			floors → 12
			levels → Array (
					max → 33
					min → 22
			)
	) ]]
	
	PrintInfo("TeamsQuestingMenu:updateSummary(..): self.menu.CurrentChoiceTotal+1: " .. COMMON.print_r(self.menu.CurrentChoiceTotal+1, 1))
	PrintInfo("TeamsQuestingMenu:updateSummary(..): self.optionList: " .. COMMON.print_r(self.optionList, 1))
	local Team = self.optionList[self.menu.CurrentChoiceTotal+1]
	PrintInfo("TeamsQuestingMenu:updateSummary(..): type(Team): " .. COMMON.print_r(type(Team), 1))
	
	local Quest = Team:get_quest()
	
	self.side_summary_title_text:SetText("Quest: " .. Quest.zone_info.name)
	self.side_summary_floors_text:SetText("Floors: " .. Quest.progress.floor .. " / " .. Quest.options.max_floor)
	-- self.side_summary_levels_text:SetText("Lvl: " .. (not zone_info.levels and {"--"} or {zone_info.levels.min .. "-" .. zone_info.levels.max})[1])
	-- self.side_summary_money_text:SetText("PoKe: " .. ((not zone_info.poke or not zone_info.poke.min) and {"--"} or {zone_info.poke.min .. "-" .. zone_info.poke.max .. rto_icons.misc("$")})[1])
end

--- Updates the summary window.
function TeamsQuestingMenu:createSummary()
	local GraphicsManager = RogueEssence.Content.GraphicsManager
	
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
	self.side_summary_title_string = "Quest: "
	self.side_summary_title_text = RogueEssence.Menu.MenuText(
		self.side_summary_title_string,
		RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_title_text)
	
	-- self.side_summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))
	
	height_line = 2
	
	self.side_summary_floors_string = "Floors: "
	self.side_summary_floors_text = RogueEssence.Menu.MenuText(
		self.side_summary_floors_string,
		RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	)
	self.side_summary.Elements:Add(self.side_summary_floors_text)
	
	-- self.side_summary_levels_string = "Lvl: "
	-- self.side_summary_levels_text = RogueEssence.Menu.MenuText(
	-- 	self.side_summary_levels_string,
	-- 	RogueElements.Loc(80, 4*(height_line-1) + 8 * height_line)
	-- )
	-- self.side_summary.Elements:Add(self.side_summary_levels_text)
	
	-- height_line = 3
	
	-- self.side_summary_money_string = "PoKe: "
	-- self.side_summary_money_text = RogueEssence.Menu.MenuText(
	-- 	self.side_summary_money_string,
	-- 	RogueElements.Loc(16, 4*(height_line-1) + 8 * height_line)
	-- )
	-- self.side_summary.Elements:Add(self.side_summary_money_text)
	
	-- -- self.side_summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))
	
	-- height_line = 3
	
	
	self.menu.SummaryMenus:Add(self.side_summary)
	self:updateSummary()
end


--- Creates a basic ``TeamsQuestingMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param options_list table an array, list or lua array table containing options.
--- @return table or string If not selected: "". Otherwise the selected option as: {i = i, option = option}
function TeamsQuestingMenu.run(title, options_list)
	local ret = ""
	local choose = function(i, option) if not option or option == '' then ret = "" else ret = {i = i, option = option} end end
	local refuse = function() _MENU:RemoveMenu() end
	local max_elements = 6 -- 6: Enough for a thorough summary under  |  8: Just a tight summary under
	local menu_width = 180
	
	local menu = TeamsQuestingMenu:new(title, options_list, choose, refuse, max_elements, menu_width)
	UI:SetCustomMenu(menu.menu)
	UI:WaitForChoice()
	return ret
end
