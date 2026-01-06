# PMDO Mod: Rescue Teams Outpost
Mod Rescue Teams Outpost for audinowho/PMDODump.

Mod currently, adds functionality for: Creating/managing teams, and dispatching them to do quests
<br>
<br>

[CONTINUE HERE](#continue_here)

### Features (So far):
- New "Shop": Rescue Teams Outpost
- Team management
	- Ceate / Edit Team
	- Choose Team as main
- Quests: Send Team to Dungeon (Makeshift. Does nothing after choosing dungeon)
<br>
<br>

---

### Legend
- {Event}
- [Menu]
- § Code action referenced
- MVC: Model View Control (Google it)

### """ROADMAP"""

---
- [X] TASK 0
	- [X] ORGANIZE everything you have written in correct groups.
		- [X] Organize in "ACTIVE TASK" / "FUTURE TASK" first!
---
- [ ] TASK 1
	- [X] MVC!
	- [ ] Split EVERYTHING, into smaller tasks/systems... In order to create many TINY functions!!!
		- [ ] Everything should end up like an Έκθεση!!
		- [ ] You start HERE! IN THE TASKS!!! NOT in code!!
		- [ ] you THEN propagate in code, the structure of interconnected functions...
		- [ ] Functions FOR EVERYTHING! Even for a small fart...
---
- [ ] TASK 2
	- [ ] Find the swiftest way possible, TO CLOSE the existing mod
		- [ ] You can test menus by providing dump data!! No need to run a complete mission!!
			- [ ] WHEN UI is ready, THEN run a complete mission, to check correct INTEGRATION only... damn you :S ...
	- [ ] Release version v1.0.0!!! (Actually 0.5, just don't name it 0.5 cause you'll scare people xD. No bugs here, just roadmap WAAAAY far from complete.)
---
- [ ] CALLBACK TASK 1
	- [ ] All classes should get a RTO prefix. Even the "meaningful" ones, like "Quest", because it's RTO's way of visualizing a Quest!!
---


- [ ] ACTIVE TASK
	- Info
		- Steps/Turns (Main team) -> Ticks (Universal) -> Floor progress (RTO Teams)
		- Ticks advanced based on Team.MainTeam.Quest.Progress.floor_turn_counter EVEN if floor ALREADY cleared (because team can traverse up-down)
	
	
	- [ ] MVC: Control
		- [ ] Events
			- #### Main Team Events
				- [X] On {Dungeon MainTeam turn completed} -> Increment Team.MainTeam.Quest.Progress.floor_turn_counter
					§ FIND: {Dungeon MainTeam turn completed}
					§ NEW FIELD: Team.MainTeam.Quest.Progress.floor_turn_counter: Team.MainTeam.Quest.Progress.floor_turn_counter
				- [X] On {Dungeon MainTeam change floor}
					- [X] Convert Team.MainTeam.Quest.Progress.floor_turn_counter to ticks (int div) ($converted_ticks), and preserve the remainder(X % Y)!! rather than resetting to 0!!
					- [X] Do $converted_ticks * {Quests tick}
					§ NEW FIELD: CONSTANTS.TURNS_PER_TICK
					§ FIND: {Dungeon MainTeam change floor}
					§ NEW FUNCTION: RTO_quests_tick(int ticks)
				- [X] On {Dungeon MainTeam exit} -> Menu: [Complete Summary Screen]
					- [X] Link it to normal flow = Before dungeon finish UI, events, etc
					§ FIND: {Main team dungeon completion handler}
					§ FIND: dungeon finish UI
				- [~] On {Dungeon MainTeam enter} -> Create a Quest and Record dungeon in a Quest.Contract.Dungeon
					§ FIND: {Dungeon MainTeam enter}
					§ NEW FUNCTION: Quest.fromMainTeamDungeon(Main Team, Current Dungeon): Quest
						? TODO: Quest data is still vague/undefined in my head...
						? What will become with the Quest data? Like "Contract" etc?
							- Maybe some things need to be nullable
				
			- #### UI Events
				- [X] On {[Manage Quests] -> View all} -> Menu: [Complete Summary Screen]
				- [~] On {Quest start} (After completing [New Quest])
					- [ ] Cache dungeon parameters:
						- [ ] FloorList
							- [ ] PokemonList
							- [ ] ItemList
							- [ ] GoldList
							- [ ] TrapList
							- [ ] Floor characteristics, (example: IsBossFloor)
					? TODO: RESEARCH: Dungeon Info / Creation (Lists: Pokemon spawns, item drops, etc etc)
					§ FIND: {Quest start}
					§ STORE REFERENCES: Quest.Contract.Dungeon
			
			- <h3 id="continue_here"><b><u>CONTINUE HERE</u></b></h3>
			- #### Misc Events
				- [ ] On {Quests tick}
					- [ ] Foreach Quest
						- [ ] If Floor 0 (Preparation Phase) just begin (With 1 tick)
						- [ ] Determine floor "turns/steps taken to proceed"
							- [ ] Create a function (floor analysis) that tells dungeon "size". Combine how many steps are required to finish the floor, from avg minimum, to EXHAUSTIVE complete (like, all available walkable tiles)
								- CURRENT VERSION: Consider using something for startes, like, dungeon size: tiny / small / normal / large / gigantic
									- Warning: floors are "square-like"!! So 2x should provide 4x ticks!! Not 2x!! Also some maps are perimeter based only
							§ FIND: Max steps per floor (the "Something is approaching" thing...)
							§ NEW FUNCTION: floor_size_info
								- [ ] All walkable tiles count
								- [ ] Avg stairs count (Maybe max radius?)
						- [ ] Advance progress counter:
							- [ ] "Quest Progress".currentTickProgress += 1
							- [ ] ticksPerRemoteFloor:
								- [ ] RTO team current floor size
								- [ ] Quest chosen speed matters
								- [ ] Quest pririty matters (is it reqruiting? Training? Those are ultra heavy)
								- [ ] Simple booleans matter, like, did you tick the: Open all traps? That adds somewhat
							- [ ] If >= then "Quest Progress".currentTickProgress = 0 and the team attempts to traverse one dungeon floor (full tick).
								- [ ] {RTO Team dungeon floor decending}
						§ NEW/EXISTING FUNCTION/FIELD: Quest.all
				- [ ] On {Ground Seconds pass} - Accumulate "long seconds" and use them as a tick
					- "Long seconds", means, if 20 turns in Dungeon take 60 seconds, the equivalent in Ground should be way more, like 120? Dunno
					- Thus, ticks happen while you are at city => Distress signals can work with normal flow
					- Balance is made, by not allowing you to farm their work, by sending them out and waiting
					- It feels more "natural", like, that time flows EVEN when you are at the city...
					- You could even make a nicer balance! Like: Time passes normally (So as to actually SEE events happening, rather than them being too unoften) BUT!! There is a cutoff! Like, you get max 2 steps while in city. Then time pauses!! To force you to be unable to farm other's work. It's not a manager or idle game after all!! xD
					- All those should be configurable, for the mod user. People may be fond of turning PMDO to manager game ... (shrug)
			
			- #### RTO Team Events
				- [ ] On {RTO Team dungeon floor decending} (Steps ordered)
					- ->
						- i) One could say that the path taken / steps/turns, are "Predefined", based on Quest Contract (what the team aims to do)...
							- [ ] Because, you know, the poke does not return where it already searched! ... So it's like a flood
							=> So, all mechanisms should count on how much steps the team will take in this floor!
						- !X Determine floor properties
							Actually ... I am thinking I should KEEP the actual objects... Instead of "Gathering info for my mod", I should rather learn to use the existing objects.... So as to be more flexible! And less RAM hungry xD
					
					- [ ] Calculate "encounters" based on "turns/steps taken to proceed"
						- [ ] Calculate "Moves used count" based on encounters
					- [ ] Simulate encounters
						- [ ] Choose enemy(s) using dungeon spawn table for that floor.
						- [ ] Foreach
							- [ ] Match Pokemons to each fight (Also calculate that as turns pass, an allied pokemon might engage)
							- [ ] Compute outcome:
								- [ ] Study combat, in order to define the outcome...
									- [ ] Maybe skip that for Version one with a simple formula?? ...
										- [ ] winProb = sigmoid( teamStrength / enemyStrength * statusModifiers ) where teamStrength = sum(memberOffense) * (1 + teamLevel*0.02) * moraleBonus and enemyStrength = sum(enemyOffense).
								- [ ] Calculate hp loss
								- [ ] Update Team.Pokemons[that_pokemon] stats (health, fainted), status etc
							- [ ] On {RTO team fight won}:
								- [ ] Calculate XP
							- [ ] On {RTO team fight badly damaged}:
								- [ ] Consider Quest Contract for escaping
								- [ ] Consider Quest Contract for using healing items
							- [ ] On {RTO team fight faint}:
								- [ ] Consider Quest Contract for escaping
								- [ ] Consider Quest Contract for using revive items
								- [ ] Consider Quest failed conditions??
								- [ ] Set Team.Pokemons[that_pokemon] as fainted
								-	If all team fainted: {RTO Team fainted}
							- [ ] Recruitment attempts:
								- [ ] If not recruitable / team full: break
								- [ ] Calculate recruit chance
									- [ ] account for boosting items / etc
								- [ ] If success, {RTO Team recruit success}
					- [ ] Food consumption:
						- [ ] Just like in Main team, based on: foodPerStep/Turn * turns/steps taken + "Moves used count" * foodPerMove
						- [ ] turns/steps taken, combo of: 
							- [ ] F: floor_size_info, steps to exit
							- [ ] Quest contract
								- [ ] Will be mopping whole floor? Quickly passing through?
								- [ ] ...
							- [ ] "Moves used count" => depends on: Simulate encounters
								- [ ] Combat intensity approximated by expectedEncounterCount * avgEnemyHP / avgTeamHP. Or more simply compute: expectedCombatRatio = 0.5 + 0.5 * encounterCount (tunable).
						- [ ] Subtract from mission inventory; if food falls below returnOnLowFoodPct * startingFood and autoReturn true → set mission aborted and initiate return handling.
					- [ ] Loot & items:
						- [ ] coins = randomBetween(minGold, maxGold) * (1 + thoroughnessBonus)
						- [ ] items: +thoroughnessBonus
							- [ ] when capacity exceeded:
								- [ ] Run item choice algorith
								- [ ] excess is left behind
					- [ ] NO TRAPS V.1 SPARE ME!!
					- [ ] {RTO Team dungeon floor decended}
				- [ ] On {RTO Team dungeon floor decended}
					- [ ] "Quest Progress".floorsCleared++
					- [ ] Check Quest Contract to see if Quest completed
						- [ ] Reached the end of dungeon
					- [ ] Check Quest Contract to see if Return policy Triggered
						- [ ] If "Quest Progress".floorsCleared >= targetFloor
						-? Pokemon rescued
						- [ ] Job completed
						- [ ] ...
				- [ ] On {RTO Team recruit success}
					- [ ] Add poke to the Team.Recruits stack
				- [ ] On {RTO Team leaving dungeon}
					- [ ] Award Exp
					- [ ] Append event to "Quest Progress".report for end-of-mission summary (encounters, items, recruits, damages).
				- [ ] On {RTO Team Success / Escape} (After {RTO Team leaving dungeon})
					- [ ] Apply small cooldown to Team
					- [ ] Award spoils
						- [ ] Recruits
						- [ ] items
						- [ ] coins
						- [ ] ...
					- [ ] Return items to storage
				- [ ] On {RTO Team fainted} (After {RTO Team leaving dungeon})
					- [ ] Apply hash cooldown to team
					- [ ] Options depend on Quest Contract and/or Return policy:
						- [ ] If ConsumeReviverItems set and items available — auto revive using item and continue (with HP/food penalty).
						- [ ] Else if PayRescueFee set and outpostHasFunds → spend coins and revive team (set morale penalty).
						- [ ] Else: mission failed — compute losses:
							- [ ] {RTO Team quest failed}
				- [ ] On {RTO Team quest failed} (After {RTO Team leaving dungeon})
					- [ ] Empty: Team.purse, Team.recruited, Team.bag
					- [ ] Surviving recruited Pokémon (if any) have a chance to escape (recruitment fails) or return injured.
					? Gold penalty: pay rescue / lost coins.
					- [ ] Team disbanded? Recommend NOT full permadeath by default. Instead mark team as injured and require restTicks to be reused. If you want a harder mode, offer permadeath toggle.
			
	- [ ] MVC: Model (Entities)
		- #### Paths
			- (Registered for mass replace later on...)
			- Team.MainTeam.Quest.Progress.floor_turn_counter
			- CONSTANTS.TURNS_PER_TICK
			- RTO_quests_tick(int ticks)
			- Quest.fromMainTeamDungeon(Main Team, Current Dungeon): Quest
			- Quest.all
		- [ ] Team
			- [ ] Link: Team.Bag
			- [ ] Link: Team.Purse
			- [ ] Link: Team.Recruits
			- [ ] Link: Team.Pokemon
			- [ ] Static: Team.MainTeam: active team reference/index
		- [ ] Team.Bag
		- [ ] Team.Purse
		- [ ] Team.Recruits
		- [ ] Team.Pokemon
		- [ ] Main team
		
		- [ ] Quest
			- [ ] Link: Quest.Contract
			- [ ] Link: Quest.Progress
			- [ ] Link: Job
		
		- [ ] Quest.Contract (Options)
			- [ ] Link: Quest.Contract.Dungeon
		
		- [ ] Quest.Contract.Dungeon
			
		- [ ] Quest.Progress
			- [ ] Quest.Progress.floor_turn_counter: Used only for Main Team
			- [ ] Possible stages:
				- [ ] Preparation (Barely confirmed mission)
				- [ ] Ongoing [F: Quest failed] / Returning
				- [ ] Completed / Fainted
		
		- [ ] Mod_save_data:
			- ...
		
		- [ ] Arbitrary data:
			- [ ] Location: Organize Teams (Home)
				- [ ] At: Storage box, since currently there is no "Home"
				- [ ] Menu: [Manage Teams]
			- [ ] Location: RTO
				- [ ] Menu: [Manage Teams]
				- [ ] Menu: [Manage Quests]
		
		- [ ] Lore
			- [ ] balance cooldowns is that pokemon need to relax, they are not slaves! ^_^
	
	- [ ] MVC: View
		- [ ] [Manage Quests]:
		- [ ] [Manage Teams]:
			- [ ] 1st option: New
				- [ ] On select: [New team menu]
			- [ ] Rest options: Show Teams
				- [ ] On select: [Team context menu]
		- [ ] [Quest contract]: Where you define what the team should do (Alias: Quest options)
			- [ ] options before departing:
				- [ ] Target dungeon (Sub menu)
				- [ ] Objective / Mission priority (affects AI behaviour):
					Clear dungeon / Survival / Target floor / Reach the deepest you can: avoid risky fights; auto-return on low food or heavy damage. / Reach the end of dungeon
					Loot / Gold — pursue items and gold; may take more risk.
						- [ ] Sub-choice: rare items priority (or items you dont have much of) / valuable items
					Recruit — maximize recruitment attempts (use bait/berries if available); moderate risk.
						- [ ] Sub-choice: All / Unrecruited
					Training - seek EXP
				- [ ] Exploration speed (affects speed vs thoroughness vs risk):
					- [ ] Rush/SpeedRun — 1-- tick per floor, low item/recruit chance, low enemy encounter modifier.
					- [ ] Normal — 1 tick per floor, baseline rates.
					- [ ] Thorough — 2 ticks per floor (every 2 main floors = remote advances 1 floor), higher item/recruit chance, higher food consumption and higher enemy spawn chance.
					- [ ] Exhaustive - Give it your all
				- [ ] Auto-revive policy:
					- [ ] ConsumeReviverItems (yes/no) — whether reviver seeds / revival items are consumed automatically. (That goes for items you supply, or found in-dungeon...)
					- [ ] PayRescueFee (!!!) (yes/no) — if wiped, automatically spend outpost coins to perform rescue (if you want a non-permanent loss option).
				- [ ] Carry load:
					- [ ] Choose items to send
						- [ ] Set limitations, like, don't send items if invenrory has less or equal to ... (Default 1)
					- [ ] Send when not fully Equipped?
						- [ ] Even without Escape Orb? (DANGER!)
				- [ ] AI tactics:
					- [ ] Capture Pokemon
					- [ ] Expose traps
					- [ ] Use items
				- [ ] Return policy:
					- [ ] ReturnOnLowFoodPct (e.g. 20%)
					- [ ] AbortOnAnyFaint (if >Y% of team HP lost)
					- [ ] AbortOnMajorLoss (if >Y% of team HP lost)
					- [ ] AbortOnQuestFailed (...?)
					- [ ] Don't return ..... xD ... hahaha, give it your all or die trying xD
		- [ ] [Complete Summary Screen]: Modal that shows summary of quests, and per-team quest info
			- [ ] Instead of being like: Team A ... recruited ... , Team B ... recruited ... , Team C ... recruited ...
			- [ ] BE LIKE: SUM: Coins: + ..., New Recruits: + ..., ... !!! AND THEN(!!!) ONLY IF CHOSEN (arrows?) show per team!!! ;) GODLIKE!!
				- [ ] Teams dungeons shown should be sorted like this: Completed first, ongoing next. You could even place comp->right, ong->left :D ... (and sum in the middle)
		? Explore: View shape:
			- [ ] Short summary (possibly multiple forms of that, for multiple places)
				- [ ] Those could come also in important pop-up notifications...
			- [ ] COMPLETE info
				- [ ] For both dungeon completion AND active dungeons...
	
