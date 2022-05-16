gladiator_1__bash = class({})
LinkLuaModifier("gladiator_1_modifier_bash", "heroes/gladiator/gladiator_1_modifier_bash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function gladiator_1__bash:CalcStatus(duration, caster, target)
        local time = duration
        local caster_int = nil
        local caster_mnd = nil
        local target_res = nil

        if caster ~= nil then
            caster_int = caster:FindModifierByName("_1_INT_modifier")
            caster_mnd = caster:FindModifierByName("_2_MND_modifier")
        end

        if target ~= nil then
            target_res = target:FindModifierByName("_2_RES_modifier")
        end

        if caster == nil then
            if target ~= nil then
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        else
            if target == nil then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
                else
                    if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                    if target_res then time = time * (1 - target_res:GetStatus()) end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function gladiator_1__bash:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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

        local channel = caster:FindAbilityByName("_channel")
        local model = "models/items/phantom_assassin/athena_pa_weapon/athena_pa_weapon.vmdl"
        if channel then channel:HideCosmetic(model, true) end
    end

    function gladiator_1__bash:OnProjectileHit(hTarget, vLocation)
        local caster = self:GetCaster()

        if hTarget == caster then
            caster:RemoveModifierByName("_modifier_disarm")
            self:SetActivated(true)

            local mod = caster:FindModifierByName("gladiator__modifier_effect")
            if mod then mod:ChangeActivity("loda") end

            local channel = caster:FindAbilityByName("_channel")
            local model = "models/items/phantom_assassin/athena_pa_weapon/athena_pa_weapon.vmdl"
            if channel then channel:HideCosmetic(model, false) end

            return
        end
        
        self.info.Source = nil
        self.info.vSourceLoc = vLocation
        self.info.Target = caster
        ProjectileManager:CreateTrackingProjectile(self.info)

        if hTarget == nil then return end

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