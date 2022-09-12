druid_2__armor = class({})
LinkLuaModifier("druid_2_modifier_armor", "heroes/druid/druid_2_modifier_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_2__armor:CalcStatus(duration, caster, target)
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

    function druid_2__armor:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_2__armor:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_2__armor:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function druid_2__armor:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_2__armor:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_2__armor:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        caster:FindModifierByName("base_hero_mod"):ChangeActivity("suffer")
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
        return true
    end

    function druid_2__armor:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FindModifierByName("base_hero_mod"):ChangeActivity("")
        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    end

    function druid_2__armor:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")
        caster:FindModifierByName("base_hero_mod"):ChangeActivity("")

        target:AddNewModifier(caster, self, "druid_2_modifier_armor", {
            duration = self:CalcStatus(duration, caster, target)
        })

        if IsServer() then
            caster:EmitSound("Hero_Treant.LivingArmor.Cast")
            target:EmitSound("Hero_Treant.LivingArmor.Target")
        end
    end

    function druid_2__armor:CreateSeedProj(target, source, heal)
        if IsServer() then source:EmitSound("Hero_Treant.LeechSeed.Tick") end

        ProjectileManager:CreateTrackingProjectile({
            Target = target,
            Source = source,
            Ability = self,	
            EffectName = "particles/druid/druid_ult_projectile.vpcf",
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            iMoveSpeed = 250,
            bReplaceExisting = false,
            bProvidesVision = true,
            iVisionRadius = 75,
            iVisionTeamNumber = target:GetTeamNumber(),
            ExtraData = {damage = heal}
        })
    end

    function druid_2__armor:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
        if not hTarget then return end
        local heal = ExtraData.damage

        local lotus_mod = hTarget:FindModifierByName("druid_3_modifier_totem")
        if lotus_mod then
            if lotus_mod.min_health < hTarget:GetMaxHealth() then
                lotus_mod.disable_heal = 0
                lotus_mod.min_health = lotus_mod.min_health + 1

                hTarget:Heal(1, self)
                self:PlayEfxHeal(hTarget)

                lotus_mod.disable_heal = 1
            end
            return
        end

        hTarget:Heal(heal, self)
        self:PlayEfxHeal(hTarget)
    end

    function druid_2__armor:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_2__armor:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function druid_2__armor:PlayEfxHeal(target)
        local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)
    end