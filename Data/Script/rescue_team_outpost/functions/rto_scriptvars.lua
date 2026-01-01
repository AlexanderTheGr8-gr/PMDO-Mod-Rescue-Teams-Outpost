rto_scriptvars = {}


-- TEAM CLASS
  rto_scriptvars.Team = {}

  --[[
    name
    members: array of [Member / C# Character / uids]
    Quest
  ]]
  --[[ zone_info example: Array (
      id
      name
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
  ---@param name string tData.name is the teams name
  ---@param members table tData.members is the members array of: Member / C# Character / uids
  ---@param Quest? rto_scriptvars.Quest|nil tData.Quest is the current Quest of the team
  ---@return nil
  function rto_scriptvars.Team.fromData(tData)
    if tData.name == nil then return nil end
    
    local Team = {
      is_team_class = 1,
      name = tData.name, -- We are obliged to set it, because this is the bridge of communication, between Team, and it's underlying data
      
      -- Affects characters!
      members = function(self, members)
        -- GET ------------------------------------------------
        if members == nil then return rto_scriptvars.Team.arr_to_members(self:member_uids()) end
        
        -- SET ------------------------------------------------
        local Members = rto_scriptvars.Team.arr_to_members(members)
        if not Members then
          self:_data().member_uids = {}
        else
          self:_data().member_uids = rto_scriptvars.Team.arr_to_uids(Members)
          for _, M in pairs(Members) do M:set_team(self) end
        end
      end,
      
      get_quest = function(self) return self:_data().Quest end,
      questing = function(self) return self:get_quest() ~= nil end,
      
      
      quest_start = function(self, zone_info, options)
        self:_data().Quest = rto_scriptvars.Quest.fromData({
          Team = self,
          zone_info = zone_info,
          options = options or {},
        })
        PrintInfo("rto_scriptvars.Team:quest_start() self:_data().Quest ".. COMMON.print_r(self:_data().Quest, 1) .."")
      end,
      
      -- Search: "zone_info example"
      quest_advance = function(self, lvls)
        
        PrintInfo("rto_scriptvars.Team:quest_advance(lvls=".. (lvls or "nil") ..") for team ".. self.name .."")
        
        PrintInfo("rto_scriptvars.Team:quest_advance: #0")
        
        local Q = self:get_quest()
        if not self:questing() or not Q.progress:get_ongoing() then return end
        
        lvls = lvls or 1
        for i = 1, lvls do
          PrintInfo("rto_scriptvars.Team:quest_advance: #1")
          local new_floor = Q.progress.floor + 1
          
          --[[ TODO: Damage / death calculation
            Zone pokemon lvls
            Team member lvls
            Team member elements
            Zone pokemon elements
            Team member healths
            Food consumption / remaining
            More logic ...
            Calculate status moves on floor available too
            %
          ]]
          local all_dead = false
          
          -- TODO: Floor succeed calculation
          local floor_succeed = true
          if all_dead then
            Q.progress.status = RogueEssence.Data.GameProgress.ResultType.Downed
            floor_succeed = false
            break
          end
          PrintInfo("rto_scriptvars.Team:quest_advance: #2")
          -- TODO: Exp calculation
          --[[ Q.progress.spoils.exp = COMMON.array_combine(
            COMMON.array_column(m_chs, "Name"),
            COMMON.array_fill(#m_chs, 0)
          )]]
          
          -- TODO: Items calculation
          -- Q.progress.spoils.items = ...
         
          -- TODO: Poke calculation
          local min_poke = Q.zone_info.poke.min
          local max_poke = math.max(min_poke + 1, Q.zone_info.poke.max / new_floor)
          local new_poke = math.random(min_poke, max_poke)
          Q.progress.spoils.poke = Q.progress.spoils.poke + new_poke
          PrintInfo("rto_scriptvars.Team:quest_advance: #3")
          local q_last_floor = Q:get_last_floor()
          if new_floor <= q_last_floor then
            Q.progress.floor = new_floor
            PrintInfo("rto_scriptvars.Team:quest_advance: #4")
          else
            Q.progress.status = (q_last_floor == Q.zone_info.floors and {RogueEssence.Data.GameProgress.ResultType.Cleared} or {RogueEssence.Data.GameProgress.ResultType.Escaped})[1]
            PrintInfo("rto_scriptvars.Team:quest_advance: #5")
            -- ↓ Complete actions
              UI:WaitShowDialogue("[Run 'Completion actions']")
              UI:WaitShowDialogue("[Assigning exp, lvling, obtaining items, etc]")
              UI:WaitShowDialogue("[Feature not implemented yet]")
              -- Possible: GAME:UnlockDungeon(zone_id)
              -- Maybe find a way to call the "ExitSegment" etc of each zone?? ... or maybe that will trigger bad stuff? ...
              -- Otherwise bring back reports... For example: Your team spotted a stairway at floor 5 etc
              
              -- Certainly: Here, EVEN THOUGH, you wont be notified of it, since you are in dungeon, must happen events like:
                -- Items lost
                -- Storage items consumption, because imagine meeting the team after 99 loops, each time using an escape orb, and you only had 10...
                  -- Iterations would see 10 each time, but you didn't have enough...
              -- Because the ongoig loops, will NOT be the same, depending the team bag
            -- ↑ Complete actions
            PrintInfo("rto_scriptvars.Team:quest_advance: #6")
            if not Q.options.loop then Q.progress.floor = 0
            else
              Q:history_archive_progress()
              self:quest_advance(new_floor - q_last_floor - 1) -- Here -1 is set, for returning to town and starting anew. Floor 0 means still in town
            end
            PrintInfo("rto_scriptvars.Team:quest_advance: #7")
          end
          PrintInfo("rto_scriptvars.Team:quest_advance: #8")
        end
        PrintInfo("rto_scriptvars.Team:quest_advance: #9")
      end,
      
      -- TODO: Should this actually return and the active progress, if it's not ongoing??? ... If not, how should users of function deal with that data??
      ---comment
      ---@param action? string ["mark" as notified, "remove" from history]
      ---@return table of QuestProgress
      quest_result_notifications = function(self, action)
        local Q = self:get_quest()
        if not self:questing() or not Q or COMMON.array_first(Q.history) == nil then return nil end
        
        local ret = {}
        for _, q_prog in pairs(Q.history) do
          repeat -- Allows to recreate "continue" behavior. Just hit "break"
            
            if q_prog.notified then break end
            
            if action then
              action = ({
                mark = function() q_prog.notified = true end,
                remove = function() table.remove(Q.history, 1) end,
              })[action]
              if type(action) == "function" then action() end
            end
            
            table.insert(ret, q_prog)
          until true -- Allows to recreate "continue" behavior. Just hit "break"
        end
        
        return ret
      end,
      
      -- Actually apply the data to storage / asselmby / bank etc
      quest_process_results = function(self, action)
        
        local quest_history = self:quest_result_notifications(action)
        for _, q_prog in pairs(quest_history) do
          repeat -- Allows to recreate "continue" behavior. Just hit "break"
            if q_prog:get_failed() then break end
            
            -- TODO: implement
            GAME:AddToPlayerMoneyBank(q_prog.spoils.poke)
            -- qpData.spoils.items
            -- qpData.spoils.captured
            -- qpData.spoils.exp
          until true -- Allows to recreate "continue" behavior. Just hit "break"
        end
        
        local Q = self:get_quest()
        if self:questing() and not Q.progress:get_ongoing() and not Q.options.loop then Team:quest_cancel() end
        
      end,
      
      quest_cancel = function(self)
        if not self:questing() then return end
        
        self.Quest = nil
      end,
      
      member_uids = function(self) return self:_data().member_uids end,
      member_chars = function(self)
        local chars = {}
        local mems = self:members()
        for _, m in pairs(mems) do
          table.insert(chars, m:char())
        end
        return chars
      end,
      
      
      
      unregister = function(self)
        for _, m in pairs(self:members()) do m:set_team(nil) end
        SV.rescue_team_outpost.teams[self.name] = nil
      end,
      
      can_quest = function(self) return not self:questing() end,
      
      is_active = function(self)
        return rto_teams.active_team_name() == self.name
      end,
      
      set_active = function(self)
        
        while _DATA.Save.ActiveTeam.Players.Count > 0 do _GROUND:SilentSendHome(_DATA.Save.ActiveTeam.Players.Count-1) end
        
        local chars = self:member_chars()
        for _, char in pairs(chars) do COMMON.silent_add_to_team(char) end
        
        _DATA.Save.ActiveTeam.LeaderIndex = 0;
        
        GAME:WaitFrames(10)
        SOUND:PlayBattleSE("EVT_Assembly_Bell")
        GAME:FadeOut(false, 20)
        GROUND:RefreshPlayer()
        
        GAME:SetTeamName(self.name)
        UI:WaitShowDialogue(STRINGS:Format("Changed to team {0}!", self.name))
        
        GAME:FadeIn(20)
      end,
      
      _data = function(self) return SV.rescue_team_outpost.teams[self.name] end,
      _init_data = function(self, tData)
        SV.rescue_team_outpost.teams[self.name] = {
          name = tData.name,
          member_uids = {},
          Quest = tData.Quest or nil,
        }
        self:members(tData.members) -- Auto-assign members to teams too
      end,
    }
    
    if not rto_scriptvars.Team.exists(tData.name) then Team:_init_data(tData) end
    return Team
  end
  
  function rto_scriptvars.Team.get_all()
    return COMMON.array_map(function(team_name, tData)
      return rto_scriptvars.Team.fromData(tData)
    end, SV.rescue_team_outpost.teams)
  end
  function rto_scriptvars.Team.count() return COMMON.count_assoc_array(SV.rescue_team_outpost.teams) end
  function rto_scriptvars.Team.exists(team_name) return not not SV.rescue_team_outpost.teams[team_name] end
  function rto_scriptvars.Team.names() return COMMON.array_keys(SV.rescue_team_outpost.teams) end
  
  function rto_scriptvars.Team.fromName(team_name)
    if not rto_scriptvars.Team.exists(team_name) then return nil end
    return rto_scriptvars.Team.fromData(SV.rescue_team_outpost.teams[team_name])
  end
  
  function rto_scriptvars.Team.fromActive()
    local name = rto_teams.active_team_name()
    local mem = {}
    for i = 0, _DATA.Save.ActiveTeam.Players.Count - 1 do
      table.insert(mem, _DATA.Save.ActiveTeam.Players[i])
    end
    if rto_scriptvars.Team.exists(name) then
      local Team = rto_scriptvars.Team.fromName(name)
      Team:members(mem)
      return Team
    end
    return rto_scriptvars.Team.fromData({
      name = name,
      members = mem,
    })
  end
  
  function rto_scriptvars.Team.members_type(members)
    if (not members) or (not members[1]) then return nil end
    if (type(members[1]) == 'string' or type(members[1]) == 'number')  then return "uids" end
    if (type(members[1]) == 'table') and (members[1].is_member_class) then return "members" end
    return "chars"
  end
  
  function rto_scriptvars.Team.arr_to_members(arr)
    local t = rto_scriptvars.Team.members_type(arr)
    if t == "uids"    then return rto_scriptvars.Team.uids_to_members(arr)
    elseif t == "chars"  then return rto_scriptvars.Team.chars_to_members(arr)
    elseif t == "members" then return arr
    else return nil end
  end
  
  function rto_scriptvars.Team.arr_to_uids(arr)
    local t = rto_scriptvars.Team.members_type(arr)
    if t == "members"    then return rto_scriptvars.Team.member_uids(arr)
    elseif t == "chars"  then return rto_scriptvars.Team.member_uids(rto_scriptvars.Team.chars_to_members(arr))
    elseif t == "uids" then return arr
    else return nil end
  end
  
  function rto_scriptvars.Team.arr_to_chars(arr)
    local t = rto_scriptvars.Team.members_type(arr)
    if t == "members"    then return rto_scriptvars.Team.member_chars(arr)
    elseif t == "uids"  then return rto_scriptvars.Team.member_chars(rto_scriptvars.Team.uids_to_members(arr))
    elseif t == "chars" then return arr
    else return nil end
  end
  
  function rto_scriptvars.Team.uids_to_members(uids)
    local members = {}
    for _, uid in pairs(uids) do
      table.insert(members, rto_scriptvars.Member.fromUID(uid))
  end
  return members
  end
  
  function rto_scriptvars.Team.member_uids(Members)
    local uids = {}
    for _, m in pairs(Members) do
      table.insert(uids, m:char().LuaData.uid)
    end
    return uids
  end
  
  function rto_scriptvars.Team.chars_to_members(chars)
    local members = {}
    for _, char in pairs(chars) do
      table.insert(members, rto_scriptvars.Member.fromChar(char))
    end
    return members
  end
  
  function rto_scriptvars.Team.sync_active_team()
    rto_scriptvars.Team.fromActive()
  end

  function rto_scriptvars.Team.quests_advance(floors)
    if floors == nil then floors = 1 end
    
    PrintInfo("rto_scriptvars.Team.quests_advance(floors=".. floors ..")")

    local Teams = rto_scriptvars.Team.get_all()
    for i, Team in pairs(Teams) do
      if Team:questing() then Team:quest_advance(floors) end
    end
  end
  
  function rto_scriptvars.Team.quests_result_notifications(action)
    local qrn = {}
    
    local team_names = rto_scriptvars.Team.names()
    for i, team_name in pairs(team_names) do
      local Team = rto_scriptvars.Team.fromName(team_name)
      if Team:questing() then
        if COMMON.array_first(Team:get_quest().history) ~= nil then
          qrn[team_name] = Team:quest_result_notifications(action)
        end
      end
    end
    
    return qrn
  end
  
  function rto_scriptvars.Team.process_quests_results()
    local team_names = rto_scriptvars.Team.names()
    for i, team_name in pairs(team_names) do
      local Team = rto_scriptvars.Team.fromName(team_name)
      if Team:questing() then Team:quest_process_results(remove) end
    end
  end
  
-- MEMBER CLASS
  rto_scriptvars.Member = {}
  
  function rto_scriptvars.Member.fromUID(uid)
    return {
      is_member_class = 1,
      uid = uid,
      
      char = function(self) return (rto_uids.get())[self.uid] end,
      
      get_team = function(self) return rto_scriptvars.Team.fromName(self:get_teamname()) end,
      questing = function(self)
        local Team = self:get_team()
        return (Team == nil and {nil} or {Team:questing()})[1]
      end,
      
      -- TODO: Does NOT affects team!
      set_team = function(self, Team)
        local char = self:char()
        SV.rescue_team_outpost.char_to_teamname[char.LuaData.uid] = (Team == nil and {nil} or {Team.name})[1]
      end,
      
      get_teamname = function(self)
        local char = self:char()
        return SV.rescue_team_outpost.char_to_teamname[char.LuaData.uid]
      end,
      
      in_any_team = function(self) return self:in_secondary_team() or self:in_active_team() end,
      in_team = function(self, teamname) return teamname == self:get_teamname() end,
      in_secondary_team = function(self) return self:get_teamname() ~= nil end,
      in_active_team = function(self)
        for char in luanet.each(LUA_ENGINE:MakeList(_DATA.Save.ActiveTeam.Players)) do
          if self:char().LuaData.uid == char.LuaData.uid then return true end
        end
        return false
      end,
    }
  end
  
  function rto_scriptvars.Member.fromChar(char)
    rto_uids.init_char(char)
    return rto_scriptvars.Member.fromUID(char.LuaData.uid)
  end
  
-- QUEST CLASS
  rto_scriptvars.Quest = {}
  
  function rto_scriptvars.Quest.isValidData(qData)
    return
      qData.Team      ~= nil and
      qData.zone_info ~= nil and
      1 == 1
  end
  
  -- Search: "zone_info example"
  function rto_scriptvars.Quest.fromData(qData)
    if qData == nil or not rto_scriptvars.Quest.isValidData(qData) then return nil end
    
    qData.is_quest_class = 1
    
    qData.get_last_floor = function(self)
      return (self.options.max_floor <= 0 and {self.zone_info.floors} or {math.min(self.options.max_floor, self.zone_info.floors)})[1]
    end
    qData.history_clear = function(self) self.history = {} end
    qData.history_archive_progress = function(self)
      table.insert(self.history, self.progress)
      self.progress = rto_scriptvars.QuestProgress.fromData({})
    end
    
    qData.options               = (qData.options            ~= nil and {qData.options}            or {{}})[1]
    qData.options.loop          = (qData.options.loop       ~= nil and {qData.options.loop}       or {false})[1]
    qData.options.max_floor     = (qData.options.max_floor  ~= nil and {qData.options.max_floor}  or {0})[1]
    qData.history               = (qData.history            ~= nil and {qData.history}            or {{}})[1]
    qData.progress              = (qData.progress           ~= nil and {qData.progress}           or {rto_scriptvars.QuestProgress.fromData({})})[1]
    -- // BUG Cyclic reference!! DO NOT set the inner object have a reference to the outer! Othewise, you will get infinite loops when printing!
    qData.progress.Quest        = function() return qData end
    qData.progress.last_floor   = qData:get_last_floor()
    
    return qData
  end

-- QUEST STATUS CLASS
  rto_scriptvars.QuestProgress = {}
  --- @param qpData table {status: RogueEssence.Data.GameProgress.ResultType. One of: Unknown, Downed, Failed, Cleared, Escaped, TimedOut, GaveUp, Rescue}
  function rto_scriptvars.QuestProgress.fromData(qpData)
    qpData = (qpData == nil and {{}} or {qpData})[1]
    
    qpData.is_quest_status_class = 1
    
    qpData.Quest              = (qpData.Quest               ~= nil and {qpData.Quest}               or {{}})[1]
    qpData.floor              = (qpData.floor               ~= nil and {qpData.floor}               or {0})[1]
    qpData.last_floor         = (qpData.last_floor          ~= nil and {qpData.last_floor}          or {0})[1]
    qpData.status             = (qpData.status              ~= nil and {qpData.status}              or {RogueEssence.Data.GameProgress.ResultType.Unknown})[1]
    qpData.spoils             = (qpData.spoils              ~= nil and {qpData.spoils}              or {{}})[1]
    qpData.spoils.poke        = (qpData.spoils.poke         ~= nil and {qpData.spoils.poke}         or {0})[1]
    qpData.spoils.items       = (qpData.spoils.items        ~= nil and {qpData.spoils.items}        or {{}})[1]
    qpData.spoils.captured    = (qpData.spoils.captured     ~= nil and {qpData.spoils.captured}     or {{}})[1]
    qpData.spoils.exp         = (qpData.spoils.exp          ~= nil and {qpData.spoils.exp}          or {{}})[1]
    
    qpData.get_ongoing = function(self) return self.status == RogueEssence.Data.GameProgress.ResultType.Unknown end
    qpData.get_failed = function(self)
      return ({
        [RogueEssence.Data.GameProgress.ResultType.Downed]    = true,
        [RogueEssence.Data.GameProgress.ResultType.Failed]    = true,
        [RogueEssence.Data.GameProgress.ResultType.TimedOut]  = true,
        [RogueEssence.Data.GameProgress.ResultType.GaveUp]    = true,
        
        [RogueEssence.Data.GameProgress.ResultType.Unknown]   = false,
        [RogueEssence.Data.GameProgress.ResultType.Cleared]   = false,
        [RogueEssence.Data.GameProgress.ResultType.Escaped]   = false,
        [RogueEssence.Data.GameProgress.ResultType.Rescue]    = false,
      })[self.status]
    end
    qpData.get_succeeded = function(self)
      return ({
        [RogueEssence.Data.GameProgress.ResultType.Cleared]   = true,
        [RogueEssence.Data.GameProgress.ResultType.Escaped]   = true,
        [RogueEssence.Data.GameProgress.ResultType.Rescue]    = true,
        
        [RogueEssence.Data.GameProgress.ResultType.Unknown]   = false,
        [RogueEssence.Data.GameProgress.ResultType.Downed]    = false,
        [RogueEssence.Data.GameProgress.ResultType.Failed]    = false,
        [RogueEssence.Data.GameProgress.ResultType.TimedOut]  = false,
        [RogueEssence.Data.GameProgress.ResultType.GaveUp]    = false,
      })[self.status]
    end
    
    return qpData
  end