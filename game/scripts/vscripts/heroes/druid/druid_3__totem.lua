druid_3__totem = class({})
LinkLuaModifier("druid_3_modifier_totem", "heroes/druid/druid_3_modifier_totem", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_totem_effect", "heroes/druid/druid_3_modifier_totem_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_passive", "heroes/druid/druid_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_3_modifier_charges", "heroes/druid/druid_3_modifier_charges", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_3__totem:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
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
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function druid_3__totem:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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