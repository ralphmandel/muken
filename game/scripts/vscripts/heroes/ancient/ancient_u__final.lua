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
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function ancient_u__final:Spawn()
        self:SetCurrentAbilityCharges(0)
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
        self:StopEffects1(false)
    
        local name = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
        local distance = self:GetCastRange(point, nil)
        local radius = self:GetSpecialValueFor("radius")
        local speed = self:GetSpecialValueFor("speed")
        local flag = DOTA_UNIT_TARGET_FLAG_NONE
    
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
        }
        ProjectileManager:CreateLinearProjectile(info)
    end

    function ancient_u__final:OnProjectileHit( target, location )
        if not target then return end
        local caster = self:GetCaster()

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self, --Optional.
        }
        ApplyDamage(damageTable)
    
        -- local pull_duration = self:GetSpecialValueFor("pull_duration")
        -- local pull_distance = self:GetSpecialValueFor("pull_distance")
        -- local mod = target:AddNewModifier(
        --     caster, -- player source
        --     self, -- ability source
        --     "modifier_generic_arc_lua", -- modifier name
        --     {
        --         target_x = location.x,
        --         target_y = location.y,
        --         duration = pull_duration,
        --         distance = pull_distance,
        --         activity = ACT_DOTA_FLAIL,
        --     } -- kv
        -- )
    
        -- self:PlayEffects2(target, mod)
    
        return false
    end

    function ancient_u__final:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("distance") * self:GetCaster():GetMana()
    end

-- EFFECTS

    function ancient_u__final:PlayEffects2(target, mod)
        local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)
        mod:AddParticle(effect_cast, false, false, -1, false, false)
    end

    function ancient_u__final:PlayEffects1()
        local caster = self:GetCaster()
        local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
        self.effect_cast = effect_cast

        caster:AddNewModifier(caster, self, "ancient_u_modifier_pos", {duration = 2})
    end

    function ancient_u__final:StopEffects1(interrupted)
        local caster = self:GetCaster()
        ParticleManager:DestroyParticle(self.effect_cast, interrupted)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)
        if interrupted == true then caster:RemoveModifierByName("ancient_u_modifier_pos") end
    end