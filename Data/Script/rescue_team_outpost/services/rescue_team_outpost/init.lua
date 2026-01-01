--[[
    Example Service
    General instructions: https://wiki.pmdo.pmdcollab.org/Services
    After declaring you service, you have to include your package inside the main.lua file!
]]--

-- Available Events: https://wiki.pmdo.pmdcollab.org/Service_Events
    -- Init, Deinit, Update, MusicChange,
    -- GraphicsLoad, GraphicsUnload,
    -- NewGame, UpgradeSave, Restart, SaveData, LoadSavedData,
    -- AddMenu, MenuButtonPressed,
    -- LossPenalty, ZoneInit, DungeonModeBegin, DungeonModeEnd, GroundModeBegin, GroundModeEnd,
    -- DungeonMapInit, DungeonSegmentStart, DungeonSegmentEnd, DungeonFloorEnter, DungeonFloorExit,
    -- GroundMapInit, GroundMapEnter, GroundMapExit, GroundEntityInteract
--

-- ResultType:
    -- RogueEssence.Data.GameProgress.ResultType.Unknown
    -- RogueEssence.Data.GameProgress.ResultType.Downed
    -- RogueEssence.Data.GameProgress.ResultType.Failed
    -- RogueEssence.Data.GameProgress.ResultType.Cleared
    -- RogueEssence.Data.GameProgress.ResultType.Escaped
    -- RogueEssence.Data.GameProgress.ResultType.TimedOut
    -- RogueEssence.Data.GameProgress.ResultType.GaveUp
    -- RogueEssence.Data.GameProgress.ResultType.Rescu
--

require 'origin.common'
require 'origin.services.baseservice'
require 'rescue_team_outpost.functions.rto_scriptvars'
require 'rescue_team_outpost.functions.rto_teams'
require 'rescue_team_outpost.menu.Dungeons.RTODungeonResultsMenu'

local RescueTeamOutpostService = Class('RescueTeamOutpostService', BaseService)

function RescueTeamOutpostService:RecordT(fname, args) PrintInfo("RescueTeamOutpostService:"..fname.. ", args -> ".. COMMON.print_r(args, 1) .."") end


function RescueTeamOutpostService:initialize() BaseService.initialize(self) PrintInfo('RescueTeamOutpostService:initialize()') end
function RescueTeamOutpostService:OnMusicChange(args) self:RecordT("OnMusicChange", args) end

-- function RescueTeamOutpostService:OnDungeonModeEnd(args) self:RecordT("OnDungeonModeEnd", args) end
function RescueTeamOutpostService:OnGroundModeBegin(args) rto_teams.show_quest_results_menu() end

function RescueTeamOutpostService:OnDungeonFloorExit(args)
    local lastDunRed = COMMON.ProgressResultType2string(DUNGEON:LastDungeonResult())
    
    local should_advance_quests = ({
        ['Unknown'] = true, -- Just got down a floor
        ['Cleared'] = true,
        ['Rescuing'] = true,
        
        ['Downed'] = false,
        ['Failed'] = false,
        ['Escaped'] = false,
        ['TimedOut'] = false,
        ['GaveUp'] = false,
    })[lastDunRed]
    
    if should_advance_quests then rto_scriptvars.Team.quests_advance() end
end







function RescueTeamOutpostService:UnSubscribe(_) end
function RescueTeamOutpostService:Subscribe(med)
    for _, event_name in pairs(EngineServiceEvents) do
        local listener_name = "On"..event_name
        if self[listener_name] ~= nil and type(self[listener_name]) == "function" then
            med:Subscribe("RescueTeamOutpostService", EngineServiceEvents[event_name], function(_, args) self[listener_name](self, args) end )
        end
    end
end
SCRIPT:AddService("RescueTeamOutpostService", RescueTeamOutpostService:new())
return RescueTeamOutpostService




--[[ function RescueTeamOutpostService:OnDungeonFloorEnd(_, _) -- Called when leaving dungeon floor
    assert(self, 'RescueTeamOutpostService:OnDungeonFloorEnd() : self is null!')
    local location = RECRUIT_LIST.getCurrentMap()
    RECRUIT_LIST.generateDungeonListSV(location.zone, location.segment)

    -- update floor count for this location
    RECRUIT_LIST.updateFloorsCleared(location.zone, location.segment, location.floor)
    RECRUIT_LIST.markAsExplored(location.zone, location.segment)
end ]]