- [ ] FUTURE TASK [HOT]
	- [ ] Make mod configurable!!! [Tutorial](https://wiki.pmdo.pmdcollab.org/Tutorial:Adding_New_Settings)
		- Also see: "SettingsTitleMenu.cs", for "The default settings page initialized" ... I gues that means "The default menu object stuff you will get prefabed in Lua, when you will follow the tutorial"
- [ ] FUTURE TASK
	- [ ]
	- [ ] BE CALLED IN!!! :D .... Like, a Team you sent is requesting for backup! It needs help to make it out and sent a distress signal! and a psycic can teleport you in! (And you fight in a battle supporting your team!) Of course, this would only make sense to be responded with your presence when you ALREADY are in town... I mean, imagine taking your sweet time returning back ... They would have already fainted xD
		- To make it more interesting, it coule be only 1 Poke can go! So instead of a "Oh-the-top-team-came-it-will-be-over-in-3-senconds" which quickly becomes boring, it goes to a kinda thrilling "I-get-to-fight-side-by-side-with-a-team-I-dont-use-because-I-find-it-lowlife"!! And you get the fresh experience of fighting next to a NPC TEAM (No, you WONT directly control the, they have THEIR leader, you know??) that "does not feel yours"! xD Since you would never use it, if not for RTO xD ....
	- [ ] Simulate encounters
		- [ ] Use priority to adjust winProb and AI choices: Survival reduces engagements (higher flee probability)
	- [ ] Events
		- [ ] On {Dungeon MainTeam change floor} -> {Quests tick} (Exploration team progress speed)
			- Consider to spread the calculations out, bg processes, rather than a single mega-calculation per tick...
		- [ ] On {RTO team needs help (fainted)} -> [Bubble Popup Message]
			- [ ] {Requirement: Telecommunication bridge between: Incident - Base - Main team}
		- [ ] On {Quests tick} (Steps ordered)
				- [ ] you walk => All those must be processed "In parallel"...
					- [ ] You meet traps
					- [ ] You meet pokemon
					- [ ] You meet items
					- [ ] You meet coins
					- [ ] Exit / Hidden exit / Anomally / etc-etc
					- [ ] You meet puzzles!!
					- [ ] You meet risky bargains!! (Like, switch the trap, get treasures and TROUBLES!!)
		- [ ] On {RTO Team dungeon floor decending} (Steps ordered)
			- [ ] Traps & hazards:
				(Traps should "carry stuff" to the following battles, like if it was not insta damage, life diminishes little by little => in next battle you are damaged! Because damage slowly heals)
				-	Trap triggers reduce HP or consume items. trapChance = baseTrapRate * dungeonTrapModifier * modeTrapMod.
		- [ ] On {RTO Team quest failed} (After {RTO Team leaving dungeon})
			- [ ] Consider:   Lost items: only a percentage of carried items are lost to the dungeon.
			- [ ] Consider:   Gold penalty: pay rescue / lost coins.   Pay some prise, EVEN if you chose not to rescue. EVEN without money (recorded as dept. Can't use RTO until payed). Otherwise members should be disbanded.. (lost in the dungeon)
			- [ ] Consider:   Surviving recruited Pokémon have a chance to escape
			- [ ] Consider:   Team disbanded? Recommend NOT full permadeath by default. Instead mark team as injured and require restTicks to be reused. If you want a harder mode, offer permadeath toggle.
	- [ ] Splice from mod:
		- [ ] "Team manager" mod: add it to storage box
		- [ ] "Pokemon IDs" mod: Each pokemon in the assembly is unique! It's an entity! It exists!! You can't store them in there as "a bunch of data"!! Otherwise boundaries mix! Who's who??
	- [ ] Player feedback
		? Expand this?
	- [ ] Lore: Like who was the first to concieve of forming teams, etc etc etc
	? I should create a "Dungeon Exploration AI"... Something like "Team Leader AI"...
		- [ ] So that, will be able to hold data like "I want to go home". Because from that moment, until YOU ACTUALLY CAN, go home.... it may be like 5 floors!! >,< .. Because you had no esc orb, and you found one later...
	- [ ] Spot all items/moves that are related to the win spoils!! Like, "pay day", exp boosters, friend arrow, etc etc etc!
		- [ ] Consider adding debuffs, in the sense that "Only the main player team should be THAT powerful" (Configurable in settings?)
	- [ ] Exploration team progress speed
		- [ ] Advances time:
			- [ ] What else?? .... hmmmmmm....
		- [ ] Create a function (floor analysis) that tells dungeon "size". Combine how many steps are required to finish the floor, from avg minimum, to EXHAUSTIVE complete (like, all available walkable tiles)
			(Warning: floors are "square-like"!! So 2x should provide 4x ticks!! Not 2x!! Also some maps are perimeter based only)
			\> tiny / small / normal / large / gigantic
		- [ ] What affects speed:
			- [ ] ? What else ?
	- [ ] Outpost upgrades!!!
		- [ ] Upgrade to allow more teams!
		- [ ] Upgrade to allow bigger bags! (Yes, not 24 like your bag, something like 12! to begin with or EVEN 6!)
		- [ ] Upgrade to add more team members! (Start with 2, 3, or 4! But not more. Upgrade up to... 8?)
		- [ ] Upgrade to allow more helping hands, like
			- [ ] Phsycics, more upgrades = more phsycics
				- [ ] Phsycics can help this way too:
					- [ ] In exteme high levels, they can have the team start from a specific floor!! O.O
						- [ ] (Maybe with some extra cost?) : YOUR TEAM TOO!!!! O.O (omg!!)
					- [ ] When in main team, no matter if you have no Phsycics capable in RTO, they can communicate back! So no matter if RTO has info on other teams, at least you have contact to RTO! And know all they know
					- [ ] When in main team, they can teleport staff back and forth your storage!
						- [ ] The greater power they posses, the more items per PP can be transfered!
			- [ ] Healing pokemon, more upgrades = more healers
			- [ ] What other positions could come in handy exploring the dungeons??
				- ...
	- [ ] All those "positions" opened, like phsycics for telecomunication, etc etc, need a new UI to show info in a good way
	- [ ] Ghosts in secondary team allow for faster traversing!! (They can reach for stairs, IF that is the strategy. Also the more, the higher the chance. In an logarithmic way! Example, 1 adds 5%, but 5 add 40% buff - cause they split)
	- [ ] It's VERY possible in the starting steps, when no psychic is available, to have a team lose, wait there for rescue, and eventually perma-faint, only for you to find out later... WELL! SINCE YOU DONT HAVE TELECOMMUNICATIONS!!
	- [ ] As described elsewhere, Telecommunications matter like a centered web: What matters is:
		- [ ] Communication of EACH secondary to the RTO
		- [ ] While the same time, communication of RTO to main team TO be INFORMED!
	- [ ] options before departing:
		- [ ] Auto-revive policy:
			- [ ] PayRescueFee (!!!) (yes/no) — if wiped, automatically spend outpost coins to perform rescue (if you want a non-permanent loss option).
				- [ ] OTHERWISE, note the location of fainting, and create INTERNAL JOB!!!
					- [ ] That can either be completed by main team, or secondary teams, OR EVEN HIRE OTHER TEAMS FROM OUTPOST!!!!
					- [ ] After some ticks have passed, fainted teams faints permanently, one of many possibilities happen:
						- [ ] Items/coins lost
						- [ ] Injuries (taking part cooldowns)
						- [ ] Pokemon disbanded from player Assembly .... yes, this kind of penalties make sense, not to go TOO haywire with this system... It's high gain HIGH RISK system...
							- [ ] BUT!!!! BUT!!! BUT!! This means ME, the F***ING DEV, MUST DO A PERFECT job to allow such a "tragedy" to befall the user.... To make sure NO bug happens, NO mis-conception, that MULTIPLE helps and warnings were given to the player...
					- [ ] Possibly psycic pokemon have these skills, if assigned at post of "Outpost helpers":
						- [ ] Telecommunication. Like, gathering info, for example a secondary team failed, and COMMUNICATING info, like "Team X-Y-Z" you are requested to return (Otherwise calls to "stop" matter only on recurring missions, since none can notify team that already departed. And if it was a once only, well yeah, when they came of course they would stop xD ...), or like "Hey main team, whom you are in the 20th floor of X, team Z failed!! You should come back to save them!", no response in like 3 ticks? Again!! Inform they will be dieing ... the situation is dire!! No response till example 7 ticks? Perma-faint.
						- [ ] Teleport To Main party (or possible to secondaries too, to increase success rates)
						- [ ] The higher the "power" of the phsyic, the greater it's abilities, like, lower cooldowns, higher skills reach, etc etc etc.
		- [ ] [Completely futuristic idea: Spectate team ... O.O ... XDDD ... Like, run the actual simmulation!!]
		- [ ] MAKE OPTIONS TEMPLATEABLE!!!
			- [ ] Possibly edit then templates, and leave only SOME of the options... to do things like having 6 templates, 3 for half options and 3 for the rest half... (Instead of 9 combinations...)
		Recruit — maximize recruitment attempts (use bait/berries if available); moderate risk.
			- [ ] Sub-choice: ?? (Maybe recruit specific? Does not seem good, too OP. Maybe reward this?)
		- [ ] AI tactics:
			// - EngageBosses
			- [ ] ... ?
		- [ ] Return policy:
			- [ ] ...?
		- [ ] ... ?
	- [ ] Entities:
		- [ ] Telecommunication (!)
		- [ ] Team
			- [ ] OutOfDungeon Condition (Injuries etc)
		- [ ] Quest
			- [ ] Faint location
		- [ ] """Rescue fainted team"""...
	- [ ] Extra features?
		- [ ] Auto-assign teams to posted jobs (AI uses outpost teams to auto-fulfill contracts).
			- [ ] When a team becomes a specific dungeons "master", like finished it ok 10 times, it then get's a "star" on the dungeon, and can pick jobs on it!! :D (So you get a bonus for NOT disbanding your teams...)
				- [ ] Maybe there should be limits, like 60% of pokemons making of a team should NOT leave, for team history to reamain, maybe with like: max changes 2/"""month""" ... Otherwise history resets / it's another team now, just with same name.
		- [ ] ?? Team specializations / skills: ??
		- [ ] Garrison building (!!) : upgrades to outpost that increase carry capacity, reduce cooldowns
		- [ ] Mission contracts (!):  player posts a job to outpost for other teams!! Like, get me a X item! Or, rescue my team! Or ... ??? Why should they get it from us? Maybe we exchange items?? Or dunno.
			- [ ] What missions would make sense for the PLAYER to set?
				- [ ] Fainted secondary team (calculate cost)
				- [ ] IF you have telecommunication between RTO-Main team: Main team faint job (calculate cost live)
				- [ ] ??? ... as a means to get some item?? Maybe a MUCH paid way to ask for specific items??
			- [ ] ESCORT!!! ESCORT ESCORT ESCORT!!! PAID ESCORT!!!! (The deeper the costier!!!)
	- [ ] Useful recruited Pokémon:
		- [ ] Jobs / Professions:
			For teams / single Pokémon jobs at outpost:
				- [ ] ???
				- [ ] Random examples: foraging, smithing, cooking, scouting, merchant, guard, research
			On the same tick system (1 main-floor = 1 tick)
			produce resources, services, or bonuses over time.
				Steady passive resources (food, salvage, crafting parts), temporary buffs (item find rate), and unlockable services (link moves, skill tutoring).
			`jobProgress`?
				`ticksToComplete`.
				jobProgress += jobSpeed;
			`jobLevel`?
			Limit jobs outpost slots;
			scale output with jobLevel
			Prevent fast-farm by adding a daily cap or cooldown?
		- [ ] Expedition Teams (long missions that generate rare loot)
			- [ ] For example: Go find X item or go recruit Y pokemon or even SHINY(!) pokemon! (they search all dungeons, here, there, etc. Maybe even log their history / path / travels?? :D )
			long, multi-floor runs
		- [ ] Training Grounds / Mentorship
			Teach a moooove!! :D (after say, 50 days!! if it's a good move even more!)
			A higher-level Pokémon can train a lower-level one to learn moves, inherit passive skills, or boost growth rates.
			? Add a “sparring” mini-sim for XP and stat boosts.
			recruits -> useful specialists
			supports intentional squad-building
			Allows move transfer
			Training consumes food/time!!
			Cap on how many moves can be inherited;
		- [ ] Outpost Crafting & Workshops
			Have pokemon help in building the upgrades?? O,o ... hmmmmmm.... doesn't sound nice *^_^
		- [ ] Rotating Support / “On-call” Teams
			? I think indeed this better be implemented as "Relationship" stuff... where specific pokemons jump in ... rather than making teams "stand-by" and call... A WHOLE SQUAD?? XD wtf??
			Allow the player to temporarily “call in” a registered team as AI-controlled allies for a limited number of floors of the current dungeon.
			Calling costs outpost resources and has cooldown.
		-??? X---------------------------- Reputation & Contracts Market
		- [ ] Research & Move Development
			can prototype new moves, (buff types, or passive skills)?
			"tech trees"?
		-? Morale & Social Activities
			? Social activities (festivals, training parties)?
		- [ ] Photo Studio / Memory Bonds (cosmetic + unlocks)
			Record bonds between Pokémon
			High-bond pairs unlock combo moves, dual-skill passive
			Bond increases from shared mission success or social activity ticks
			Bonding is slow to prevent mass-farming.
		- [ ] Super Wow #1 — Collaborative Multi-Team Expeditions (Cooperative Campaigns)
			Outpost can launch coordinated, multi-team campaigns into massive multi-boss dungeons (procedural “campaign maps”).
			Each registered team handles a sector; success requires diverse roles and inter-team planning.
			Campaigns are long (many ticks), and teams influence each other (supply lines, supporting buffs, staggered floor progress).
			Why it wows: This creates strategic meta-play—planning team composition, supply routes, and timing—without asking the player to manually run every floor.
				The emergent result: dramatic campaign reports, rare global rewards, and a feeling of an active world.
			Implementation sketch:
				* Campaign = map of sectors; each sector has `difficulty`, `resourceNodes`, `boss`.
				* Each tick, campaign resolves per-sector ticks. Supply lines consume food and items transferred between sectors (simulate transfers each tick).
				* Successful sector clears unlock adjacent sectors; failing a sector risks campaign collapse or retreat.
					Player benefit: Rare artifacts, large-scale recruit opportunities, outpost upgrades.
					Balance / anti-exploit: Long cooldowns, resource sinks, and an escalating supply requirement that prevents repeated farming.
		- [ ] “Field Integration” — temporary cross-over of outpost pokemon/teams into the player’s active party in critical story moments (unique scripted interactions and synergy attacks).
		- [ ] “Economy & Politics” — other outposts and NPC factions respond to your outpost’s reputation; teams can be contracted by factions, triggering diplomacy and late-game markets.
	- [ ] UX
		- [ ] [Complete Summary Screen]
			- The percent loaded, shown with: Silly animations!! XD Like how Mon.Hun. has the cat animation in the loading bar ... (When downloading "cache"/"Performance" data on PSP)
		- [ ] (Component) visual progress bar: floorsCleared / targetFloor
		- [ ] [Bubble Popup Message]: A tiny info popup, containing only the TOP important info. Example: {Team (X / X, Y, Z) fainted! Help!}
		- [ ] [RTO Teams History Info UI]
			- [ ] Show info on each dungeon taken, as if you are watching it the time it happened!
		- [ ] [RTO Teams Statistics Info UI]
			- [ ] {consolidated weekly/daily summary when the player returns to town.}
	- [ ] Provide a compact mission log readable from the outpost: summary lines like
		- [ ] "Floor 5: defeated 3 enemies, found 12 coins and 1 Potion. Team lost 4 HP each. Recruited: Pidgey (lvl 3)."
