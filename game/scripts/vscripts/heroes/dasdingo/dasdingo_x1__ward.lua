dasdingo_x1__ward = class({})
LinkLuaModifier("dasdingo_x1_modifier_tribal", "heroes/dasdingo/dasdingo_x1_modifier_tribal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_x1_modifier_bounce", "heroes/dasdingo/dasdingo_x1_modifier_bounce", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_x1__ward:CalcStatus(duration, caster, target)
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

    function dasdingo_x1__ward:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_x1__ward:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_x1__ward:OnUpgrade()
        self:SetHidden(false)
    end

    function dasdingo_x1__ward:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_x1__ward:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")
    
        local summoned_unit = CreateUnitByName(
            "tribal_ward", -- name
            point, -- point
            true, -- bFindClearSpace,
            caster, -- hNPCOwner,
            caster, -- hUnitOwner,
            caster:GetTeamNumber() -- iTeamNumber
        )
        -- dominate units
        --summoned_unit:SetControllableByPlayer(self.caster:GetPlayerID(), false) -- (playerID, bSkipAdjustingPosition)
        summoned_unit:SetOwner(caster)
        summoned_unit:AddNewModifier(caster, self, "dasdingo_x1_modifier_tribal", {
            duration = self:CalcStatus(duration, caster, nil)
        })

        if IsServer() then summoned_unit:EmitSound("Hero_WitchDoctor.Paralyzing_Cask_Cast") end
    end

-- EFFECTS