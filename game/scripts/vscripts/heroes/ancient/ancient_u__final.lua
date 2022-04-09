ancient_u__final = class({})
LinkLuaModifier("ancient_u_modifier_passive", "heroes/ancient/ancient_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_u_modifier_pos", "heroes/ancient/ancient_u_modifier_pos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

    function ancient_u__final:CalcStatus(duration, caster, target)
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

    function ancient_u__final:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function ancient_u__final:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_u__final:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("ancient__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        return att.talents[4][upgrade]
    end

    function ancient_u__final:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local att = caster:FindAbilityByName("ancient__attributes")
        if att then
            if att:IsTrained() then
                att.talents[4][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
            self:SetActivated(false)
		end

    	-- UP 4.12
        if self:GetRank(12) then
            --if IsServer() then self:SetStackCount(200) end
            self.mana_bonus = 200
            local void = caster:FindAbilityByName("_void")
            if void then void:SetLevel(1) end
        end

        -- UP 4.21
        if self:GetRank(21) then
            local con_mod = caster:FindModifierByName("_1_CON_modifier")
            if con_mod then con_mod:SetRegenState(false) end
        end

        -- UP 4.22
        self.min_mana = self:GetSpecialValueFor("min_mana")
        if self:GetRank(22) then
            self.min_mana = self.min_mana - 10
        end

        -- UP 4.31
        if self:GetRank(31) then
            local berserk = caster:FindAbilityByName("ancient_1__berserk")
            if berserk then
                if berserk:IsTrained() then
                    berserk.natural_loss = berserk:GetSpecialValueFor("natural_loss") * 2
                end
            end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function ancient_u__final:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.casting = false
        self.mana_bonus = 0
    end

-- SPELL START

    function ancient_u__final:GetIntrinsicModifierName()
        return "ancient_u_modifier_passive"
    end

    function ancient_u__final:OnAbilityPhaseStart()
        self:PlayEffects1()
        return true
    end
    
    function ancient_u__final:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:SpendMana(math.floor(caster:GetMana() * 0.2), self)
        self:StopEffects1(true)
    end
    
    function ancient_u__final:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()

        self.mana_loss = 0
        self.damage = self:GetSpecialValueFor("damage") * caster:GetMana() * 0.01

        -- UP 4.21
        if self:GetRank(21) then
            local heal = caster:GetMana() * 0.3
            local mnd = caster:FindModifierByName("_2_MND_modifier")
            if mnd then heal = heal * mnd:GetHealPower() end
            caster:Heal(heal, self)
        end
    
        local name = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
        local distance = self:GetCastRange(point, nil)
        local radius = self:GetSpecialValueFor("radius")
        local speed = self:GetSpecialValueFor("speed")
        local flag = DOTA_UNIT_TARGET_FLAG_NONE
        local energy_left = 0

        -- UP 4.22
        if self:GetRank(22) then
            radius = radius + 50
        end

        -- UP 4.23
        if self:GetRank(23) then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
            energy_left = caster:GetMana() * 0.3
        end
    
        local direction = point - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()
    
        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            bDeleteOnHit = true,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = flag,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = name,
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = direction * speed,
            bProvidesVision = true,
            iVisionRadius = radius,
            iVisionTeamNumber = caster:GetTeamNumber()
        }

        ProjectileManager:CreateLinearProjectile(info)
        caster:SetMana(energy_left)
        self:StopEffects1(false)
    end

    function ancient_u__final:OnProjectileHit(target, location)
        if not target then return end
        local caster = self:GetCaster()
        local activity = ACT_DOTA_DISABLED
        local distance = 0
        local duration = 0.2

        -- UP 4.22
        if self:GetRank(22) then
            activity = ACT_DOTA_FLAIL
            distance = 375
            duration = 0.5
        end

        local calc_dist = CalcDistanceBetweenEntityOBB(caster, target)
        if distance > calc_dist then distance = calc_dist end

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage(damageTable)
    
        if target:IsMagicImmune() == false then
            local mod = target:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "_modifier_generic_arc", -- modifier name
                {
                    target_x = location.x,
                    target_y = location.y,
                    duration = duration,
                    distance = distance,
                    activity = activity,
                } -- kv
            )
        
            self:PlayEffects2(target, mod)
        end
    
        return false
    end

    function ancient_u__final:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("distance") * self:GetCaster():GetMana()
    end

-- EFFECTS

    function ancient_u__final:PlayEffects2(target, mod)
        local particle_cast = "particles/ancient/ancient_final_blow_hit.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)
        if mod then mod:AddParticle(effect_cast, false, false, -1, false, false) end

        if IsServer() then target:EmitSound("Ancient.Final.Hit") end
    end

    function ancient_u__final:PlayEffects1()
        local caster = self:GetCaster()
        self.casting = true

        local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
        self.effect_cast = effect_cast

        caster:FindModifierByName("ancient__modifier_effect"):ChangeActivity("")

        if IsServer() then caster:EmitSound("Ancient.Final.Pre") end
    end
    
    function ancient_u__final:StopEffects1(interrupted)
        local caster = self:GetCaster()
        self.casting = false

        ParticleManager:DestroyParticle(self.effect_cast, interrupted)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)

        caster:FindModifierByName("ancient__modifier_effect"):ChangeActivity("et_2021")

        if IsServer() then
            if interrupted == true then
                caster:StopSound("Ancient.Final.Pre")
            else
                caster:EmitSound("Ancient.Final.Cast")
            end
        end
    end

	-- function ancient_u__final:PlayEfxCharge(direction, target)
	-- 	local particle_cast = "particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf"
	-- 	local effect_charge = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	-- 	ParticleManager:SetParticleControl(effect_charge, 0, target:GetOrigin())
    --     ParticleManager:SetParticleControl(effect_charge, 1, target:GetOrigin())
	-- 	ParticleManager:SetParticleControlForward(effect_charge, 1, direction:Normalized())
    --     self.effect_charge = effect_charge
	-- end