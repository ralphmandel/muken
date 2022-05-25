dasdingo_1__heal = class({})
LinkLuaModifier("dasdingo_1_modifier_passive", "heroes/dasdingo/dasdingo_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_heal", "heroes/dasdingo/dasdingo_1_modifier_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_heal_effect", "heroes/dasdingo/dasdingo_1_modifier_heal_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_immortal", "heroes/dasdingo/dasdingo_1_modifier_immortal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_immortal_status_efx", "heroes/dasdingo/dasdingo_1_modifier_immortal_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_1__heal:CalcStatus(duration, caster, target)
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

    function dasdingo_1__heal:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_1__heal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_1__heal:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("dasdingo__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        return att.talents[1][upgrade]
    end

    function dasdingo_1__heal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local att = caster:FindAbilityByName("dasdingo__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1

        -- UP 1.32
        if self:GetRank(32) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_1__heal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_1__heal:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function dasdingo_1__heal:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 1.21
        if self:GetRank(21) then
            duration = duration + 10
        end

        CreateModifierThinker(caster, self, "dasdingo_1_modifier_heal", {duration = duration}, point, caster:GetTeamNumber(), false)
    end

-- EFFECTS