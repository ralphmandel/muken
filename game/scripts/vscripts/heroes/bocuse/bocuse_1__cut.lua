bocuse_1__cut = class({})
LinkLuaModifier("bocuse_1_modifier_slash", "heroes/bocuse/bocuse_1_modifier_slash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_1_modifier_bleeding", "heroes/bocuse/bocuse_1_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_1__cut:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
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

        if self:GetCurrentAbilityCharges() % 3 == 0 then
            caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
        else
            caster:StartGesture(ACT_DOTA_ATTACK)
        end

        if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end

        return true
    end

    function bocuse_1__cut:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FadeGesture(ACT_DOTA_ATTACK)
    end

    function bocuse_1__cut:OnSpellStart()
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget() 
        caster:FadeGesture(ACT_DOTA_ATTACK)

        if self.target:TriggerSpellAbsorb(self) then return end

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
    end

    function bocuse_1__cut:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        if caster:IsDisarmed()
        and self:GetCurrentAbilityCharges() % 3 ~= 0 then
            return UF_FAIL_CUSTOM
        end

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

    function bocuse_1__cut:GetAOERadius()
        local radius = 1
        if self:GetCurrentAbilityCharges() == 0 then return radius end
        if self:GetCurrentAbilityCharges() % 5 == 0 then radius = 200 end
        return radius
    end

    function bocuse_1__cut:GetCastPoint()
        local cast_point = 0.55
        if self:GetCurrentAbilityCharges() == 0 then return cast_point end
        if self:GetCurrentAbilityCharges() % 3 == 0 then cast_point = 0.1 end
        return cast_point
    end

    function bocuse_1__cut:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range = cast_range + 100 end
        return cast_range
    end

    function bocuse_1__cut:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_1__cut:CheckAbilityCharges(charges)
        -- UP 1.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 1.31
        if self:GetRank(31) then
            charges = charges * 3
        end

        -- UP 1.41
        if self:GetRank(41) then
            charges = charges * 5
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS