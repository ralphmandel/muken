template_3__sk3 = class({})
LinkLuaModifier("template_3_modifier_sk3", "heroes/template/template_3_modifier_sk3", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function template_3__sk3:CalcStatus(duration, caster, target)
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

    function template_3__sk3:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function template_3__sk3:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function template_3__sk3:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("template__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_id_name" then return end

        return att.talents[3][upgrade]
    end

    function template_3__sk3:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_id_name" then return end

        local att = caster:FindAbilityByName("template__attributes")
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
        self:SetCurrentAbilityCharges(charges)
    end

    function template_3__sk3:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function template_3__sk3:OnSpellStart()
        local caster = self:GetCaster()
    end

    function template_3__sk3:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS