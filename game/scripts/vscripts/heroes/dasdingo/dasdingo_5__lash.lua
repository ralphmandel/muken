dasdingo_5__lash = class({})
LinkLuaModifier("dasdingo_5_modifier_lash", "heroes/dasdingo/dasdingo_5_modifier_lash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ethereal", "modifiers/_modifier_ethereal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ethereal_status_efx", "modifiers/_modifier_ethereal_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bkb", "modifiers/_modifier_bkb", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_5__lash:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function dasdingo_5__lash:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_5__lash:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_5__lash:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function dasdingo_5__lash:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 5.11
        if self:GetRank(11) then
            charges = charges * 2           
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_5__lash:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_5__lash:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then
            caster:Interrupt()
        else
            target:AddNewModifier(caster, self, "dasdingo_5_modifier_lash", {duration = self:GetChannelTime()})
            if IsServer() then target:EmitSound("Hero_ShadowShaman.Shackles.Cast") end
        end
    end

    function dasdingo_5__lash:OnChannelFinish(bInterrupted)
        local target = self:GetCursorTarget()
        if target then target:RemoveModifierByName("dasdingo_5_modifier_lash") end
    end

    function dasdingo_5__lash:GetChannelTime()
        return self:CalcStatus(self:GetSpecialValueFor("channel_time"), self:GetCaster(), self:GetCursorTarget())
    end

    function dasdingo_5__lash:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return cast_range + 200 end
        return cast_range
    end

    function dasdingo_5__lash:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS