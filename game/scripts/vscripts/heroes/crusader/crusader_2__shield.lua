crusader_2__shield = class({})
LinkLuaModifier("crusader_2_modifier_shield", "heroes/crusader/crusader_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_2_modifier_absorption", "heroes/crusader/crusader_2_modifier_absorption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function crusader_2__shield:CalcStatus(duration, caster, target)
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

    function crusader_2__shield:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function crusader_2__shield:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function crusader_2__shield:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("crusader__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        return att.talents[2][upgrade]
    end

    function crusader_2__shield:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        local att = caster:FindAbilityByName("crusader__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
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

        -- UP 2.5
        if self:GetRank(5) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function crusader_2__shield:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function crusader_2__shield:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
    
        caster:AddNewModifier(caster, self, "crusader_2_modifier_shield", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        -- UP 2.4
        if self:GetRank(4) == false then
            self:EndCooldown()
            self:SetActivated(false)
        end
    end

    function crusader_2__shield:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 400 end
    end

-- EFFECTS