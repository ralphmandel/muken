genuine_5__awakening = class({})
LinkLuaModifier("genuine_5_modifier_charges", "heroes/genuine/genuine_5_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_5_modifier_recharge", "heroes/genuine/genuine_5_modifier_recharge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_5__awakening:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function genuine_5__awakening:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_5__awakening:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_5__awakening:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function genuine_5__awakening:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 5.31
        if self:GetRank(31) then
            charges = charges * 2
        end

        -- UP 5.41
        if self:GetRank(41) then
            self.charges = self:GetSpecialValueFor("charges") + 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_5__awakening:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.charges = 0
    end

-- SPELL START

    genuine_5__awakening.projectiles = {}

    function genuine_5__awakening:GetIntrinsicModifierName()
        return "genuine_5_modifier_charges"
    end

    function genuine_5__awakening:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()

        local time = self:GetChannelTime()
        local gesture_time = 0.4

        local rate = 1 / (time / gesture_time)
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, rate)

        self:PlayEfxChannel(point, time * 100)
    end

    function genuine_5__awakening:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()

        Timers:CreateTimer((0.1), function()
            caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
        end)

        local projectile_name = "particles/genuine/genuine_powershoot/genuine_spell_powershot_ti6.vpcf"
        local damage = self:GetAbilityDamage()
        local damage_reduction = 1 - (self:GetSpecialValueFor("damage_reduction") * 0.01)
        local vision_radius = self:GetSpecialValueFor("vision_radius")
        local arrow_speed = self:GetSpecialValueFor("arrow_speed")
        local arrow_width = self:GetSpecialValueFor("arrow_width")
        local projectile_direction = point-caster:GetOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()

        -- UP 5.31
        if self:GetRank(31) then
            arrow_speed = arrow_speed + 1000
        end

        -- UP 5.32
        if self:GetRank(32) then
            damage_reduction = 1
        end

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = self:GetCastRange(caster:GetAbsOrigin(), nil) * channel_pct,
            fStartRadius = arrow_width,
            fEndRadius = arrow_width,
            vVelocity = projectile_direction * arrow_speed,
        
            bProvidesVision = true,
            iVisionRadius = vision_radius,
            iVisionTeamNumber = caster:GetTeamNumber(),
        }
        local projectile = ProjectileManager:CreateLinearProjectile(info)

        self.projectiles[projectile] = {}
        self.projectiles[projectile].damage = damage * channel_pct
        self.projectiles[projectile].reduction = damage_reduction
        self.knockbackProperties = nil

        -- UP 5.32
        if self:GetRank(32) then
            self.knockbackProperties =
            {
                center_x = caster:GetAbsOrigin().x + 1,
                center_y = caster:GetAbsOrigin().y + 1,
                center_z = caster:GetAbsOrigin().z,
                knockback_height = 0,
                duration = 0.35,
                knockback_duration = 0.35,
                knockback_distance = 700 * channel_pct
            }
        end

        self:StopEfxChannel()
    end

    function genuine_5__awakening:OnProjectileHitHandle(target, location, handle)
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

        if self.knockbackProperties and target:IsAlive() then
            target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
            target:AddNewModifier(caster, self, "_modifier_movespeed_debuff", {percent = 100, duration = 1.2})
        end

        if IsServer() then target:EmitSound("Hero_Windrunner.PowershotDamage") end
    end

    function genuine_5__awakening:OnProjectileThink(location)
        local tree_width = self:GetSpecialValueFor("tree_width")
        GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
    end

    function genuine_5__awakening:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")

        if self:GetCurrentAbilityCharges() == 0 then
            return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
        end

        if self:GetCurrentAbilityCharges() % 2 == 0 then
            channel_time = channel_time + 1
        end

        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

    function genuine_5__awakening:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("arrow_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range = cast_range + 1600 end
        return cast_range
    end

    function genuine_5__awakening:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function genuine_5__awakening:PlayEfxChannel(point, time)
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

    function genuine_5__awakening:StopEfxChannel()
        local caster = self:GetCaster()
        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

        if IsServer() then
            caster:StopSound("Ability.PowershotPull.Lyralei")
            caster:EmitSound("Ability.Powershot.Alt")
        end
    end