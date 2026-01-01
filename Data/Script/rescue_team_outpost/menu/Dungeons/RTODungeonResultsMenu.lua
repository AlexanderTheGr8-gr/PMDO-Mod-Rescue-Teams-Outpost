-- -----------------------------------------------
-- Multi Page Text Menu
-- -----------------------------------------------
-- Shows text and divides it in multiple pages
RTODungeonResultsMenu = Class('RTODungeonResultsMenu')

RTODungeonResultsMenu.SECTIONS = {
    "Summary",
    "Inventory",
    "Captures",
}



---------------------------------
-- TODO: implement
	
-- Use a menu like: B:\Αρχεία\Εργαστήριο\GMaking\PMDO-Proj\git-PMDODump-dev\PMDC\RogueEssence\RogueEssence\Menu\Items\SpoilsMenu.cs
-- Along with a menu like: B:\Αρχεία\Εργαστήριο\GMaking\PMDO-Proj\.NECRO-Command Center\publish\Data\Script\origin\menu\team\AssemblySelectMenu.lua
-- To build a simple: Quest results menu, where each tab will show each teams quest!
---------------------------------


function load_aliases()
    PrintInfo("Point DRMenu#1")
    return {
        GraphicsManager = RogueEssence.Content.GraphicsManager,
        Loc = RogueElements.Loc,
        Rect = RogueElements.Rect,
        MenuText = RogueEssence.Menu.MenuText,
        DialogueText = RogueEssence.Menu.DialogueText,
        DirH = RogueElements.DirH,
        MenuDivider = RogueEssence.Menu.MenuDivider,
        TITLE_OFFSET = RogueEssence.Menu.TitledStripMenu.TITLE_OFFSET,
        VERT_SPACE = 14,
        LINE_HEIGHT = 12,
        TextBlue = RogueEssence.Menu.MenuBase.TextBlue, --[[ Color(132, 132, 255) ]]
        Dir8 = RogueElements.Dir8,
        InputType = RogueEssence.FrameInput.InputType,
        _ = ''
    }
end

function RTODungeonResultsMenu.run(completed_quests_data)
    PrintInfo("Point DRMenu#2")
    local DEFAULT_SECTION = "Summary" -- "Summary" / "Inventory" / "Captures"
    
    PrintInfo("completed_quests_data: " .. COMMON.print_r(completed_quests_data, 1))
    
    repeat -- Allows to recreate "continue" behavior. Just hit "break"
        
        if completed_quests_data == nil or not COMMON.count_assoc_array(completed_quests_data) then break end
        
        RTODungeonResultsMenu.pages = {}
        _MENU:AddMenu(RTODungeonResultsMenu:new(completed_quests_data, DEFAULT_SECTION).menu, false)
    until true -- Allows to recreate "continue" behavior. Just hit "break"
end

--- @param section string One of RTODungeonResultsMenu.SECTIONS
function RTODungeonResultsMenu:initialize(completed_quests_data, section, page)
    if not COMMON.array_has_value(RTODungeonResultsMenu.SECTIONS, section) then
        error("RTODungeonResultsMenu:initialize(): section is not valid!")
        return
    end
    self.data = completed_quests_data or {}
    local first_team_name = COMMON.array_first(COMMON.array_keys(completed_quests_data))
    self.Team = rto_scriptvars.Team.fromName(first_team_name)
    self.section = section
    self.page = page or 1
    PrintInfo("self: " .. COMMON.print_r(self, 1))
    
    self['initialize'..section](self, page)
end

