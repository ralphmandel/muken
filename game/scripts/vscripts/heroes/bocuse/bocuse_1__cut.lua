bocuse_1__cut = class({})
LinkLuaModifier("bocuse_1_modifier_slash", "heroes/bocuse/bocuse_1_modifier_slash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_1__cut:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function bocuse_1__cut:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_1__cut:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_1__cut:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function bocuse_1__cut:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bocuse_1__cut:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bocuse_1__cut:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        caster:FadeGesture(ACT_DOTA_ATTACK)
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.5)

        return true
    end

    function bocuse_1__cut:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FadeGesture(ACT_DOTA_ATTACK)
    end

    function bocuse_1__cut:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget() 
        caster:FadeGesture(ACT_DOTA_ATTACK)

        local max_bonus_chance = self:GetSpecialValueFor("max_bonus_chance")
        local bonus_chance = max_bonus_chance

        if self.last_time_cast == nil then
            self.last_time_cast = GameRules:GetGameTime()
        else
            bonus_chance = GameRules:GetGameTime() - self.last_time_cast - self:GetEffectiveCooldown(self:GetLevel())
            self.last_time_cast = GameRules:GetGameTime()
            if bonus_chance > max_bonus_chance then bonus_chance = max_bonus_chance end
        end

        local mod = caster:AddNewModifier(caster, self, "bocuse_1_modifier_slash", {bonus_chance = bonus_chance})
        mod.target = target
    end

    function bocuse_1__cut:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        if caster:IsDisarmed() then return UF_FAIL_CUSTOM end

        local result = UnitFilter(
            hTarget, self:GetAbilityTargetTeam(),
            self:GetAbilityTargetType(),
            self:GetAbilityTargetFlags(),
            caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function bocuse_1__cut:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster():IsDisarmed() then
            return "Can't Cast While Disarmed"
        end
    end

    function bocuse_1__cut:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_1__cut:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS