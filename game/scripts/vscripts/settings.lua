-- In this file you can set up all the properties and settings for your game mode.


ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 9000.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 60.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 100                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 5                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = -1           -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = true                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = (i-1) * 100
end

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = -1                     -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 3            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 500                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = false                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 30                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = false                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 


-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
ENABLED_RUNES[DOTA_RUNE_ARCANE] = true

MAX_NUMBER_OF_TEAMS = 4                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_NEUTRALS] = { 204, 204, 204 }  --   
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 172, 0, 32 }  --    
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 61, 210, 150 }   --    
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 140, 42, 244 }   --   
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 199, 228, 13 }  --   
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 61, 210, 150 }  --    Teal
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 243, 201, 9 }   --    Yellow
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 197, 77, 168 }  --    Pink
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 255, 108, 0 }   --    Orange
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 199, 228, 13 }   --   Olive
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 140, 42, 244 }  --    Purple
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 129, 83, 54 }   --    Brown
-- TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 27, 192, 216 }  --    Cyan
--TEAM_COLORS[DOTA_TEAM_CUSTOM_9] = { 199, 228, 13 }  --    Olive
--TEAM_COLORS[DOTA_TEAM_CUSTOM_10] = { 140, 42, 244 }  --    Purple


USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 3
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 3
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 3
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 3
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 4
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 4
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 4
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 4

INITIAL_XP = 1 
-- LVL 30(MAX): 55300

SCORE_LIMIT = 50
SCORE_KILL = 2
SCORE_DEATH = -1
XP_BOUNTY_MIN = 20
XP_BOUNTY_MAX = 30

BOTS_ENABLED = true
BOTS_ENABLED_TOOLS = false
BOTS_LOADED = false

BOTS = {}

BOT_LIST = {
  "fleaman", "lawbreaker", "bloodstained", "bocuse",
  "genuine", "icebreaker",
  "dasdingo", "hunter",
  "paladin", "templar", "baldur", "ancient"
}

RANDOM_NAMES = {
  [1] = "Jairo, o Jakiro",
  [2] = "Zubumafu",
  [3] = "Gasp.Z",
  [4] = "Martin Gore",
  [5] = "Serluc",
  [6] = "Shirayama",
  [7] = "InStereo4",
  [8] = "UK",
  [9] = "kubo",
  [10] = "Edomic Wolf",
  [11] = "Kazunari",
  [12] = "Do Jun"
}

TEMP_DEL = 0
BOT_STATE_REST = 0
BOT_STATE_AGGRESSIVE = 1
BOT_STATE_FLEE = 2
BOT_STATE_FARMING = 3
BOT_STATE_AGGRESSIVE_FIND_TARGET = 10

SPAWNER_MOBS = {
-- TIER 1
  {["tier"] = 1, ["units"] = {
    "neutral_basic_chameleon", "neutral_basic_chameleon",
    "neutral_basic_chameleon_b", "neutral_basic_chameleon_b"
  }},
  {["tier"] = 1, ["units"] = {
    "neutral_basic_crocodilian", "neutral_basic_crocodilian_b"
  }},
  {["tier"] = 1, ["units"] = {
    "neutral_basic_gargoyle", "neutral_basic_gargoyle_b", "neutral_basic_gargoyle_b"
  }},
  {["tier"] = 1, ["units"] = {
    "neutral_crocodile"
  }},
  {["tier"] = 1, ["units"] = {
    "neutral_frostbitten"
  }},
-- TIER 2
  {["tier"] = 2, ["units"] = {
    "neutral_igneo"
  }},
  {["tier"] = 2, ["units"] = {
    "neutral_crocodile", "neutral_crocodile"
  }},
  {["tier"] = 2, ["units"] = {
    "neutral_basic_crocodilian", "neutral_basic_crocodilian",
    "neutral_basic_crocodilian_b", "neutral_basic_crocodilian_b"
  }},
-- TIER 3
  {["tier"] = 3, ["units"] = {
    "neutral_crocodile", "neutral_crocodile", "neutral_crocodile"
  }},
  {["tier"] = 3, ["units"] = {
    "neutral_skydragon", "neutral_dragon"
  }},
  {["tier"] = 3, ["units"] = {
    "neutral_lamp"
  }},
-- TIER 4
  {["tier"] = 4, ["units"] = {
    "neutral_igneo", "neutral_igneo"
  }},
  {["tier"] = 4, ["units"] = {
    "neutral_igor", "neutral_frostbitten", "neutral_frostbitten"
  }},
-- TIER 5
  {["tier"] = 5, ["units"] = {
    "neutral_spider"
  }},
  {["tier"] = 5, ["units"] = {
    "neutral_frostbitten", "neutral_frostbitten", "neutral_frostbitten", "neutral_frostbitten", "neutral_frostbitten"
  }},
-- TIER BOSS
  {["tier"] = 8, ["units"] = {
    "boss_gorillaz"
  }}
}

SPAWNER_SPOTS_A = {
  [1] = { ["mob"] = {}, ["origin"] = Vector(-1264, -5247, 0), ["respawn"] = -90 },
  [2] = { ["mob"] = {}, ["origin"] = Vector(-631, -5971, 0), ["respawn"] = -90 },
  [3] = { ["mob"] = {}, ["origin"] = Vector(-1175, -7170, 0), ["respawn"] = -90 },
  [4] = { ["mob"] = {}, ["origin"] = Vector(299, -6840, 0), ["respawn"] = -90 },
  [5] = { ["mob"] = {}, ["origin"] = Vector(144, -5266, 0), ["respawn"] = -90 },
  [6] = { ["mob"] = {}, ["origin"] = Vector(1380, -5030, 0), ["respawn"] = -90 },
  [7] = { ["mob"] = {}, ["origin"] = Vector(1059, -6249, 0), ["respawn"] = -90 },
  [8] = { ["mob"] = {}, ["origin"] = Vector(1541, -7312, 0), ["respawn"] = -90 }
}

SPAWNER_SPOTS_B = {
  [1] = { ["mob"] = {}, ["origin"] = Vector(-1273, 5143, 0), ["respawn"] = -90 },
  [2] = { ["mob"] = {}, ["origin"] = Vector(-865, 6067, 0), ["respawn"] = -90 },
  [3] = { ["mob"] = {}, ["origin"] = Vector(-1228, 7106, 0), ["respawn"] = -90 },
  [4] = { ["mob"] = {}, ["origin"] = Vector(-60, 6605, 0), ["respawn"] = -90 },
  [5] = { ["mob"] = {}, ["origin"] = Vector(28, 5359, 0), ["respawn"] = -90 },
  [6] = { ["mob"] = {}, ["origin"] = Vector(1430, 5222, 0), ["respawn"] = -90 },
  [7] = { ["mob"] = {}, ["origin"] = Vector(1126, 5855, 0), ["respawn"] = -90 },
  [8] = { ["mob"] = {}, ["origin"] = Vector(1125, 6785, 0), ["respawn"] = -90 }
}

SPAWNER_SPOTS = {
  [1] = { ["mob"] = {}, ["origin"] = Vector(-3195, 379, 0), ["respawn"] = -90 },
  [2] = { ["mob"] = {}, ["origin"] = Vector(-2048, 2872, 0), ["respawn"] = -90 },
  [3] = { ["mob"] = {}, ["origin"] = Vector(-761, 1587, 0), ["respawn"] = -90 },
  [4] = { ["mob"] = {}, ["origin"] = Vector(-701, 3193, 0), ["respawn"] = -90 },
  [5] = { ["mob"] = {}, ["origin"] = Vector(507, 1276, 0), ["respawn"] = -90 },
  [6] = { ["mob"] = {}, ["origin"] = Vector(638, 3195, 0), ["respawn"] = -90 },
  [7] = { ["mob"] = {}, ["origin"] = Vector(2163, 2170, 0), ["respawn"] = -90 },
  [8] = { ["mob"] = {}, ["origin"] = Vector(3195, 1528, 0), ["respawn"] = -90 },
  [9] = { ["mob"] = {}, ["origin"] = Vector(1607, 386, 0), ["respawn"] = -90 },
  [10] = { ["mob"] = {}, ["origin"] = Vector(3203, -771, 0), ["respawn"] = -90 },
  [11] = { ["mob"] = {}, ["origin"] = Vector(1412, -1863, 0), ["respawn"] = -90 },
  [12] = { ["mob"] = {}, ["origin"] = Vector(1602, -3146, 0), ["respawn"] = -90 },
  [13] = { ["mob"] = {}, ["origin"] = Vector(329, -1352, 0), ["respawn"] = -90 },
  [14] = { ["mob"] = {}, ["origin"] = Vector(131, -2949, 0), ["respawn"] = -90 },
  [15] = { ["mob"] = {}, ["origin"] = Vector(-2621, -2115, 0), ["respawn"] = -90 },
  [16] = { ["mob"] = {}, ["origin"] = Vector(-1409, -835, 0), ["respawn"] = -90 }
}

SPAWNER_BOSS_SPOTS = {
  [1] = { ["mob"] = {}, ["origin"] = Vector(-6500, 0, 0), ["respawn"] = -300},
  [2] = { ["mob"] = {}, ["origin"] = Vector(6500, 0, 0), ["respawn"] = -300},
}

MAX_MOB_COUNT = 3
MAX_BOSS_COUNT = 1

BALDUR_CHARGING = 0
BALDUR_READY = 1
BALDUR_READY_NO_MANACOST = 2

GENUINE_TRAVEL_STATE_IN = 0
GENUINE_TRAVEL_STATE_OUT = 1
CYCLE_NIGHT = 0
CYCLE_DAY = 1

PLAYERS = {}
TEAMS = { -- [1] Team, [2] Score, [3] Team Name, [4] number of players, [5] team colour bar  
  [1] = {[1] = DOTA_TEAM_CUSTOM_1, [2] = 0, [3] = "Death Team",  [4] = 0, [5] = "<font color='#ac0020'>", ["fountain_origin"] = Vector(-2550, 3850, 0), ["team_origin"] = Vector(-3215, 3965, 0)},
  [2] = {[1] = DOTA_TEAM_CUSTOM_2, [2] = 0, [3] = "Nature Team",   [4] = 0, [5] = "<font color='#3dd296'>", ["fountain_origin"] = Vector(2550, -3850, 0), ["team_origin"] = Vector(3215, -3965, 0)},
  [3] = {[1] = DOTA_TEAM_CUSTOM_3, [2] = 0, [3] = "Moon Team", [4] = 0, [5] = "<font color='#8c2af4'>", ["fountain_origin"] = Vector(-3850, -2550, 0), ["team_origin"] = Vector(-3965, -3215, 0)},
  [4] = {[1] = DOTA_TEAM_CUSTOM_4, [2] = 0, [3] = "Sun Team", [4] = 0, [5] = "<font color='#c7e40d'>", ["fountain_origin"] = Vector(3850, 2550, 0), ["team_origin"] = Vector(3965, 3215, 0)},
}

TEAM_ORIGIN = {
  [DOTA_TEAM_CUSTOM_1] = Vector(-2730, -2730, 0),
  [DOTA_TEAM_CUSTOM_2] = Vector(2730, 2730, 0),
  [DOTA_TEAM_CUSTOM_3] = Vector(-2730, 2730, 0),
  [DOTA_TEAM_CUSTOM_4] = Vector(2730, -2730, 0),
}

OUTPOST_ORIGIN = {
  [1] = Vector(2145.98, -427.15, 48.1793),
  [2] = Vector(545.975, 2452.85, 48.1793),
  [3] = Vector(-2526.03, 596.85, 57.7422),
  [4] = Vector(-542.025, -2283.15, 16),
}