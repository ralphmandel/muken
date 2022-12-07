bald_1__power = class({})
LinkLuaModifier("bald_1_modifier_passive", "heroes/bald/bald_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_1_modifier_passive_stack", "heroes/bald/bald_1_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_1__power:CalcStatus(duration, caster, target)
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

    function bald_1__power:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_1__power:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_1__power:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        Timers:CreateTimer(0.2, function()
            local base_hero = caster:FindAbilityByName("base_hero")
            if base_hero then
                base_hero.ranks[1][0] = true
                if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
            end
        end)
    end

    function bald_1__power:Spawn()
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function bald_1__power:GetIntrinsicModifierName()
        return "bald_1_modifier_passive"
    end

-- EFFECTS