icebreaker_0__slow = class({})
LinkLuaModifier( "icebreaker_0_modifier_slow", "heroes/icebreaker/icebreaker_0_modifier_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_freeze", "heroes/icebreaker/icebreaker_0_modifier_freeze", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_0_modifier_illusion", "heroes/icebreaker/icebreaker_0_modifier_illusion", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_0__slow:CalcStatus(duration, caster, target)
        local time = duration
        local caster_int = nil
        local caster_mnd = nil
        local target_res = nil

        if caster ~= nil then
            caster_int = caster:FindModifierByName("_1_INT_modifier")
            caster_mnd = caster:FindModifierByName("_2_MND_modifier")
        end

        if target ~= nil then
            target_res = target:FindModifierByName("_2_RES_modifier")
        end

        if caster == nil then
            if target ~= nil then
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        else
            if target == nil then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
                else
                    if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                    if target_res then time = time * (1 - target_res:GetStatus()) end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function icebreaker_0__slow:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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