bald_u__vitality = class({})
LinkLuaModifier("bald_u_modifier_vitality", "heroes/bald/bald_u_modifier_vitality", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_u_modifier_vitality_status_efx", "heroes/bald/bald_u_modifier_vitality_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_u__vitality:CalcStatus(duration, caster, target)
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

    function bald_u__vitality:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_u__vitality:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_u__vitality:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function bald_u__vitality:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        self:CheckAbilityCharges(1)
    end

    function bald_u__vitality:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bald_u__vitality:OnAbilityPhaseStart()
        local caster = self:GetCaster()

        Timers:CreateTimer(0.5, function()
            if IsServer() then caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast") end
        end)

        return true
    end

    function bald_u__vitality:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "bald_u_modifier_vitality", {})

        if IsServer() then caster:EmitSound("Hero_OgreMagi.Bloodlust.Target") end
    end

    function bald_u__vitality:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bald_u__vitality:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
