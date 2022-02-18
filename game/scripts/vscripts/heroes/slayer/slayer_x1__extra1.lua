slayer_x1__extra1 = class({})
LinkLuaModifier( "slayer_x1_modifier_extra1", "heroes/slayer/slayer_x1_modifier_extra1", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function slayer_x1__extra1:CalcStatus(duration, caster, target)
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

    function slayer_x1__extra1:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function slayer_x1__extra1:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function slayer_x1__extra1:OnUpgrade()
        self:SetHidden(false)
    end

    function slayer_x1__extra1:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function slayer_x1__extra1:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS