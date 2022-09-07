dasdingo_1__heal = class({})
LinkLuaModifier("dasdingo_1_modifier_passive", "heroes/dasdingo/dasdingo_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_heal", "heroes/dasdingo/dasdingo_1_modifier_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_heal_effect", "heroes/dasdingo/dasdingo_1_modifier_heal_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_immortal", "heroes/dasdingo/dasdingo_1_modifier_immortal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_immortal_status_efx", "heroes/dasdingo/dasdingo_1_modifier_immortal_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_1__heal:CalcStatus(duration, caster, target)
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

    function dasdingo_1__heal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_1__heal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_1__heal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function dasdingo_1__heal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 1.42
        if self:GetRank(42) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_1__heal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_1__heal:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function dasdingo_1__heal:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 1.21
        if self:GetRank(21) then
            duration = duration + 8
        end

        CreateModifierThinker(caster, self, "dasdingo_1_modifier_heal", {duration = duration}, point, caster:GetTeamNumber(), false)
    end

    function dasdingo_1__heal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS