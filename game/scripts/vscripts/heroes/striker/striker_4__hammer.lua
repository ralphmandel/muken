striker_4__hammer = class({})
LinkLuaModifier("striker_4_modifier_hammer", "heroes/striker/striker_4_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_4__hammer:CalcStatus(duration, caster, target)
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

    function striker_4__hammer:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_4__hammer:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_4__hammer:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function striker_4__hammer:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2 -- cast range
        end

        -- UP 4.12
        if self:GetRank(12) then
            charges = charges * 3 -- cast point
        end

        -- UP 4.21
        if self:GetRank(21) then
            charges = charges * 5 -- pierces magic immunity
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function striker_4__hammer:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_4__hammer:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then return false end

        self:PlayEfxStart(self:GetCursorTarget())

        return true
    end

    function striker_4__hammer:OnAbilityPhaseInterrupted()
        self:PlayEfxInterrupted()
    end

    function striker_4__hammer:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local level = self:CalculateLevel(caster, target)
        local isDamageRadius = false

        if target:IsIllusion() then target:ForceKill(false) return end

        local hammer_radius = self:GetSpecialValueFor("hammer_radius")
        local stun_duration = self:GetSpecialValueFor("stun_duration") * level
        local damage = self:GetAbilityDamage() * level

        -- UP 4.22
        if self:GetRank(22) then
            stun_duration = (self:GetSpecialValueFor("stun_duration") + 0.5) * level
        end

        -- UP 4.41
        if self:GetRank(41) then
            damage = (self:GetAbilityDamage() + 25) * level
            isDamageRadius = true
        end

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }

        if isDamageRadius == false then ApplyDamage(damageTable) end
    
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, hammer_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            if isDamageRadius then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end

            if enemy:IsAlive() then
                enemy:AddNewModifier(caster, self, "_modifier_stun", {duration = stun_duration})
            end
        end
    
        GridNav:DestroyTreesAroundPoint(target:GetOrigin(), hammer_radius, true)

        self:PlayEfxInterrupted()
        self:PlayEfxEnd(target, level, hammer_radius)
    end

    function striker_4__hammer:CalculateLevel(caster, target)
        local level = 1
        if caster:GetLevel() % 2 == 0 and target:GetLevel() % 3 == 0 then level = level + 1 end
        if caster:GetLevel() % 3 == 0 and target:GetLevel() % 2 == 0 then level = level + 1 end
        if caster:GetLevel() == target:GetLevel() then return 2 end
        if target:IsHero() == false then return 1 end

        return level
    end

    function striker_4__hammer:GetAOERadius()
        return self:GetSpecialValueFor("hammer_radius")
    end

    function striker_4__hammer:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        -- UP 4.21
        if self:GetCurrentAbilityCharges() % 5 == 0 then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            flag, caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then return result end

        return UF_SUCCESS
    end

    function striker_4__hammer:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return cast_range + 200 end
        return cast_range
    end

    function striker_4__hammer:GetCastPoint()
        local cast_point = self:GetSpecialValueFor("cast_point")
        if self:GetCurrentAbilityCharges() == 0 then return cast_point end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return cast_point - 1 end
        return cast_point
    end

    function striker_4__hammer:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function striker_4__hammer:PlayEfxStart(target)
        local caster = self:GetCaster()
        local particle = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_beam_shaft.vpcf"
        self.efx_light = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(self.efx_light, 0, target:GetOrigin())

        caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

        if IsServer() then caster:EmitSound("Hero_Nevermore.RequiemOfSoulsCast") end
    end

    function striker_4__hammer:PlayEfxInterrupted()
        local caster = self:GetCaster()
        if self.efx_light then ParticleManager:DestroyParticle(self.efx_light, false) end

        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)

        if IsServer() then caster:StopSound("Hero_Nevermore.RequiemOfSoulsCast") end
    end

    function striker_4__hammer:PlayEfxEnd(target, level, radius)
        local caster = self:GetCaster()
        local particle = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
    
        local particle2 = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf"
        local effect2 = ParticleManager:CreateParticle(particle2, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect2, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect2, 1, target:GetOrigin())
    
        local particle3 = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf"
        local effect3 = ParticleManager:CreateParticle(particle3, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect3, 0, target:GetOrigin() )
        ParticleManager:SetParticleControl(effect3, 2, Vector(radius, radius, radius))
    
        local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(level, 1, level))
    
        if IsServer() then target:EmitSound("Hero_Striker.Hammer.Strike") end
    end