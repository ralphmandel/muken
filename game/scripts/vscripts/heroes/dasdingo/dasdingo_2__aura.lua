dasdingo_2__aura = class({})
LinkLuaModifier("dasdingo_2_modifier_aura", "heroes/dasdingo/dasdingo_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_2_modifier_aura_effect", "heroes/dasdingo/dasdingo_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_2__aura:CalcStatus(duration, caster, target)
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

    function dasdingo_2__aura:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_2__aura:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_2__aura:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function dasdingo_2__aura:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 2.31
        if self:GetRank(31) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_2__aura:Spawn()
        self:SetCurrentAbilityCharges(0)
        --self.total_regen = 0
    end

-- SPELL START

    function dasdingo_2__aura:GetIntrinsicModifierName()
        return "dasdingo_2_modifier_aura"
    end

    function dasdingo_2__aura:OnSpellStart()
        local caster = self:GetCaster()
    end

    function dasdingo_2__aura:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") * 2 end
    end

-- EFFECTS