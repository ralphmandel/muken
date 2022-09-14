striker_4__hammer = class({})
LinkLuaModifier("striker_4_modifier_hammer", "heroes/striker/striker_4_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_4__hammer:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
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
            charges = charges * 2 -- cast point
        end

        -- UP 4.41
        if self:GetRank(41) then
            charges = charges * 3 -- AoE radius
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
        local isDamageRadius = false

        if target:IsIllusion() then target:ForceKill(false) end

        local stun_duration = self:GetSpecialValueFor("stun_duration") * level
        local damage = self:GetAbilityDamage() * level

        -- UP 4.21
        if self:GetRank(21) then
            stun_duration = (self:GetSpecialValueFor("stun_duration") + 0.75) * level
        end

        -- UP 4.31
        if self:GetRank(31) then
            isDamageRadius = true
        end

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }
    
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, hammer_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            if isDamageRadius or enemy == target then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end

            if enemy:IsAlive() then
                enemy:AddNewModifier(caster, self, "_modifier_stun", {duration = stun_duration})
            end
        end
    
        GridNav:DestroyTreesAroundPoint(target:GetOrigin(), hammer_radius, true)

        self:PlayEfxEnd(false, bGesture)
        self:PlayEfxHammer(target, level, hammer_radius)
    end

    function striker_4__hammer:CalculateLevel(caster, target)
        local level = 1
        if caster:GetLevel() % 2 == 0 and target:GetLevel() % 3 == 0 then level = level + 1 end
        if caster:GetLevel() % 3 == 0 and target:GetLevel() % 2 == 0 then level = level + 1 end
        if caster:GetLevel() == target:GetLevel() then return 2 end
        if target:IsHero() == false then return 1 end

        return level
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

    function striker_4__hammer:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("cast_range")
    end

    function striker_4__hammer:GetCastPoint()
        local cast_point = self:GetSpecialValueFor("cast_point")
        if self:GetCurrentAbilityCharges() == 0 then return cast_point end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return cast_point - 1 end
        return cast_point
    end

    function striker_4__hammer:GetAOERadius()
        local hammer_radius = self:GetSpecialValueFor("hammer_radius")
        if self:GetCurrentAbilityCharges() == 0 then return hammer_radius end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return hammer_radius + 100 end
        return hammer_radius
    end

    function striker_4__hammer:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
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

        -- UP 4.11
        if self:GetRank(11) then
            flRate = 1.7
        end

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