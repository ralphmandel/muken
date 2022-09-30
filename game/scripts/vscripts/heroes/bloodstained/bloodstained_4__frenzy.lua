bloodstained_4__frenzy = class({})
LinkLuaModifier("bloodstained_4_modifier_passive", "heroes/bloodstained/bloodstained_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_4_modifier_frenzy", "heroes/bloodstained/bloodstained_4_modifier_frenzy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_bleeding", "heroes/bloodstained/bloodstained__modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_bleeding_status_efx", "heroes/bloodstained/bloodstained__modifier_bleeding_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_4__frenzy:CalcStatus(duration, caster, target)
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

    function bloodstained_4__frenzy:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_4__frenzy:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_4__frenzy:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function bloodstained_4__frenzy:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bloodstained_4__frenzy:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_4__frenzy:GetIntrinsicModifierName()
        return "bloodstained_4_modifier_passive"
    end

    function bloodstained_4__frenzy:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bloodstained_4__frenzy:CheckAbilityCharges(charges)
    	-- UP 4.32
        if self:GetRank(32) then
            charges = charges * 2 -- status resistance
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS