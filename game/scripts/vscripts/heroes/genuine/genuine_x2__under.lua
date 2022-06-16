genuine_x2__under = class({})
LinkLuaModifier("genuine_x2_modifier_under", "heroes/genuine/genuine_x2_modifier_under", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_x2__under:CalcStatus(duration, caster, target)
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

    function genuine_x2__under:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_x2__under:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_x2__under:OnUpgrade()
        self:SetHidden(false)
    end

    function genuine_x2__under:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_x2__under:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()

        local time = self:GetChannelTime()
	    local gesture_time = 0.4

        local rate = 1 / (time / gesture_time)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, rate)

        self:PlayEfxChannel(point, time * 100)
    end

    function genuine_x2__under:OnChannelFinish( bInterrupted )
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()

        Timers:CreateTimer((0.1), function()
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
		end)
    
        local damage = self:GetSpecialValueFor("powershot_damage")
        local reduction = 1 - (self:GetSpecialValueFor("damage_reduction") * 0.01)
        local vision_radius = self:GetSpecialValueFor("vision_radius")
        
        local projectile_name = "particles/genuine/genuine_powershoot/genuine_spell_powershot_ti6.vpcf"
        local projectile_speed = self:GetSpecialValueFor("arrow_speed")
        local projectile_distance = self:GetSpecialValueFor("arrow_range")
        local projectile_radius = self:GetSpecialValueFor("arrow_width")
        local projectile_direction = point-caster:GetOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_radius,
            fEndRadius = projectile_radius,
            vVelocity = projectile_direction * projectile_speed,
        
            bProvidesVision = true,
            iVisionRadius = vision_radius,
            iVisionTeamNumber = caster:GetTeamNumber(),
        }
        local projectile = ProjectileManager:CreateLinearProjectile(info)

        self.projectiles[projectile] = {}
        self.projectiles[projectile].damage = damage * channel_pct
        self.projectiles[projectile].reduction = reduction
    
        self:StopEfxChannel()
    end

    genuine_x2__under.projectiles = {}

    function genuine_x2__under:OnProjectileHitHandle(target, location, handle)
        local caster = self:GetCaster()

        if not target then
            self.projectiles[handle] = nil

            local vision_radius = self:GetSpecialValueFor("vision_radius")
            local vision_duration = self:GetSpecialValueFor("vision_duration")
            AddFOWViewer(caster:GetTeamNumber(), location, vision_radius, vision_duration, false)
    
            return
        end
    
        local data = self.projectiles[handle]
        local damage = data.damage
    
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }

        ApplyDamage(damageTable)
        data.damage = damage * data.reduction
    
        if IsServer() then target:EmitSound("Hero_Windrunner.PowershotDamage") end
    end
    
    function genuine_x2__under:OnProjectileThink(location)
        local tree_width = self:GetSpecialValueFor("tree_width")
        GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
    end

    function genuine_x2__under:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

-- EFFECTS

    function genuine_x2__under:PlayEfxChannel(point, time)
        local caster = self:GetCaster()
        local particle_cast = "particles/genuine/genuine_powershoot/genuine_powershot_channel_combo_v2.vpcf"
        local direction = point - caster:GetAbsOrigin()

        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
        self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(self.effect_cast, 0, caster:GetOrigin())
        ParticleManager:SetParticleControlForward(self.effect_cast, 0, direction:Normalized())
        ParticleManager:SetParticleControl(self.effect_cast, 1, caster:GetOrigin())
        ParticleManager:SetParticleControlForward(self.effect_cast, 1, direction:Normalized())
        ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(math.floor(time), 0, 0))

        if IsServer() then EmitSoundOnLocationForAllies(caster:GetOrigin(), "Ability.PowershotPull.Lyralei", caster) end
    end

    function genuine_x2__under:StopEfxChannel()
        local caster = self:GetCaster()
        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

        if IsServer() then
            caster:StopSound("Ability.PowershotPull.Lyralei")
            caster:EmitSound("Ability.Powershot.Alt")
        end
    end