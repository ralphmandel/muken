druid_3__totem = class({})
LinkLuaModifier("druid_3_modifier_totem", "heroes/druid/druid_3_modifier_totem", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_totem_effect", "heroes/druid/druid_3_modifier_totem_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_quill", "heroes/druid/druid_3_modifier_quill", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_3__totem:CalcStatus(duration, caster, target)
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

    function druid_3__totem:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_3__totem:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_3__totem:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function druid_3__totem:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_3__totem:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_3__totem:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 3.12
        if self:GetRank(12) then
            duration = duration + 10
        end
    
        local totem = CreateUnitByName("npc_druid_totem", point, true, caster, caster, caster:GetTeamNumber())        
        totem:AddNewModifier(caster, self, "druid_3_modifier_totem", {duration = duration})        
        totem:SetControllableByPlayer(caster:GetPlayerID(), true)
        totem:CreatureLevelUp(self:GetSpecialValueFor("rank") - 1)

        if IsServer() then caster:EmitSound("Hero_Juggernaut.HealingWard.Cast") end
    end

    function druid_3__totem:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_3__totem:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range = cast_range + 750 end
        return cast_range
    end

    function druid_3__totem:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_3__totem:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS