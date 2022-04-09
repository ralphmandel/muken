shadow_1__weapon = class({})
LinkLuaModifier("shadow_0_modifier_poison", "heroes/shadow/shadow_0_modifier_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_0_modifier_poison_stack", "heroes/shadow/shadow_0_modifier_poison_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_1_modifier_weapon", "heroes/shadow/shadow_1_modifier_weapon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_1_modifier_faster", "heroes/shadow/shadow_1_modifier_faster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_1_modifier_shadow_mode", "heroes/shadow/shadow_1_modifier_shadow_mode", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_1__weapon:CalcStatus(duration, caster, target)
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

    function shadow_1__weapon:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_1__weapon:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_1__weapon:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("shadow__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

        return att.talents[1][upgrade]
    end

    function shadow_1__weapon:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

        local att = caster:FindAbilityByName("shadow__attributes")
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
        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_1__weapon:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_1__weapon:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "shadow_1_modifier_weapon", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        if IsServer() then caster:EmitSound("Hero_Visage.SoulAssumption.Cast") end

        local disable = caster:FindAbilityByName("shadow_1__disable")
        if disable then
            if disable:IsTrained() then
                disable:SetHidden(false)
                self:SetHidden(true)
                self:EndCooldown()
            end
        end
    end