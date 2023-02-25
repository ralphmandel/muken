striker_4__hammer = class({})
LinkLuaModifier("striker_4_modifier_hammer", "heroes/striker/striker_4_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function striker_4__hammer:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then return false end

        self.hammer_radius = self:GetAOERadius()
        self:PlayEfxStart(target, self.hammer_radius, true)

        return true
    end

    function striker_4__hammer:OnAbilityPhaseInterrupted()
        self:PlayEfxEnd(true, true)
    end

    function striker_4__hammer:OnSpellStart()
        self:LandHammer(self:GetCursorTarget(), self.hammer_radius, true)
    end

    function striker_4__hammer:PerformAbility(target)
        local caster = self:GetCaster()

        if target:TriggerSpellAbsorb(self) then return true end

        local hammer_radius = self:GetAOERadius()
        self:PlayEfxStart(target, hammer_radius, false)

        Timers:CreateTimer((self:GetCastPoint()), function()
            if target then
                if IsValidEntity(target) then
                    self:LandHammer(target, hammer_radius, false)
                end
            end
        end)

        return true
    end

    function striker_4__hammer:LandHammer(target, hammer_radius, bGesture)
        local caster = self:GetCaster()
        local level = self:CalculateLevel(caster, target)
        local break_duration = self:GetSpecialValueFor("special_break_duration")

        if target:HasModifier("bloodstained_u_modifier_copy") == false
		and target:IsIllusion() then
			target:ForceKill(false)
		end
    
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, hammer_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "_modifier_stun", {
                duration = self:GetSpecialValueFor("stun_duration") * level
            })

            if break_duration > 0 then
                enemy:AddNewModifier(caster, self, "_modifier_break", {
                    duration = CalcStatus(break_duration * level, caster, enemy)
                })
            end

            local total_damage = ApplyDamage({
                victim = enemy,
                attacker = caster,
                damage = self:GetSpecialValueFor("damage") * level,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })

            local heal = total_damage * self:GetSpecialValueFor("special_lifesteal") * 0.01
            if heal > 0 then caster:Heal(heal, self) end
        end
    
        GridNav:DestroyTreesAroundPoint(target:GetOrigin(), hammer_radius, true)

        self:PlayEfxEnd(false, bGesture)
        self:PlayEfxHammer(target, level, hammer_radius)
    end

    function striker_4__hammer:CalculateLevel(caster, target)
        local level_min = self:GetSpecialValueFor("level_min")

        if caster:GetLevel() == target:GetLevel() then level_min = level_min + 1 end
        if (caster:GetLevel() % 2 == 0 and target:GetLevel() % 3 == 0)
        or (caster:GetLevel() % 3 == 0 and target:GetLevel() % 2 == 0) then
            level_min = level_min + 1
        end

        return level_min
    end

    function striker_4__hammer:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            flag, caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then return result end

        return UF_SUCCESS
    end

    function striker_4__hammer:GetAOERadius()
        return self:GetSpecialValueFor("hammer_radius")
    end

-- EFFECTS

    function striker_4__hammer:PlayEfxStart(target, radius, bGesture)
        local caster = self:GetCaster()
        local flRate = 0.85

        local particle = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_aoe.vpcf"
        if self.efx_light then ParticleManager:DestroyParticle(self.efx_light, false) end
        self.efx_light = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(self.efx_light, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(self.efx_light, 1, target:GetOrigin())
        ParticleManager:SetParticleControl(self.efx_light, 2, Vector(radius, radius, 0))

        if bGesture then caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, flRate) end

        if IsServer() then caster:EmitSound("Hero_Dawnbreaker.Solar_Guardian.Channel") end
    end

    function striker_4__hammer:PlayEfxEnd(bInterrupted, bGesture)
        local caster = self:GetCaster()
        if self.efx_light then ParticleManager:DestroyParticle(self.efx_light, false) end

        if bGesture then
            if bInterrupted then
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
            else
                Timers:CreateTimer((0.3), function()
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
                end)
            end
        end

        if IsServer() then caster:StopSound("Hero_Dawnbreaker.Solar_Guardian.Channel") end
    end

    function striker_4__hammer:PlayEfxHammer(target, level, radius)
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