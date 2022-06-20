bloodstained_1__rage = class({})
LinkLuaModifier( "bloodstained_1_modifier_rage", "heroes/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_berserk", "heroes/bloodstained/bloodstained_1_modifier_berserk", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_rage_status_efx", "heroes/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_berserk_status_efx", "heroes/bloodstained/bloodstained_1_modifier_berserk_status_efx", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function bloodstained_1__rage:CalcStatus(duration, caster, target)
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

    function bloodstained_1__rage:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_1__rage:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_1__rage:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function bloodstained_1__rage:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[1][0] = true end

        local charges = 1

        -- UP 1.22
        if self:GetRank(22) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function bloodstained_1__rage:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_1__rage:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "bloodstained_1_modifier_rage", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        self:EndCooldown()
        self:SetActivated(false)

        -- UP 1.22
        if self:GetRank(22) then
            local radius = self:GetCastRange(caster:GetOrigin(), nil)
            self:PlayEfxBerserk(radius)

            local units = FindUnitsInRadius(
                caster:GetTeamNumber(), caster:GetOrigin(), nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0, 2, false
            )

            for _,unit in pairs(units) do
                unit:SetForceAttackTarget(caster)
                unit:MoveToTargetToAttack(caster)
                unit:AddNewModifier(caster, self, "bloodstained_1_modifier_berserk", {
                    duration = self:CalcStatus(4, caster, unit)
                })
            end
        end
    end

    function bloodstained_1__rage:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 400 end
        return 0
    end

    function bloodstained_1__rage:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function bloodstained_1__rage:PlayEfxBerserk(radius)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end