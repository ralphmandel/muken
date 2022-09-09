striker_5__sof = class({})
LinkLuaModifier("striker_5_modifier_sof", "heroes/striker/striker_5_modifier_sof", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_illusion_sof", "heroes/striker/striker_5_modifier_illusion_sof", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_trail", "heroes/striker/striker_5_modifier_trail", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_trail_effect", "heroes/striker/striker_5_modifier_trail_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_return", "heroes/striker/striker_5_modifier_return", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_debuff", "heroes/striker/striker_5_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_5__sof:CalcStatus(duration, caster, target)
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

    function striker_5__sof:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_5__sof:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_5__sof:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function striker_5__sof:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function striker_5__sof:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.autocast = false
    end

-- SPELL START

    function striker_5__sof:OnSpellStart()
        self.autocast = false
        self:PerformAbility()

        -- UP 5.11
        self.fisrt_strike = self:GetRank(11)
    end

    function striker_5__sof:PerformAbility()
        self:ResetHammer()
        self:Throw_hammer()

        local caster = self:GetCaster()
        self.buff_duration = self:CalcStatus(self:GetSpecialValueFor("buff_duration"), caster, caster)
        caster:AddNewModifier(caster, self, "striker_5_modifier_sof", {duration = self.buff_duration})
        
        return true
    end

    function striker_5__sof:Throw_hammer()
        local caster = self:GetCaster()
        local distance = self:GetSpecialValueFor("distance")
        local radius = 175
        local speed = 1500

        -- UP 5.21
        if self:GetRank(21) then
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
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,

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

    function striker_5__sof:OnProjectileThinkHandle(iProjectileHandle)
        if self.hammer == iProjectileHandle then
            local point = ProjectileManager:GetLinearProjectileLocation(iProjectileHandle)
            GridNav:DestroyTreesAroundPoint(point, 150, true)

            -- UP 5.21
            if self:GetRank(21) then
                self:CreateTrail(point)
            end
        end
    end

    function striker_5__sof:OnProjectileHitHandle(target, location, iProjectileHandle)
        if not iProjectileHandle then return end

        if self.hammer == iProjectileHandle then
            if target then
                self:HammerHit(target)

                if self.fisrt_strike then
                    self.fisrt_strike = false
                    ApplyDamage({
                        victim = target, attacker = self:GetCaster(),
                        damage = RandomInt(100, 150),
                        damage_type = self:GetAbilityDamageType(),
                        ability = self
                    })
                end

                -- UP 5.21
                if self:GetRank(21) == false
                and target:IsHero() then
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
            target:RemoveModifierByNameAndCaster("striker_5_modifier_return", self:GetCaster())
        end
    end

    function striker_5__sof:CreateTrail(loc)
        local caster = self:GetCaster()
        local thinker = CreateModifierThinker(
            caster, self, "striker_5_modifier_trail",{
                duration = self.buff_duration, x = loc.x, y = loc.y,
            }, loc, caster:GetTeamNumber(), false
        )
    end

    function striker_5__sof:HammerHit(target)
        local caster = self:GetCaster()
        local slow_duration = self:GetSpecialValueFor("slow_duration")

        target:AddNewModifier(caster, self, "striker_5_modifier_debuff", {
            duration = self:CalcStatus(slow_duration, caster, target)
        })
    
        self:PlayEfxHammerHit(target)
    end

    function striker_5__sof:ResetHammer()
        self.hammer_loc = nil
        self.hammer_return = nil
        self:StopEfxHammerThrow()
        self:StopEfxHammerGround()

        if self.hammer then
            ParticleManager:DestroyLinearProjectile(self.hammer)
            self.hammer = nil
        end
    end

    function striker_5__sof:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function striker_5__sof:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function striker_5__sof:PlayEfxHammerThrow(distance, velocity)
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

    function striker_5__sof:PlayEfxHammerHit(target)
        local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf" 
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(150, 150, 150))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Dawnbreaker.Celestial_Hammer.Damage") end
    end

    function striker_5__sof:PlayEfxHammerGround(location)
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

    function striker_5__sof:StopEfxHammerThrow()
        if self.fow then RemoveFOWViewer(self:GetCaster():GetTeamNumber(), self.fow) end

        if self.pfx_hammer then
            ParticleManager:DestroyParticle(self.pfx_hammer, false)
            ParticleManager:ReleaseParticleIndex(self.pfx_hammer)
            self.pfx_hammer = nil
        end
    end

    function striker_5__sof:StopEfxHammerGround()
        if self.pfx_hammer_ground then
            ParticleManager:DestroyParticle(self.pfx_hammer_ground, false)
            ParticleManager:ReleaseParticleIndex(self.pfx_hammer_ground)
            self.pfx_hammer_ground = nil
        end
    end