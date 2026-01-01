--[[
    scriptvars.lua
      This file contains all the default values for the script variables. AKA on a new game this file is loaded!
      Script variables are stored in a table  that gets saved when the game is saved.
      Its meant to be used for scripters to add data to be saved and loaded during a playthrough.
      
      You can simply refer to the "SV" global table like any other table in any scripts!
      You don't need to write a default value in this lua script to add a new value.
      However its good practice to set a default value when you can!
      
    --Examples:
    SV.SomeVariable = "Smiles go for miles!"
    SV.AnotherVariable = 2526
    SV.AnotherVariable = { something={somethingelse={} } }
    SV.AnotherVariable = function() print('lmao') end
]]--

SV.rescue_team_outpost = {
  settings = {
    team_members_min = 3,
    team_members_max = 12,
    minimum_assembly = 15,
  },
  introduced = false,
  outpost_status = 0,
  
  -- Example team, see: MODS\Rescue_Team_Outpost\Data\Script\rescue_team_outpost\functions\rto_scriptvars.lua: rto_scriptvars.Team.fromData: local Team = { ...
  teams = {},
  char_to_teamname = {},
}