-- Run as a coroutine for each service, once per frame.
-- function RescueTeamOutpostService:Update(_) --[[ while(true) coroutine.yield() end ]] end

-- DEMO Upgrade code
-- Called when version differences are found while loading a save
--[[ function RescueTeamOutpostService:OnUpgrade()
    assert(self, 'RescueTeamOutpostService:OnUpgrade() : self is null!')
    PrintInfo("RecruitList =>> Loading version")
    RECRUIT_LIST.version = {Major = 0, Minor = 0, Build = 0, Revision = 0}
    -- get old version
    for i=0, _DATA.Save.Mods.Count-1, 1 do
        local mod = _DATA.Save.Mods[i]
        if mod.Name == "Dungeon Recruitment List" then
            RECRUIT_LIST.version = mod.Version
            break
        end
    end

    --remove spoiler mode leftover data
    if not RECRUIT_LIST.checkMinVersion(3) then
        SV.Services.RecruitList_spoiler_mode = nil
    end

    --hide accidental dev mode message
    if not RECRUIT_LIST.checkMinVersion(2, 3, 1) then
        SV.Services.RecruitList_show_unrecruitable = nil
    end

    -- update dungeon list data
    local list =  RECRUIT_LIST.getDungeonListSV()
    if not RECRUIT_LIST.checkMinVersion(2, 2) then
        SV.Services.RecruitList_DungeonOrder = {}
        for zone, zone_data in pairs(list) do
            for segment, _ in pairs(zone_data) do
                if RECRUIT_LIST.checkMinVersion(2, 0) then
                    RECRUIT_LIST.generateDungeonListSV(zone, segment)
                else
                    RECRUIT_LIST.updateSegmentName(zone, segment)
                end
                RECRUIT_LIST.markAsExplored(zone, segment)
            end
        end
    end

    -- update dungeon order data
    if not RECRUIT_LIST.checkMinVersion(2) then
        local order = RECRUIT_LIST.getDungeonOrder()
        for _, entry in pairs(order) do
            if list[entry.zone] then
                for segment, _ in pairs(list[entry.zone]) do
                    RECRUIT_LIST.markAsExplored(entry.zone, segment)
                end
            end
        end

        -- add all completed dungeons
        for entry in luanet.each(_DATA.Save.DungeonUnlocks) do
            if entry.Value == RogueEssence.Data.GameProgress.UnlockState.Completed and
                    not RECRUIT_LIST.segmentDataExists(entry.Key, 0) then

                local data = RECRUIT_LIST.getSegmentData(entry.Key, 0)
                if data ~= nil then
                    local length = data.totalFloors
                    RECRUIT_LIST.updateFloorsCleared(entry.Key,0, length)
                    RECRUIT_LIST.markAsExplored(entry.Key, 0)
                end
            end
        end
    end

    PrintInfo("RecruitList =>> Loaded version")
end ]]

-- DEMO Add Menu code
-- Called when a menu is about to be added to the menu stack
--[[ function RescueTeamOutpostService:OnAddMenu(menu)
    local labels = RogueEssence.Menu.MenuLabel
    if menu:HasLabel() and menu.Label == labels.OTHERS_MENU then

        local enabled = true
        local color = Color.White
        local choice = RogueEssence.Menu.MenuTextChoice("Recruits", function () _MENU:AddMenu(RecruitListMainMenu:new(menu.Bounds.Width+menu.Bounds.X+2).menu, true) end, enabled, color)
        local choices = menu:ExportChoices()

        -- put in place of Recruitment Search if present
        local index = menu:GetChoiceIndexByLabel("OTH_RECRUIT")
        if index > 0 then
            choices[index] = choice
        else
            -- put right before Settings if present
            index = menu:GetChoiceIndexByLabel(labels.OTH_SETTINGS)
            -- fall back to either 1 or choices count if the check fails
            if index < 0 then index = math.min(1, choices.Count) end
            choices:Insert(index, choice)
        end
        menu:ImportChoices(choices)
    end
end ]]