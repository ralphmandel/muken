dasdingo_x1__ward = class({})
LinkLuaModifier("dasdingo_x1_modifier_tribal", "heroes/dasdingo/dasdingo_x1_modifier_tribal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_x1_modifier_bounce", "heroes/dasdingo/dasdingo_x1_modifier_bounce", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_x1__ward:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
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
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function dasdingo_x1__ward:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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