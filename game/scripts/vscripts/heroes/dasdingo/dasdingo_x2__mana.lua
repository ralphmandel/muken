dasdingo_x2__mana = class({})
LinkLuaModifier("dasdingo_x2_modifier_lash", "heroes/dasdingo/dasdingo_x2_modifier_lash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_x2__mana:CalcStatus(duration, caster, target)
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

    function dasdingo_x2__mana:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_x2__mana:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_x2__mana:OnUpgrade()
        self:SetHidden(false)
    end

    function dasdingo_x2__mana:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_x2__mana:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then
            caster:Interrupt()
        else
            target:AddNewModifier(caster, self, "dasdingo_x2_modifier_lash", {duration = self:GetChannelTime()})
            if IsServer() then target:EmitSound("Hero_ShadowShaman.Shackles.Cast") end
        end
    end

    function dasdingo_x2__mana:OnChannelFinish(bInterrupted)
        local target = self:GetCursorTarget()
        if target then target:RemoveModifierByName("dasdingo_x2_modifier_lash") end
    end

    function dasdingo_x2__mana:GetChannelTime()
        return self:CalcStatus(self:GetSpecialValueFor("channel_time"), self:GetCaster(), self:GetCursorTarget())
    end

-- EFFECTS