bloodmage_0__sacrifice = class({})
LinkLuaModifier("bloodmage_0_modifier_sacrifice", "heroes/bloodmage/bloodmage_0_modifier_sacrifice", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodmage_0_modifier_sacrifice_stack", "heroes/bloodmage/bloodmage_0_modifier_sacrifice_stack", LUA_MODIFIER_MOTION_NONE)


-- INIT

    function bloodmage_0__sacrifice:CalcStatus(duration, caster, target)
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

    function bloodmage_0__sacrifice:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodmage_0__sacrifice:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodmage_0__sacrifice:Spawn()
        self:UpgradeAbility(true)
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodmage_0__sacrifice:GetIntrinsicModifierName()
        return "bloodmage_0_modifier_sacrifice"
    end

    function bloodmage_0__sacrifice:OnSpellStart()
        local caster = self:GetCaster()

        local mod_sacrifice = caster:FindModifierByName("bloodmage_0_modifier_sacrifice")
        if mod_sacrifice then
            mod_sacrifice:IncrementBP()
            mod_sacrifice:AddStack()
        end
    end

    function bloodmage_0__sacrifice:OnOwnerSpawned()
        local caster = self:GetCaster()
        caster:SetMana(0)
    end

    function bloodmage_0__sacrifice:OnOwnerDied()
        local caster = self:GetCaster()

        local mod_sacrifice = caster:FindModifierByName("bloodmage_0_modifier_sacrifice")
        if mod_sacrifice then
            mod_sacrifice:DecrementBP(caster:GetMana())
        end
    end

-- EFFECTS