genuine_2__fallen = class({})
LinkLuaModifier("genuine_0_modifier_fear", "heroes/genuine/genuine_0_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear_status_effect", "heroes/genuine/genuine_0_modifier_fear_status_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_2__fallen:CalcStatus(duration, caster, target)
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

    function genuine_2__fallen:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function genuine_2__fallen:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_2__fallen:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("genuine__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        return att.talents[2][upgrade]
    end

    function genuine_2__fallen:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local att = caster:FindAbilityByName("genuine__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
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

    function genuine_2__fallen:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_2__fallen:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
    
        local speed = self:GetSpecialValueFor("speed")
        local radius = self:GetSpecialValueFor("radius")
        local distance = self:GetCastRange( point, nil )
        local direction = point - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            bDeleteOnHit = false,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf",
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = direction * speed
        }
        ProjectileManager:CreateLinearProjectile(info)
        if IsServer() then caster:EmitSound("Hero_DrowRanger.Silence") end
    end

    function genuine_2__fallen:OnProjectileHit(hTarget, vLocation)
        if not hTarget then return end
        local caster = self:GetCaster()
        local fear_duration = self:GetSpecialValueFor("fear_duration")
        local mana_steal = self:GetSpecialValueFor("mana_steal")

        if mana_steal > hTarget:GetMana() then mana_steal = hTarget:GetMana() end
        if mana_steal > 0 then
            hTarget:ReduceMana(mana_steal)
            caster:GiveMana(mana_steal)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, hTarget, mana_steal, caster)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, mana_steal, caster)
        end

        hTarget:AddNewModifier(caster, self, "genuine_0_modifier_fear", {
            duration = self:CalcStatus(fear_duration, caster, hTarget)
        })

        self:PlayEffects(hTarget)
    end

-- EFFECTS

    function genuine_2__fallen:PlayEffects(target)
        local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end