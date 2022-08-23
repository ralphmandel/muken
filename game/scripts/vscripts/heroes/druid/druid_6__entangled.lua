druid_6__entangled = class({})
LinkLuaModifier("druid_6_modifier_entangled", "heroes/druid/druid_6_modifier_entangled", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_6__entangled:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function druid_6__entangled:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_6__entangled:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_6__entangled:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function druid_6__entangled:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_6__entangled:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_6__entangled:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, target)

        if target:TriggerSpellAbsorb(self) then return end

        target:AddNewModifier(caster, self, "druid_6_modifier_entangled", {duration = duration})
        if IsServer() then caster:EmitSound("Hero_Treant.LeechSeed.Cast") end
    end

    function druid_6__entangled:CreateSeedProj(target, source, leech_amount)
        ProjectileManager:CreateTrackingProjectile({
            Target = target,
            Source = source,
            Ability = self,	
            EffectName = "particles/druid/druid_ult_projectile.vpcf",
            iMoveSpeed = 250,
            bReplaceExisting = false,
            bProvidesVision = true,
            iVisionRadius = 75,
            iVisionTeamNumber = target:GetTeamNumber(),
            ExtraData = {damage = leech_amount}
        })
    end

    function druid_6__entangled:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
        if not hTarget then return end
        local heal = ExtraData.damage
        local base_stats = self:GetCaster():FindAbilityByName("base_stats")
        if base_stats then heal = heal * base_stats:GetHealPower() end
    
        if heal > 0 then
            hTarget:Heal(heal, self)
            self:PlayEfxHeal(hTarget)
        end
    end

    function druid_6__entangled:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_6__entangled:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("cast_range")
    end

    function druid_6__entangled:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_6__entangled:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function druid_6__entangled:PlayEfxHeal(target)
        local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)
    end