function RTODungeonResultsMenu:initializeSummary(page)
    local a = load_aliases()
    
    PrintInfo("self: " .. COMMON.print_r(self, 1))
    
    -- self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
    -- self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(Loc(16,16), 144, "Dungeons", choices_array, 0, 10, exit_fn, exit_fn)
    self.menu = RogueEssence.Menu.ScriptableMenu(a.GraphicsManager.ScreenWidth / 2 - 140, 16, a.GraphicsManager.ScreenWidth / 2 + 140, 224, function(input) self:Update(input) end)
    self.Bounds = a.Rect.FromPoints(a.Loc(a.GraphicsManager.ScreenWidth / 2 - 140, 16), a.Loc(a.GraphicsManager.ScreenWidth / 2 + 140, 224))
    
    -- self.Team = a.MenuText(_DATA.Save.ActiveTeam:GetDisplayName(), a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE + a.TITLE_OFFSET), a.DirH.None)
    self.Team = a.MenuText(_DATA.Save.ActiveTeam:GetDisplayName(), a.Loc(a.GraphicsManager.ScreenWidth / 2 - 140 + 5, a.GraphicsManager.MenuBG.TileHeight), a.DirH.Left)
    self.Title = a.MenuText(STRINGS:FormatKey("MENU_RESULTS_TITLE"), a.Loc(self.Bounds.Width / 2, a.GraphicsManager.ScreenWidth / 2 + 140 - 5), a.DirH.Right)
    self.Div = a.MenuDivider(a.Loc(a.GraphicsManager.MenuBG.TileWidth, a.GraphicsManager.MenuBG.TileHeight + a.LINE_HEIGHT), self.Bounds.Width - a.GraphicsManager.MenuBG.TileWidth * 2)
    
    local sumdata = self.data[self.Team.name]
    -- local sumdata_c = COMMON.count_assoc_array(sumdata)
    
    self.Descriptions = {}
    local i = 0
    if sumdata then
        for _, q_prog in pairs(sumdata) do
            local Q = q_prog.Quest
            
            self.Team = a.MenuText(_DATA.Save:GetTeam(q_prog.team_name):GetDisplayName() .. " (" .. STRINGS:FormatKey("MENU_RESULTS_COMPLETED_QUESTS", q_prog.completed_c) .. ")",
                a.Loc(a.GraphicsManager.ScreenWidth / 2 - 140 + 5, a.GraphicsManager.MenuBG.TileHeight), a.DirH.Left)
            break
            
            local message = ({
                [GameProgress.ResultType.Cleared] = STRINGS:FormatKey("MENU_RESULTS_COMPLETE", Q.zone_info.name),
                [GameProgress.ResultType.Rescue] = STRINGS:FormatKey("MENU_RESULTS_RESCUE", Q.zone_info.name),
                [GameProgress.ResultType.Failed] = STRINGS:FormatKey("MENU_RESULTS_DEFEAT", Q.zone_info.name),
                [GameProgress.ResultType.Downed] = STRINGS:FormatKey("MENU_RESULTS_DEFEAT", Q.zone_info.name),
                [GameProgress.ResultType.TimedOut] = STRINGS:FormatKey("MENU_RESULTS_TIMEOUT", Q.zone_info.name),
                [GameProgress.ResultType.Escaped] = STRINGS:FormatKey("MENU_RESULTS_ESCAPE", Q.zone_info.name),
                [GameProgress.ResultType.GaveUp] = STRINGS:FormatKey("MENU_RESULTS_QUIT", Q.zone_info.name),
            })[q_prog.status]
            
            if message == nil then
                if Q.zone_info.name == nil or Q.zone_info.name:match("^%s+$") then
                    message = STRINGS:FormatKey("MENU_RESULTS_VANISHED")
                else
                    message = STRINGS:FormatKey("MENU_RESULTS_VANISHED_AT", Q.zone_info.name)
                end
            end
            
            local diff_y = a.LINE_HEIGHT -- a.LINE_HEIGHT / a.VERT_SPACE
            
            table.insert(self.Descriptions, a.DialogueText(message,
                a.Rect(
                    a.Loc(a.GraphicsManager.MenuBG.TileWidth * 2                    , a.GraphicsManager.MenuBG.TileHeight + a.TITLE_OFFSET + a.VERT_SPACE * 2 + diff_y * i),
                    a.Loc(self.Bounds.Width - a.GraphicsManager.MenuBG.TileWidth * 4, a.GraphicsManager.MenuBG.TileHeight + a.TITLE_OFFSET + a.VERT_SPACE * 2 + a.LINE_HEIGHT * 2 + diff_y * i)
                ),
                a.LINE_HEIGHT, true, false, -1
            ))
            i = i + 1
        end
    end
    
    
    -- self.MoneyTally = a.MenuText(STRINGS:FormatKey("MENU_BAG_MONEY", STRINGS:FormatKey("MONEY_AMOUNT", _DATA.Save.ActiveTeam.Money)),
    --     a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE * 4 + a.TITLE_OFFSET), a.DirH.None)
    -- self.InvValueTally = a.MenuText(STRINGS:FormatKey("MENU_RESULTS_INV_VALUE", STRINGS:FormatKey("MONEY_AMOUNT", 0 --[[ Team:GetInvValue() ]])),
    --     a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE * 5 + a.TITLE_OFFSET), a.DirH.None)
    -- self.TotalTurns = a.MenuText(STRINGS:FormatKey("MENU_RESULTS_TOTAL_TURNS", 0 --[[ self.Ending.TotalTurns ]]),
    --     a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE * 9 + a.TITLE_OFFSET), a.DirH.None)
    -- self.TotalDungeonTime = a.MenuText(STRINGS:FormatKey("MENU_TIMER", 0 --[[ self.Ending:GetDungeonTimeDisplay() ]]),
    --     a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE * 10 + a.TITLE_OFFSET), a.DirH.None)
    
    self.MoneyTally = a.MenuText(STRINGS:FormatKey("MENU_BAG_MONEY", STRINGS:FormatKey("MONEY_AMOUNT", _DATA.Save.ActiveTeam.Money)),
        a.Loc(self.Bounds.Width / 2, a.GraphicsManager.MenuBG.TileHeight + a.VERT_SPACE * 11 + a.TITLE_OFFSET), a.DirH.None)
    
    
    self.menu.Elements:Add(self.Title)
    self.menu.Elements:Add(self.Div)
    self.menu.Elements:Add(self.Team)
    for _, desc in pairs(self.Descriptions) do self.menu.Elements:Add(desc) end
    self.menu.Elements:Add(self.Description)
    self.menu.Elements:Add(self.MoneyTally)
    -- self.menu.Elements:Add(self.InvValueTally)
    -- self.menu.Elements:Add(self.TotalTurns)
    -- self.menu.Elements:Add(self.TotalDungeonTime)
    
    
    self.dir_already_keydown = false -- TODO: Is dir_already_keydown really needed?? ...
    
    -- TODO
    self.page = 1
    self.PAGE_MAX = 1
    
    -- TODO
    -- self.page_num = a.MenuText("", Loc(self.menu.Bounds.Width - 8, 8),a.DirH.Right)
    -- self.page_text = a.DialogueText("", Rect(Loc(GraphicsManager.MenuBG.TileWidth * 2, GraphicsManager.MenuBG.TileHeight + 14 + 4),
    --     Loc(self.menu.Bounds.Width - GraphicsManager.MenuBG.TileWidth * 4, self.menu.Bounds.Height - GraphicsManager.MenuBG.TileHeight * 4)), 12)
    
    -- TODO
    -- self.menu.Elements:Add(self.page_num)
    -- self.menu.Elements:Add(a.MenuDivider(Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))
    ----------------------------------------------------------------------

    -- self:UpdateMenu()
