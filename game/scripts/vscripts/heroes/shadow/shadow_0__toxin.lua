shadow_0__toxin = class({})
LinkLuaModifier("shadow_0_modifier_toxin", "heroes/shadow/shadow_0_modifier_toxin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_0_modifier_toxin_stack", "heroes/shadow/shadow_0_modifier_toxin_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_0_modifier_toxin_status_efx", "heroes/shadow/shadow_0_modifier_toxin_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_0__toxin:CalcStatus(duration, caster, target)
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

    function shadow_0__toxin:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_0__toxin:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_0__toxin:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("shadow__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        return att.talents[0][upgrade]
    end

    function shadow_0__toxin:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local att = caster:FindAbilityByName("shadow__attributes")
        if att then
            if att:IsTrained() then
                att.talents[0][0] = true
            end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_0__toxin:Spawn()
        self:SetCurrentAbilityCharges(0)
        self:UpgradeAbility(true)
    end

-- SPELL START

    function shadow_0__toxin:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS