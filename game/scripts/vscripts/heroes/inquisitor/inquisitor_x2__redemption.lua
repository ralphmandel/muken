inquisitor_x2__redemption = class({})
LinkLuaModifier( "inquisitor_x2_modifier_redemption", "heroes/inquisitor/inquisitor_x2_modifier_redemption", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function inquisitor_x2__redemption:CalcStatus(duration, caster, target)
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

    function inquisitor_x2__redemption:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function inquisitor_x2__redemption:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function inquisitor_x2__redemption:OnUpgrade()
        self:SetHidden(false)
    end

    function inquisitor_x2__redemption:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function inquisitor_x2__redemption:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")

        target:RemoveModifierByName("inquisitor_x2_modifier_redemption")
        target:AddNewModifier(caster, self, "inquisitor_x2_modifier_redemption", {duration = duration})
    end

-- EFFECTS