end

function RTODungeonResultsMenu:initializeInventory(page)
    PrintInfo("Point DRMenu#5")
    
end

function RTODungeonResultsMenu:initializeCaptures(page)
    PrintInfo("Point DRMenu#6")
    
end

function RTODungeonResultsMenu:Update(input)
    PrintInfo("Point DRMenu#7")
    self['Update'..self.section](self, input)  -- TODO: Dynamically call the right update function based on section
    PrintInfo("Point DRMenu#8")
    
end

function RTODungeonResultsMenu:UpdateSummary(input)
    PrintInfo("Point DRMenu#9")
    local a = load_aliases()
    
    if input:JustPressed(a.InputType.Menu) or input:JustPressed(a.InputType.Confirm) or input:JustPressed(a.InputType.Cancel) then
        _GAME:SE("Menu/Confirm")
        _MENU:RemoveMenu()
        return
    end
    
    if input.Direction == a.Dir8.Left then
        _GAME:SE("Menu/Skip")
        _MENU:ReplaceMenu(RogueEssence.Menu.VersionResultsMenu(_DATA.Save, (_DATA.Save:GetModVersion().Count - 1) / RogueEssence.Menu.VersionResultsMenu.MAX_LINES))
    end
    if input.Direction == a.Dir8.Right then
        _GAME:SE("Menu/Skip")
        _MENU:ReplaceMenu(RogueEssence.Menu.InvResultsMenu(_DATA.Save, 0))
    end
    
    
    --[[
        if input.Direction == a.Dir8.None then
            self.dir_already_keydown = false
            return
        end
        
        if self.dir_already_keydown or (input.Direction ~= a.Dir8.Right and input.Direction ~= a.Dir8.Left) then return end
        
        -- TODO
        if self.PAGE_MAX == 1 then
            _GAME:SE("Menu/Cancel")
            self.page = 1
            return
        end
        
        local p_index = self.page-1
        local pgdiff = (input.Direction == a.Dir8.Right and {1} or {-1})[1]
        self.page = ((p_index+pgdiff) % (self.PAGE_MAX))+1
        _GAME:SE("Menu/Skip")
        self:UpdateMenu()
        self.dir_already_keydown = true
    ]]
end

function RTODungeonResultsMenu:UpdateInventory(input)
    PrintInfo("Point DRMenu#10")
    
end

function RTODungeonResultsMenu:UpdateCaptures(input)
    PrintInfo("Point DRMenu#11")
    
end



--[[ function RTODungeonResultsMenu:generatePages(index)
PrintInfo("Point DRMenu#12")
    local content = self.static[index].content
    local mode_index = 1
    if not RECRUIT_LIST.iconMode() then mode_index = 2 end

    local list = {}
    for page =1, #content, 1 do
        if(self.static[index].content_filter(page)) then --check if we should include this page
            if type(content[page]) == "table" then          --check if the page has modes
                table.insert(list, content[page][mode_index])  -- pick the right mode if so
            else
                table.insert(list, content[page])
            end
        end
    end
    return list
end

function RTODungeonResultsMenu:UpdateMenu()
    PrintInfo("Point DRMenu#13")
    --Update page number if it has more than one
    if self.PAGE_MAX > 1 then
        local page_num = "("..tostring(self.page).."/"..tostring(self.PAGE_MAX)..")"
        self.page_num:SetText(page_num)
    end

    self.page_text:SetAndFormatText(self.pages[self.page])
end ]]