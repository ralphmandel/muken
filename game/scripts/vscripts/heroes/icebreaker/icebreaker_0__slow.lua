icebreaker_0__slow = class({})
LinkLuaModifier( "icebreaker_0_modifier_slow", "heroes/icebreaker/icebreaker_0_modifier_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_freeze", "heroes/icebreaker/icebreaker_0_modifier_freeze", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_illusion", "heroes/icebreaker/icebreaker_0_modifier_illusion", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_slow_status_effect", "heroes/icebreaker/icebreaker_0_modifier_slow_status_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_freeze_status_effect", "heroes/icebreaker/icebreaker_0_modifier_freeze_status_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant_status_effect", "heroes/icebreaker/icebreaker_1_modifier_instant_status_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_0__slow:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.stat_total["RES"] * 0.7
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

    function icebreaker_0__slow:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_0__slow:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_0__slow:Spawn()
        self:UpgradeAbility(true)
    end

-- SPELL START

    function icebreaker_0__slow:AddSlow(target, ability)
        if target == nil then return end
        if (not IsValidEntity(target)) then return end
        if target:HasModifier("icebreaker_0_modifier_freeze") then return end

        local caster = self:GetCaster()
        local slow_duration = self:GetSpecialValueFor("slow_duration")
        local stack = ability:GetSpecialValueFor("stack")

        local hypothermia = caster:FindAbilityByName("icebreaker_x2__sight")
        if hypothermia:IsTrained() then
            slow_duration = slow_duration * 2
        end

        -- UP 2.21
        if ability:GetAbilityName() == "icebreaker_2__discus" then
            if ability:GetRank(21) then
                local rand = RandomInt(1, 12)
                if rand > 3 then
                    if rand > 7 then
                        stack = 5
                    else
                        stack = 4
                    end
                end
            end
        end

        if ability:GetAbilityName() == "icebreaker_u__zero" then
            -- UP 4.21
            if ability:GetRank(21) then
                stack = stack + 1
            end

            local mod = target:FindModifierByName("icebreaker_0_modifier_slow")
            if mod then
                local mod_stack = mod:GetStackCount()
                if mod_stack < stack then
                    stack = stack - mod_stack
                else
                    mod:SetDuration(self:CalcStatus(slow_duration, caster, target), false)
                    return
                end
            end
        end

        target:AddNewModifier(caster, self, "icebreaker_0_modifier_slow", {
            duration = self:CalcStatus(slow_duration, caster, target),
            stack = stack
        })
    end

-- EFFECTS