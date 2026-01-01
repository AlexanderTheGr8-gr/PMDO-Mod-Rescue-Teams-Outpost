--[[
    ScriptableMultiPageOptionsMenu
    Based on SkillSelectMenu by MistressNebula

    Opens a menu with multiple pages that allows the player to select an option.
    It contains a run method for quick instantiation, as well as a way to open
    an (almost) exact equivalent of UI:RelearnMenu.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
    
    If you want a summary, search "summary" in this file.
]]
require 'origin.common'

--- Menu for selecting an option from a specific list of options.
ScriptableMultiPageOptionsMenu = Class("ScriptableMultiPageOptionsMenu")

--- Creates a new ``ScriptableMultiPageOptionsMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``options_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param options_list table an array, list or lua array table containing options.
--- @param confirm_action function the function called when a slot is chosen. It will have a option string passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 152.
--- @param label string the label that will be applied to this menu.
function ScriptableMultiPageOptionsMenu:initialize(title, options_list, confirm_action, refuse_action, max_elements, menu_width, label)
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
    self.menu.ChoiceChangedFunction = function() --[[ self:updateSummary() ]] end

    -- self:createSummary()
end

--- Loads the optionss that will be part of the menu.
--- @param options_list table an array, list or lua array table containing options
--- @return table a standardized version of the options list
function ScriptableMultiPageOptionsMenu:load_options(options_list)
    local list = {}
    
    if type(options_list) == 'table' then
        for _, option in pairs(options_list) do table.insert(list, option) end
    else
        for option in luanet.each(LUA_ENGINE:MakeList(options_list)) do table.insert(list, option) end
    end
    return list
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function ScriptableMultiPageOptionsMenu:generate_options()
    local options = {}
    for i=1, #self.optionList do
        
        local text_option = RogueEssence.Menu.MenuText(self.optionList[i], RogueElements.Loc(2, 1))
        table.insert(options, RogueEssence.Menu.MenuElementChoice(
          function() self:choose(i) end, -- Choice action
          true, -- Enabled
          -- text_zone, -- Elements #1
          -- text_charges -- Elements #2
          text_option -- Elements #1
        ))
    end
    return options
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the string of the chosen option.
--- @param index number the index of the chosen option.
function ScriptableMultiPageOptionsMenu:choose(index)
    self.choice = self.optionList[index]
    _MENU:RemoveMenu()
    self.confirmAction(index, self.choice)
end

--- Updates the summary window.
function ScriptableMultiPageOptionsMenu:updateSummary()
  -- self.summary:...(self.optionList[self.menu.CurrentChoiceTotal+1])
end

--- Updates the summary window.
function ScriptableMultiPageOptionsMenu:createSummary()
  -- local GraphicsManager = RogueEssence.Content.GraphicsManager
  -- -- See SkillSummary
  -- self.summary = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(RogueElements.Loc(16,
  --         GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 12 * 2 - 14 * 4), --LINE_HEIGHT = 12, VERT_SPACE = 14
  --         RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
  -- self.menu.SummaryMenus:Add(self.summary)
  -- self:updateSummary()
end




--- Creates a basic ``ScriptableMultiPageOptionsMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param options_list table an array, list or lua array table containing options.
--- @return table or string If not selected: "". Otherwise the selected option as: {i = i, option = option}
function ScriptableMultiPageOptionsMenu.run(title, options_list)
    local ret = ""
    local choose = function(i, option) if not option or option == '' then ret = "" else ret = {i = i, option = option} end end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = ScriptableMultiPageOptionsMenu:new(title, options_list, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end
