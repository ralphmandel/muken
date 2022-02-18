dasdingo_2__aura = class({})
LinkLuaModifier("dasdingo_2_modifier_aura", "heroes/dasdingo/dasdingo_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_2_modifier_aura_effect", "heroes/dasdingo/dasdingo_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_2__aura:CalcStatus(duration, caster, target)
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

    function dasdingo_2__aura:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_2__aura:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_2__aura:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("dasdingo__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        return att.talents[2][upgrade]
    end

    function dasdingo_2__aura:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local att = caster:FindAbilityByName("dasdingo__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local charges = 1

        -- UP 2.1
        if self:GetRank(1) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_2__aura:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_2__aura:GetIntrinsicModifierName()
        return "dasdingo_2_modifier_aura"
    end

    function dasdingo_2__aura:OnSpellStart()
        local caster = self:GetCaster()
    end

    function dasdingo_2__aura:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") * 1.4 end
    end

-- EFFECTS