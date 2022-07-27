genuine_6__travel = class({})
LinkLuaModifier("genuine_6_modifier_orb", "heroes/genuine/genuine_6_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ethereal", "modifiers/_modifier_ethereal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ethereal_status_efx", "modifiers/_modifier_ethereal_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_6__travel:CalcStatus(duration, caster, target)
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

    function genuine_6__travel:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_6__travel:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_6__travel:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function genuine_6__travel:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        if self:GetLevel() == 1 then self:SetCurrentAbilityCharges(1) end
    end

    function genuine_6__travel:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_6__travel:ApplyStarfall()
        local caster = self:GetCaster()
        local starfall_damage = 75
        local starfall_radius = 250
        local damageTable = {
            attacker = caster,
            damage = starfall_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, starfall_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then caster:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_6__travel:ResetAbility()
        if self.projectileData then self.projectileData.modifier:Destroy() end
        ProjectileManager:DestroyLinearProjectile(self.projectile)
        self.projectileData = nil
        self.projectile = nil

        self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
        self:SetCurrentAbilityCharges(1)
    end

    function genuine_6__travel:Travel()
        local caster = self:GetCaster()
        local old_pos = caster:GetOrigin()
        local traveled_distance = (self.point - self.projectileData.location):Length2D()
        local silence_radius = self:GetSpecialValueFor("silence_radius")
        local silence_min = self:GetSpecialValueFor("silence_min")
        local silence_duration = silence_min + (traveled_distance * self:GetSpecialValueFor("silence_duration") * 0.01)

        -- UP 6.11
        if self:GetRank(11) then
            self:PlayEfxStarfall()
            Timers:CreateTimer((0.5), function()
                self:ApplyStarfall()
            end)
        end

        -- UP 6.12
        if self:GetRank(12) then
            silence_radius = silence_radius + 125
        end

        -- UP 6.41
        if self:GetRank(41) then
            caster:AddNewModifier(caster, self, "_modifier_ethereal", {
                duration = self:CalcStatus(silence_duration, caster, caster)
            })
        end

        FindClearSpaceForUnit(caster, ProjectileManager:GetLinearProjectileLocation(self.projectile), true)
        ProjectileManager:ProjectileDodge(caster)
        self:PlayEfxBlink(old_pos, silence_radius)

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, silence_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            if IsServer() then enemy:EmitSound("Hero_Puck.EtherealJaunt") end
            enemy:AddNewModifier(caster, self, "_modifier_silence", {
                duration = self:CalcStatus(silence_duration, caster, enemy)
            })
        end
    end

    function genuine_6__travel:OnSpellStart()
        if self.projectile then
            self:Travel()
            self:ResetAbility()
            return
        end

        print(self:GetBehavior())

        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local damage = self:GetAbilityDamage()
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
        local projectile_distance = self:GetSpecialValueFor("projectile_distance")
        local projectile_radius = self:GetSpecialValueFor("projectile_radius")
        local vision_radius = self:GetSpecialValueFor("vision_radius")
        local charges = 2

        local projectile_direction = point - caster:GetOrigin()
        projectile_direction = Vector(projectile_direction.x, projectile_direction.y, 0):Normalized()
        local projectile_name = "particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_merry_wanderer.vpcf"

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetOrigin(),
            
            bDeleteOnHit = false,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_radius,
            fEndRadius =projectile_radius,
            vVelocity = projectile_direction * projectile_speed,
        
            bReplaceExisting = false,
            
            bProvidesVision = true,
            iVisionRadius = vision_radius,
            iVisionTeamNumber = caster:GetTeamNumber(),
        }
        self.projectile = ProjectileManager:CreateLinearProjectile(info)

        local modifier = CreateModifierThinker(
            caster, self, "genuine_6_modifier_orb", {duration = 20},
            caster:GetOrigin(), caster:GetTeamNumber(), false		
        )

        modifier = modifier:FindModifierByName("genuine_6_modifier_orb")

        local extraData = {}
        extraData.damage = damage
        extraData.location = caster:GetOrigin()
        extraData.time = GameRules:GetGameTime()
        extraData.modifier = modifier
        self.projectileData = extraData
        self.point = caster:GetOrigin()

        -- UP 6.21
        if self:GetRank(21) then
            charges = 3
        end

        self:SetCurrentAbilityCharges(charges)
        self:EndCooldown()
    end

    function genuine_6__travel:OnProjectileThinkHandle(proj)
        local location = ProjectileManager:GetLinearProjectileLocation(proj)
        self.projectileData.location = location
        self.projectileData.modifier:GetParent():SetOrigin(location)
    end
    
    function genuine_6__travel:OnProjectileHitHandle(target, location, proj)
        if not target then 
            self:ResetAbility()
            return true
        end
        
        local caster = self:GetCaster()
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = self.projectileData.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        }
        ApplyDamage(damageTable)

        if target:IsAlive() then
            -- UP 6.22
            if self:GetRank(22) then
                target:AddNewModifier(caster, self, "_modifier_stun", {
                    duration = self:CalcStatus(1, caster, target)
                })
            end
        end
    
        self:PlayEfxHit(target)
        return false
    end

    function genuine_6__travel:GetBehavior()
        if self:GetCurrentAbilityCharges() == 3 then
            return 137474607108
        end

        if self:GetCurrentAbilityCharges() == 2 then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
        end

        if self:GetCurrentAbilityCharges() == 1 then
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
        end

        if self:GetCurrentAbilityCharges() == 0 then
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
        end
    end

    function genuine_6__travel:GetAbilityTextureName()
        if self:GetCurrentAbilityCharges() > 1 then return "genuine_blink" end
        return "genuine_travel"
    end

    function genuine_6__travel:GetCastAnimation()
        if self:GetCurrentAbilityCharges() > 1 then return ACT_DOTA_SPAWN end
        return ACT_DOTA_CAST_ABILITY_2
    end

    function genuine_6__travel:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 1 then return manacost * level end

        return 0
    end

-- EFFECTS

    function genuine_6__travel:PlayEfxHit(target)
        local particle_cast = "particles/units/heroes/hero_puck/puck_orb_damage.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Puck.IIllusory_Orb_Damage") end
    end

    function genuine_6__travel:PlayEfxBlink(point, radius)
        local particle_cast = "particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, point)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        particle_cast = "particles/genuine/genuine_travel_silence/genuine_silence_aproset.vpcf"
        effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then self:GetCaster():EmitSound("Hero_Puck.Waning_Rift") end
    end

    function genuine_6__travel:PlayEfxStarfall()
        local caster = self:GetCaster()
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then caster:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end