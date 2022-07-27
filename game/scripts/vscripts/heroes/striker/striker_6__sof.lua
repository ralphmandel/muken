striker_6__sof = class({})
LinkLuaModifier("striker_6_modifier_sof", "heroes/striker/striker_6_modifier_sof", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_6_modifier_sof_effect", "heroes/striker/striker_6_modifier_sof_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_6_modifier_illusion_sof", "heroes/striker/striker_6_modifier_illusion_sof", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_6_modifier_return", "heroes/striker/striker_6_modifier_return", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_6_modifier_debuff", "heroes/striker/striker_6_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_6__sof:CalcStatus(duration, caster, target)
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

    function striker_6__sof:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_6__sof:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_6__sof:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function striker_6__sof:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function striker_6__sof:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_6__sof:OnSpellStart()
        self:ResetHammer()
        self:Throw_hammer()

        local caster = self:GetCaster()
        local buff_duration = self:CalcStatus(self:GetSpecialValueFor("buff_duration"), caster, caster)
        caster:AddNewModifier(caster, self, "striker_6_modifier_sof", {duration = buff_duration})
    end

    function striker_6__sof:Throw_hammer()
        local caster = self:GetCaster()
        local distance = self:GetSpecialValueFor("distance")
        local radius = 150
        local speed = 1500

        -- UP 6.31
        if self:GetRank(31) then
            distance = distance + 500
        end
        
        local point = caster:GetOrigin() + caster:GetForwardVector():Normalized() * 100
        local hammer_direction = point - caster:GetOrigin()
        hammer_direction.z = 0
        hammer_direction = hammer_direction:Normalized()
        local velocity = caster:GetForwardVector() * speed

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
        
            bDeleteOnHit = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,

            bProvidesVision = true,
            iVisionRadius = 150,
            iVisionTeamNumber = caster:GetTeamNumber(),
        
            EffectName = "",
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = velocity
        }

        self.hammer = ProjectileManager:CreateLinearProjectile(info)
        self.pfx_hammer = self:PlayEfxHammerThrow(distance, velocity)
    end

    function striker_6__sof:OnProjectileThinkHandle(iProjectileHandle)
        if self.hammer == iProjectileHandle then
            local point = ProjectileManager:GetLinearProjectileLocation(iProjectileHandle)
            GridNav:DestroyTreesAroundPoint(point, 150, true)
        end
    end

    function striker_6__sof:OnProjectileHitHandle(target, location, iProjectileHandle)
        if not iProjectileHandle then return end

        if self.hammer == iProjectileHandle then
            if target then
                self:HammerHit(target)
                if target:IsHero() then
                    self:PlayEfxHammerGround(target:GetOrigin())
                    self.hammer_loc = location
                    self.hammer = nil
                    return true
                end
            else
                self:PlayEfxHammerGround(location)
                self.hammer_loc = location
                self.hammer = nil
            end
        end

        if self.hammer_return == iProjectileHandle then
            self.hammer_return = nil
            target:RemoveModifierByNameAndCaster("striker_6_modifier_return", self:GetCaster())
        end
    end

    function striker_6__sof:HammerHit(target)
        local caster = self:GetCaster()
        local slow_duration = self:GetSpecialValueFor("slow_duration")

        -- UP 6.31
        if self:GetRank(31) then
            slow_duration = slow_duration + 1
        end

        target:AddNewModifier(caster, self, "striker_6_modifier_debuff", {
            duration = self:CalcStatus(slow_duration, caster, target)
        })
    
        self:PlayEfxHammerHit(target)
    end

    function striker_6__sof:ResetHammer()
        self.hammer_loc = nil
        self.hammer_return = nil
        self:StopEfxHammerThrow()
        self:StopEfxHammerGround()

        if self.hammer then
            ParticleManager:DestroyLinearProjectile(self.hammer)
            self.hammer = nil
        end
    end

    function striker_6__sof:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function striker_6__sof:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function striker_6__sof:PlayEfxHammerThrow(distance, velocity)
        self:StopEfxHammerThrow()

        local caster = self:GetCaster()
        local min_rate = 1
        local duration = distance/velocity:Length2D()
        local rotation = 0.5

        local rate = rotation/duration
        while rate<min_rate do
            rotation = rotation + 1
            rate = rotation/duration
        end

        local particle_cast = "particles/econ/items/dawnbreaker/dawnbreaker_2022_cc/dawnbreaker_2022_cc_celestial_hammer_projectile.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, velocity)
        ParticleManager:SetParticleControl(effect_cast, 4, Vector(rate, 0, 0))

        if IsServer() then caster:EmitSound("Hero_Dawnbreaker.Celestial_Hammer.Cast") end

        return effect_cast
    end

    function striker_6__sof:PlayEfxHammerHit(target)
        local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf" 
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(150, 150, 150))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Dawnbreaker.Celestial_Hammer.Damage") end
    end

    function striker_6__sof:PlayEfxHammerGround(location)
        self:StopEfxHammerThrow()
        self:StopEfxHammerGround()

        local caster = self:GetCaster()
        local direction = location - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()

        local particle_cast = "particles/striker/striker_hammer_grounded.vpcf" 
        self.pfx_hammer_ground = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.pfx_hammer_ground, 0, location)
        ParticleManager:SetParticleControl(self.pfx_hammer_ground, 1, location)
        ParticleManager:SetParticleControlForward(self.pfx_hammer_ground, 0, direction)

        if IsServer() then EmitSoundOnLocationWithCaster(location, "Hero_Dawnbreaker.Celestial_Hammer.Impact", caster) end
        self.fow = AddFOWViewer(caster:GetTeamNumber(), location, 150, 30, false)
    end

    function striker_6__sof:StopEfxHammerThrow()
        if self.fow then RemoveFOWViewer(self:GetCaster():GetTeamNumber(), self.fow) end

        if self.pfx_hammer then
            ParticleManager:DestroyParticle(self.pfx_hammer, false)
            ParticleManager:ReleaseParticleIndex(self.pfx_hammer)
            self.pfx_hammer = nil
        end
    end

    function striker_6__sof:StopEfxHammerGround()
        if self.pfx_hammer_ground then
            ParticleManager:DestroyParticle(self.pfx_hammer_ground, false)
            ParticleManager:ReleaseParticleIndex(self.pfx_hammer_ground)
            self.pfx_hammer_ground = nil
        end
    end