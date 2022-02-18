shadow_3__second_shadow = class({})
LinkLuaModifier("shadow_3_modifier_illusion", "heroes/shadow/shadow_3_modifier_illusion", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function shadow_3__second_shadow:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function shadow_3__second_shadow:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_3__second_shadow:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_3__second_shadow:OnUpgrade()
        self:SetHidden(false)
    end

    function shadow_3__second_shadow:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_3__second_shadow:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        target:AddNewModifier(caster, self, "shadow_3_modifier_illusion", {ignore_order = 0, aspd = 70})
        self:SetActivated(false)
    end

    function shadow_3__second_shadow:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
    
        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end
    
        if hTarget:HasModifier("shadow_3_modifier_illusion") == false
        or hTarget:GetTeam() ~= caster:GetTeam() then
            return UF_FAIL_CUSTOM
        end
    
        return UF_SUCCESS
    end
    
    function shadow_3__second_shadow:GetCustomCastErrorTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
        if caster:HasModifier("shadow_3_modifier_illusion") == false then
            return "INVALID TARGET"
        end
    end

-- EFFECT