druid_u__seed = class({})
LinkLuaModifier("druid_u_modifier_aura", "heroes/druid/druid_u_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_aura_effect", "heroes/druid/druid_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_u__seed:CalcStatus(duration, caster, target)
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

    function druid_u__seed:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function druid_u__seed:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_u__seed:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("druid__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        return att.talents[4][upgrade]
    end

    function druid_u__seed:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local att = caster:FindAbilityByName("druid__attributes")
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
		end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function druid_u__seed:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function druid_u__seed:GetIntrinsicModifierName()
        return "druid_u_modifier_aura"
    end

    function druid_u__seed:OnProjectileHit(hTarget, vLocation)
        if not hTarget then return end
        if hTarget:IsInvulnerable() then return end

        local caster = self:GetCaster()
        local seed_heal = self:GetSpecialValueFor("seed_heal")
        local mnd = caster:FindModifierByName("_2_MND_modifier")
        if mnd then seed_heal = seed_heal * mnd:GetHealPower() end

        hTarget:Heal(seed_heal, self)
        self:PlayEfxHeal(hTarget)
    end

    function druid_u__seed:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS

    function druid_u__seed:PlayEfxHeal(target)
        local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then target:EmitSound("Druid.Seed.Heal") end
    end