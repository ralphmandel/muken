bloodmage_0__sacrifice = class({})
LinkLuaModifier("bloodmage_0_modifier_sacrifice", "heroes/bloodmage/bloodmage_0_modifier_sacrifice", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodmage_0_modifier_sacrifice_stack", "heroes/bloodmage/bloodmage_0_modifier_sacrifice_stack", LUA_MODIFIER_MOTION_NONE)


-- INIT

    function bloodmage_0__sacrifice:CalcStatus(duration, caster, target)
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

    function bloodmage_0__sacrifice:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function bloodmage_0__sacrifice:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodmage_0__sacrifice:Spawn()
        self:UpgradeAbility(true)
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodmage_0__sacrifice:GetIntrinsicModifierName()
        return "bloodmage_0_modifier_sacrifice"
    end

    function bloodmage_0__sacrifice:OnSpellStart()
        local caster = self:GetCaster()

        local mod_sacrifice = caster:FindModifierByName("bloodmage_0_modifier_sacrifice")
        if mod_sacrifice then
            mod_sacrifice:IncrementBP()
            mod_sacrifice:AddStack()
        end
    end

    function bloodmage_0__sacrifice:OnOwnerSpawned()
        local caster = self:GetCaster()
        caster:SetMana(0)
    end

    function bloodmage_0__sacrifice:OnOwnerDied()
        local caster = self:GetCaster()

        local mod_sacrifice = caster:FindModifierByName("bloodmage_0_modifier_sacrifice")
        if mod_sacrifice then
            mod_sacrifice:DecrementBP(caster:GetMana())
        end
    end

-- EFFECTS