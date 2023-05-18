ancient_4__lotus = class({})
LinkLuaModifier("ancient_4_modifier_passive", "heroes/ancient/ancient_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_4_modifier_radiance_aura", "heroes/ancient/ancient_4_modifier_radiance_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_4_modifier_radiance_aura_effect", "heroes/ancient/ancient_4_modifier_radiance_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_4__lotus:CalcStatus(duration, caster, target)
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

    function ancient_4__lotus:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_4__lotus:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_4__lotus:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function ancient_4__lotus:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function ancient_4__lotus:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function ancient_4__lotus:GetIntrinsicModifierName()
        return "ancient_4_modifier_passive"
    end

    function ancient_4__lotus:ApplyRadiance()
        local caster = self:GetCaster()
        local mana = caster:GetMana()
        local modifier_name = "ancient_4_modifier_radiance_aura"

        if caster:IsIllusion() then return end

        if mana > 0 and caster:IsAlive() then
            caster:AddNewModifier(caster, self, modifier_name, {})
        else
            caster:RemoveModifierByNameAndCaster(modifier_name, caster)
        end
    end

    function ancient_4__lotus:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 and self:GetCaster():GetMana() > 0 then return 250 end
        return 0
    end

    function ancient_4__lotus:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function ancient_4__lotus:CheckAbilityCharges(charges)
        -- UP 4.22
        if self:GetRank(22) then
            charges = charges * 2
        end

        -- UP 4.31
        if self:GetRank(31) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS