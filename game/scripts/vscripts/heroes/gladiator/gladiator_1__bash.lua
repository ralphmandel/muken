gladiator_1__bash = class({})
LinkLuaModifier("gladiator_1_modifier_bash", "heroes/gladiator/gladiator_1_modifier_bash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function gladiator_1__bash:CalcStatus(duration, caster, target)
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

    function gladiator_1__bash:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function gladiator_1__bash:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function gladiator_1__bash:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("gladiator__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

        return att.talents[1][upgrade]
    end

    function gladiator_1__bash:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

        local att = caster:FindAbilityByName("gladiator__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function gladiator_1__bash:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function gladiator_1__bash:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local mod = caster:FindModifierByName("gladiator__modifier_effect")
        if mod then mod:ChangeActivity("") end

        return true
    end

    function gladiator_1__bash:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FindModifierByName("gladiator__modifier_effect"):ChangeActivity("loda")
    end

    function gladiator_1__bash:OnSpellStart()
        local caster = self:GetCaster()
        local proj_speed = self:GetSpecialValueFor("proj_speed")

        self.info = {
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

		ProjectileManager:CreateTrackingProjectile(self.info)
        caster:AddNewModifier(caster, self, "_modifier_disarm", {})
        self:SetActivated(false)

        local cosmetics = caster:FindAbilityByName("cosmetics")
        local model = "models/items/phantom_assassin/athena_pa_weapon/athena_pa_weapon.vmdl"
        if cosmetics then cosmetics:HideCosmetic(model, true) end
    end

    function gladiator_1__bash:OnProjectileHit(hTarget, vLocation)
        local caster = self:GetCaster()

        if hTarget == caster then
            caster:RemoveModifierByName("_modifier_disarm")
            self:SetActivated(true)

            local mod = caster:FindModifierByName("gladiator__modifier_effect")
            if mod then mod:ChangeActivity("loda") end

            local cosmetics = caster:FindAbilityByName("cosmetics")
            local model = "models/items/phantom_assassin/athena_pa_weapon/athena_pa_weapon.vmdl"
            if cosmetics then cosmetics:HideCosmetic(model, false) end

            return
        end
        
        self.info.Source = nil
        self.info.vSourceLoc = vLocation
        self.info.Target = caster
        ProjectileManager:CreateTrackingProjectile(self.info)

        if hTarget == nil then return end
        if hTarget:IsInvulnerable() then return end
		if hTarget:TriggerSpellAbsorb( self ) then return end

        local hit_damage = self:GetSpecialValueFor("hit_damage")
        local damageTable = {
            damage = hit_damage,
            attacker = caster,
            victim = hTarget,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }
        ApplyDamage(damageTable)
    end

-- EFFECTS