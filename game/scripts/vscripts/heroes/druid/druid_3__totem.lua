druid_3__totem = class({})
LinkLuaModifier("druid_3_modifier_totem", "heroes/druid/druid_3_modifier_totem", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_totem_effect", "heroes/druid/druid_3_modifier_totem_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_passive", "heroes/druid/druid_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_charges", "heroes/druid/druid_3_modifier_charges", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_3__totem:CalcStatus(duration, caster, target)
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

    function druid_3__totem:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function druid_3__totem:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_3__totem:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("druid__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        return att.talents[3][upgrade]
    end

    function druid_3__totem:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local att = caster:FindAbilityByName("druid__attributes")
        if att then
            if att:IsTrained() then
                att.talents[3][0] = true
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

        -- UP 3.13
        if self:GetRank(13) then
            charges = charges * 2
        end

        -- UP 3.31
        if self:GetRank(31) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function druid_3__totem:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function druid_3__totem:GetIntrinsicModifierName()
        return "druid_3_modifier_passive"
    end

    function druid_3__totem:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        local charges = caster:FindModifierByName("druid_3_modifier_charges")
        if charges then
            self:EndCooldown()
            self:StartCooldown(charges:GetRemainingTime())
        end

        -- UP 3.31
        if self:GetRank(31) then
            local passive = caster:FindModifierByName("druid_3_modifier_passive")
            if passive then
                if passive:GetStackCount() > 0 then
                    passive:DecrementStackCount()
                end
            end
        else
            if self.summoned_unit then
                if IsValidEntity(self.summoned_unit) then
                    self.summoned_unit:RemoveModifierByName("druid_3_modifier_totem")
                end
            end
        end
    
        self.summoned_unit = CreateUnitByName("druid_totem", point, true, caster, caster, caster:GetTeamNumber())
        self.summoned_unit:SetControllableByPlayer(caster:GetPlayerID(), false)
        self.summoned_unit:SetOwner(caster)
        self.summoned_unit:AddNewModifier(caster, self, "druid_3_modifier_totem", {
            duration = self:CalcStatus(duration, caster, nil)
        })

        if IsServer() then self.summoned_unit:EmitSound("Hero_Treant.LeechSeed.Cast") end
    end

    function druid_3__totem:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_3__totem:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 350 end
        if self:GetCurrentAbilityCharges() == 1 then return 350 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 0 end
        return 350
    end

-- EFFECTS