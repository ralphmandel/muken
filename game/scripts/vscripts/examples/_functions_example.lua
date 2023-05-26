
-- PROJECTILES

    function functions_example:OnSpellStart()
        local caster = self:GetCaster()

        if target:TriggerSpellAbsorb(self) then
            return
        end

        local units = FindUnitsInRadius(
          caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetAOERadius(),
          self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
          self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
        )

        for _,unit in pairs(units) do end

        local heal = 1 * BaseStats(caster):GetHealPower()
        caster:Heal(heal, self)

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
            iVisionTeamNumber = caster:GetTeamNumber(),
            bDodgeable = false
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
            attacker = attacker, victim = victim,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }

        ApplyDamage(damageTable)
    end

-- UTILS

    function functions_example:AddTarget(target)
        for _,enemy in pairs(self.enemies) do
            if enemy then
                if IsValidEntity(enemy) then
                    if target == enemy then
                        return
                    end
                end
            end
        end

        table.insert(self.enemies, target)
    end

    function functions_example:RemoveAllTargets()
        for _,enemy in pairs(self.enemies) do
            if enemy then
                if IsValidEntity(enemy) then
                    enemy:RemoveModifierByNameAndCaster("flea_u_modifier_target", self.caster)
                end
            end
        end

        self.enemies = {}
    end