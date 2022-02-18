bocuse_x1__roux = class ({})
LinkLuaModifier("bocuse_x1_modifier_roux", "heroes/bocuse/bocuse_x1_modifier_roux", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x1_modifier_debuff", "heroes/bocuse/bocuse_x1_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_x1__roux:CalcStatus(duration, caster, target)
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

    function bocuse_x1__roux:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function bocuse_x1__roux:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_x1__roux:OnUpgrade()
        self:SetHidden(false)
    end

    function bocuse_x1__roux:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bocuse_x1__roux:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function bocuse_x1__roux:OnSpellStart()
        --1516 1520 1534 1547 1595 1596 1602
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")
        if IsServer() then caster:EmitSound("Hero_Bocuse.Roux") end

        Timers:CreateTimer((0.25), function()
            
            CreateModifierThinker(caster, self, "bocuse_x1_modifier_roux", {
                duration = duration
            }, point, caster:GetTeamNumber(), false)
        end)
    end

-- EFFECTS