genuine_x1__nightfall = class({})
LinkLuaModifier("genuine_x1_modifier_aura", "heroes/genuine/genuine_x1_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_x1_modifier_aura_effect", "heroes/genuine/genuine_x1_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_x1__nightfall:CalcStatus(duration, caster, target)
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

    function genuine_x1__nightfall:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function genuine_x1__nightfall:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_x1__nightfall:OnUpgrade()
        self:SetHidden(false)
    end

    function genuine_x1__nightfall:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_x1__nightfall:GetIntrinsicModifierName()
        return "genuine_x1_modifier_aura"
    end

    function genuine_x1__nightfall:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "_modifier_invisible", {delay = 1})
        self:SetActivated(false)
    end

    function genuine_x1__nightfall:GetCastRange(vLocation, hTarget)
        if GameRules:IsDaytime() then
            return self:GetSpecialValueFor("day_radius")
        else
            return self:GetSpecialValueFor("night_radius")
        end

        return 0
    end

-- EFFECTS