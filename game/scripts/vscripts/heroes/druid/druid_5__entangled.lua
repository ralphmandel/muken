druid_5__entangled = class({})
LinkLuaModifier("druid_5_modifier_entangled", "heroes/druid/druid_5_modifier_entangled", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_5__entangled:CalcStatus(duration, caster, target)
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

    function druid_5__entangled:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_5__entangled:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_5__entangled:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function druid_5__entangled:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_5__entangled:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_5__entangled:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, target)
        if target:TriggerSpellAbsorb(self) then return end
        local sound = "Hero_Treant.LeechSeed.Cast"

        target:AddNewModifier(caster, self, "druid_5_modifier_entangled", {duration = duration})

        -- UP 5.42
        if self:GetRank(42) then
            self:ApplySuperRoot(target)
            self:PlayEfxSuperRoot(target)
        end

        if caster:HasModifier("druid_4_modifier_metamorphosis") then sound = "Hero_LoneDruid.SavageRoar.Cast" end
        if IsServer() then caster:EmitSound(sound) end
    end

    function druid_5__entangled:ApplySuperRoot(target)
        local caster = self:GetCaster()
        local damageTable = {attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}

        local units = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, 600,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
        )
    
        for _,unit in pairs(units) do
            if unit ~= target then
                damageTable.damage = RandomInt(250, 350)
                damageTable.victim = unit
                ApplyDamage(damageTable)

                unit:AddNewModifier(caster, self, "_modifier_root", {
                    duration = self:CalcStatus(5, caster, unit),
                    effect = 6
                })
            end
        end
    end

    function druid_5__entangled:CreateSeedProj(target, source, leech_amount)
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
            ExtraData = {damage = leech_amount}
        })
    end

    function druid_5__entangled:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
        if not hTarget then return end
        local heal = ExtraData.damage
        local base_stats = self:GetCaster():FindAbilityByName("base_stats")
        if base_stats then heal = heal * base_stats:GetHealPower() end
        if heal < 1 then return end

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

    function druid_5__entangled:GetAOERadius()
        local radius = self:GetSpecialValueFor("radius")
        if self:GetCurrentAbilityCharges() == 0 then return radius end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return radius + 100 end
        return radius
    end

    function druid_5__entangled:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range = cast_range + 1200 end
        return cast_range
    end

    function druid_5__entangled:GetCastAnimation()
        if self:GetCurrentAbilityCharges() == 0 then return ACT_DOTA_CAST_ABILITY_4 end
        if self:GetCurrentAbilityCharges() % 5 == 0 then return ACT_DOTA_CAST_ABILITY_3 end
        return ACT_DOTA_CAST_ABILITY_4
    end

    function druid_5__entangled:GetCastPoint()
        if self:GetCurrentAbilityCharges() == 0 then return 0.3 end
        if self:GetCurrentAbilityCharges() % 5 == 0 then return 0.2 end
        return 0.3
    end

    function druid_5__entangled:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_5__entangled:CheckAbilityCharges(charges)
        -- UP 5.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        -- UP 5.41
        if self:GetRank(41) then
            charges = charges * 3
        end

        if self:GetCaster():HasModifier("druid_4_modifier_metamorphosis") then
            charges = charges * 5 --true form
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function druid_5__entangled:PlayEfxHeal(target)
        local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)
    end

    function druid_5__entangled:PlayEfxSuperRoot(target)
        local particle = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then target:EmitSound("Hero_EarthShaker.EchoSlamSmall") end
    end