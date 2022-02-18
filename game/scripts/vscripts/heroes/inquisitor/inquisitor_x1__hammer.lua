inquisitor_x1__hammer = class({})
LinkLuaModifier( "inquisitor_x1_modifier_hammer", "heroes/inquisitor/inquisitor_x1_modifier_hammer", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function inquisitor_x1__hammer:CalcStatus(duration, caster, target)
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

    function inquisitor_x1__hammer:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function inquisitor_x1__hammer:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function inquisitor_x1__hammer:OnUpgrade()
        self:SetHidden(false)
    end

    function inquisitor_x1__hammer:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function inquisitor_x1__hammer:GetAOERadius()
        return 400
    end

    function inquisitor_x1__hammer:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        target:AddNewModifier(caster, self, "inquisitor_x1_modifier_hammer", {})
    end

-- EFFECTS