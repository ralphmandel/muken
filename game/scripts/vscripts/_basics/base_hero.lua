base_hero = class ({})
LinkLuaModifier("base_hero_mod", "_basics/base_hero_mod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_general_script", "_bot_scripts/_general_script", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_fountain_refresh_hp", "_modifiers/_fountain_refresh_hp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_fountain_refresh_mp", "_modifiers/_fountain_refresh_mp", LUA_MODIFIER_MOTION_NONE)
require("internal/talent_tree")

-- INIT

	function base_hero:Spawn()
		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

  function base_hero:GetIntrinsicModifierName()
		return "base_hero_mod"
	end

  function base_hero:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end

		if self:GetLevel() == 1 then
      self.hero_name = GetHeroName(self:GetCaster():GetUnitName())
      self.hero_team = GetHeroTeam(self:GetCaster():GetUnitName())
      self.ability_points = GetHeroInitPts(self.hero_name)

			self:ResetRanksData()

      for team = DOTA_TEAM_CUSTOM_MIN, DOTA_TEAM_CUSTOM_MIN + 3 do
        if caster:GetTeamNumber() == team then
          Timers:CreateTimer(team, function()
            caster:RemoveAbilityByHandle(caster:FindAbilityByName("ability_capture"))
            caster:RemoveAbilityByHandle(caster:FindAbilityByName("abyssal_underlord_portal_warp"))
            caster:AddExperience(INITIAL_XP, 0, false, false)
          end)
        end
      end
		end
	end

  function base_hero:ResetRanksData()
    local caster = self:GetCaster()

		self.abilities_name = GetAbilitiesList(self:GetCaster():GetUnitName())
    self.ranks_name = GetRanksList(self.abilities_name)
    self.ranks_upgraded = {}
    self.rank_points = 0

    self:UpdatePanoramaRanks()
	end

-- UPDATE DATA

  function base_hero:UpdatePanoramaRanks()
		local player = self:GetCaster():GetPlayerOwner()
		if (not player) then return end

    local list = {}

    for skill = 1, #self.abilities_name, 1 do
      list[skill] = {}
      for tier = 1, 3, 1 do
        list[skill][tier] = {}
        for path = 1, 2, 1 do
          list[skill][tier][path] = self:GetRankState(skill, tier, path)
        end
      end
    end

		CustomGameEventManager:Send_ServerToPlayer(player, "ranks_state_from_lua", list)
	end

  function base_hero:GetRankState(skill, tier, path)
    local rank_name = self.ranks_name[skill][tier][path]
    if self:IsRankTrained(rank_name) then return "rank_state_upgraded" end
    if self:IsRankAvailable(skill, tier, path) then return "rank_state_available" end
    return "rank_state_disabled"
  end

  function base_hero:IsRankTrained(rank_name)
    for _, rank in pairs(self.ranks_upgraded) do
      if rank:GetAbilityName() == rank_name then
        return true
      end
    end

    return false
  end

  function base_hero:IsRankAvailable(skill, tier, path)
    if self.rank_points < tier then return false end
    
    for i_path, rank_name in pairs(self.ranks_name[skill][tier]) do
      if path ~= i_path and self:IsRankTrained(rank_name) then
        return false
      end
    end

    return true
  end

  function base_hero:UpgradeRank(rank_name, tier)
    local caster = self:GetCaster()
    local ability = caster:AddAbility(rank_name)

    ability:UpgradeAbility(true)
    table.insert(self.ranks_upgraded, ability)

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, tier, caster)
    self:UpdatePanoramaRanks()
  end

-- HERO LEVEL UP

	function base_hero:OnHeroLevelUp()
		local caster = self:GetCaster()
		local level = caster:GetLevel()
		if caster:IsIllusion() then return end

		if level == 8 then
			local ultimate = caster:FindAbilityByName(self.abilities_name[6])
			if ultimate then
				if ultimate:IsTrained() == false then
					ultimate:UpgradeAbility(true)
          BaseStats(caster):AddManaExtra(ultimate)
				end
			end
		end

    if level == 15 then
      self:UpdateAbilityPoints(1)
    end

    if (level + 1) % 2 == 0 then
      self:UpdateRankPoints(1)
    end

    local bot_script = caster:FindModifierByName("_general_script")
    if bot_script then bot_script:ConsumeAllPoints() end
	end

	function base_hero:OnAbilityUpgrade(ability)
		if ability:GetCaster() == self:GetCaster() then
      self:UpdateAbilityPoints(-1)
    end
	end

	function base_hero:UpdateAbilityPoints(points)
		local caster = self:GetCaster()

		self.ability_points = self.ability_points + points
		caster:SetAbilityPoints(self.ability_points)

		for i = 1, 5, 1 do
			local skill = caster:FindAbilityByName(self.abilities_name[i])
			if skill then
				if skill:IsTrained() == false then
					skill:SetHidden(self.ability_points < 1)
				end
			end
		end
	end

  function base_hero:UpdateRankPoints(points)
		self.rank_points = self.rank_points + points

		self:UpdatePanoramaState()
	end