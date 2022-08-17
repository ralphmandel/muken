
-- PROJECTILES

    function functions_example:OnSpellStart()
        local caster = self:GetCaster()

        -- TIMERS
        Timers:CreateTimer(0.2, function()
            print()
        end)

        -- DOMINATE UNITS
        local summoned_unit = nil
        summoned_unit:SetControllableByPlayer(self.caster:GetPlayerID(), false) -- (playerID, bSkipAdjustingPosition)

        -- TRACKING
        local tracking_info = {
            Target = self:GetCursorTarget(),
            Source = caster,
            Ability = self,	
            EffectName = "particles/gladiator/gladiator_shield_bash_proj.vpcf",
            iMoveSpeed = 900,
            bReplaceExisting = false,
            bProvidesVision = true,
            iVisionRadius = 150,
            iVisionTeamNumber = caster:GetTeamNumber()
        }

        ProjectileManager:CreateTrackingProjectile(tracking_info)

        -- LINEAR
        local linear_info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            bDeleteOnHit = false,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = flags,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = direction * speed,

            bProvidesVision = true,
			iVisionRadius = radius,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        ProjectileManager:CreateLinearProjectile(linear_info)
    end

    function functions_example:OnProjectileHit(hTarget, vLocation)
        local caster = self:GetCaster()
        if hTarget == nil then return end
        if hTarget:IsInvulnerable() then return end
        if hTarget:TriggerSpellAbsorb(self) then return end
    end

-- APPLY DAMAGE
    function functions_example:OnSpellStart()
        local damageTable = {
            damage = damage,
            attacker = attacker,
            victim = victim,
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }

        ApplyDamage(damageTable)
    end