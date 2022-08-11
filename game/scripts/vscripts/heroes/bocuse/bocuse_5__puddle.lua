bocuse_5__puddle = class({})
LinkLuaModifier("bocuse_5_modifier_puddle", "heroes/bocuse/bocuse_5_modifier_puddle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_aura_effect", "heroes/bocuse/bocuse_5_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_5__puddle:CalcStatus(duration, caster, target)
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

    function bocuse_5__puddle:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_5__puddle:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_5__puddle:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function bocuse_5__puddle:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(self.base_charges)
    end

    function bocuse_5__puddle:Spawn()
        self.base_charges = 1
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bocuse_5__puddle:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")
        if IsServer() then caster:EmitSound("Hero_Bocuse.Roux") end

        -- UP 5.11
        if self:GetRank(11) then
            duration = duration + 5
        end

        Timers:CreateTimer((0.25), function()
            CreateModifierThinker(caster, self, "bocuse_5_modifier_puddle", {
                duration = duration
            }, point, caster:GetTeamNumber(), false)
        end)
    end

    function bocuse_5__puddle:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function bocuse_5__puddle:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 7 == 0 then cast_range = cast_range * 1.5 end
        return cast_range
    end

    function bocuse_5__puddle:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_5__puddle:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS