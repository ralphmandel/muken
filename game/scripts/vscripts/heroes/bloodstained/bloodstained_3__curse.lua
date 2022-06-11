bloodstained_3__curse = class({})
LinkLuaModifier("bloodstained_3_modifier_curse", "heroes/bloodstained/bloodstained_3_modifier_curse", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_3__curse:CalcStatus(duration, caster, target)
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

    function bloodstained_3__curse:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_3__curse:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_3__curse:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("bloodstained__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        return att.talents[3][upgrade]
    end

    function bloodstained_3__curse:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local att = caster:FindAbilityByName("bloodstained__attributes")
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

        -- UP 3.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function bloodstained_3__curse:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_3__curse:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")

        if target:TriggerSpellAbsorb(self) then return end

        caster:RemoveModifierByName("bloodstained_3_modifier_curse")

        caster:AddNewModifier(caster, self, "bloodstained_3_modifier_curse", {
            duration = self:CalcStatus(duration, caster, target)
        })

        if IsServer() then caster:EmitSound("Hero_Oracle.FortunesEnd.Attack") end
    end

    function bloodstained_3__curse:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        -- UP 3.21
        if self:GetCurrentAbilityCharges() % 2 == 0 then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
            flag,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function bloodstained_3__curse:GetCustomCastErrorTarget( hTarget )
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

-- EFFECTS