striker_3__portal = class({})
LinkLuaModifier("striker_3_modifier_portal", "heroes/striker/striker_3_modifier_portal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_buff", "heroes/striker/striker_3_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_debuff", "heroes/striker/striker_3_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_3__portal:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function striker_3__portal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_3__portal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_3__portal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function striker_3__portal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function striker_3__portal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_3__portal:GetAOERadius()
        return self:GetSpecialValueFor("portal_radius")
    end

    function striker_3__portal:OnSpellStart()
        self:PerformAbility(self:GetCursorPosition())
    end

    function striker_3__portal:PerformAbility(loc)
        local caster = self:GetCaster()
        local portal_duration = self:GetSpecialValueFor("portal_duration")

        -- UP 3.41
        if self:GetRank(41) then
            portal_duration = portal_duration + 30
        end

        CreateModifierThinker(
            caster, self, "striker_3_modifier_portal",
            {duration = portal_duration},
            loc, caster:GetTeamNumber(), false
        )

        return true
    end

    function striker_3__portal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS