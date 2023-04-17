function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  --if spew == 1 then
    print(...)
  --end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  --if spew == 1 then
    PrintTable(...)
  --end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end




function GetTeamIndex(team_number)
  for i = #TEAMS, 1, -1 do
    if team_number == TEAMS[i][1] then
      return i
    end
  end
end

function GetKillingSpreeAnnouncer(kills)
  local rand = RandomInt(1,2)

  if kills == 4 then
    if rand == 1 then return "announcer_killing_spree_announcer_kill_dominate_01" end
    if rand == 2 then return "announcer_killing_spree_announcer_kill_mega_01" end
  end
  if kills == 5 then
    if rand == 1 then return "announcer_killing_spree_announcer_kill_unstop_01" end
    if rand == 2 then return "announcer_killing_spree_announcer_kill_wicked_01" end
  end
  if kills == 6 then
    if rand == 1 then return "announcer_killing_spree_announcer_kill_godlike_01" end
    if rand == 2 then return "announcer_killing_spree_announcer_ownage_01" end
  end
  if kills >= 7 then
    if rand == 1 then return "announcer_killing_spree_announcer_kill_holy_01" end
    if rand == 2 then return "announcer_killing_spree_announcer_kill_monster_01" end
  end

  return "announcer_killing_spree_announcer_kill_spree_01"
end

function RollDrops(unit, killerEntity)
  local table = LoadKeyValues("scripts/kv/item_drops.kv")
  local DropInfo = table[unit:GetUnitName()]
  if DropInfo then
    local chance = 0
    local item_list = {}
    for table_name, table_chance in pairs(DropInfo) do
      if table_name == "chance" then
        chance = table_chance
      else
        for i = 1, table_chance, 1 do
          if #item_list then
            item_list[#item_list + 1] = table_name
          else
            item_list[1] = table_name
          end
        end
      end
    end

    if RandomInt(1, 100) <= chance then
      local item_name = item_list[RandomInt(1, #item_list)]
      local item = CreateItem(item_name, nil, nil)
      local pos = unit:GetAbsOrigin()
      local drop = CreateItemOnPositionSync(pos, item)
      local pos_launch = pos + RandomVector(RandomFloat(150,200))
      item:LaunchLoot(false, 200, 0.75, pos_launch)

      local string = "particles/neutral_fx/neutral_item_drop_lvl4.vpcf"
      if unit:GetUnitName() == "boss_gorillaz" then string = "particles/neutral_fx/neutral_item_drop_lvl5.vpcf" end
      local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
      ParticleManager:SetParticleControl(particle, 0, pos_launch)
      ParticleManager:ReleaseParticleIndex(particle)
    
      if IsServer() then
        if killerEntity then
          EmitSoundOnLocationForAllies(pos_launch, "NeutralLootDrop.Spawn", killerEntity)
        end
      end

      Timers:CreateTimer((15), function()
        if drop then
          if IsValidEntity(drop) then
            UTIL_Remove(drop)
          end
        end
      end)
    end
  end
end

function RandomForNoHeroSelected()
  for _, team in pairs(TEAMS) do
    for i = 1, CUSTOM_TEAM_PLAYER_COUNT[team[1]] do
      local playerID = PlayerResource:GetNthPlayerIDOnTeam(team[1], i)
      if playerID ~= nil then
        if not PlayerResource:HasSelectedHero(playerID) then
          local hPlayer = PlayerResource:GetPlayer(playerID)
          if hPlayer ~= nil then
            hPlayer:MakeRandomHeroSelection()
          end
        end
      end
    end
  end
end

function CalcStatus(duration, caster, target)
  if caster == nil or target == nil then return duration end
  if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end

  if caster:GetTeamNumber() == target:GetTeamNumber() then
    if BaseStats(caster) then duration = duration * (1 + BaseStats(caster):GetBuffAmp()) end
  else
    if BaseStats(caster) then duration = duration * (1 + BaseStats(caster):GetDebuffAmp()) end
    if BaseStats(target) then duration = duration * (1 - (BaseStats(target):GetStatusResistPercent() * 0.01)) end
  end
  
  return duration
end

function AddBonus(ability, string, target, const, percent, time)
  if const == 0 and percent == 0 then return end
  if BaseStats(target) then BaseStats(target):AddBonusStat(ability:GetCaster(), ability, const, percent, time, string) end
end

function RemoveBonus(ability, string, target)
  local stringFormat = string.format("%s_modifier_stack", string)
  local mod = target:FindAllModifiersByName(stringFormat)
  for _,modifier in pairs(mod) do
      if modifier:GetAbility() == ability then modifier:Destroy() end
  end
end

function RemoveAllModifiersByNameAndAbility(target, name, ability)
  local mod = target:FindAllModifiersByName(name)
  for _,modifier in pairs(mod) do
      if modifier:GetAbility() == ability then modifier:Destroy() end
  end
end

function IsMetamorphosis(ability_name, target)
  local ability = target:FindAbilityByName(ability_name)
  if ability then
    if ability:IsTrained() then
      return ability:GetCurrentAbilityCharges()
    end
  end
  return 0
end

function BaseStats(baseNPC)
  return baseNPC:FindAbilityByName("base_stats")
end

function BaseHero(baseNPC)
  return baseNPC:FindAbilityByName("base_hero")
end

function BaseHeroMod(baseNPC)
  return baseNPC:FindModifierByName("base_hero_mod")
end