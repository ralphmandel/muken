druid_u__seed = class({})
LinkLuaModifier("druid_u_modifier_aura", "heroes/druid/druid_u_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_aura_effect", "heroes/druid/druid_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_u__seed:CalcStatus(duration, caster, target)
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

    function druid_u__seed:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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

        -- UP 4.31
        if self:GetRank(31) then
            self.regeneration = 25
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function druid_u__seed:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.regeneration = 0
    end

-- SPELL START

    function druid_u__seed:GetIntrinsicModifierName()
        return "druid_u_modifier_aura"
    end

    function druid_u__seed:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
        if not hTarget then return end
        if hTarget:IsInvulnerable() then return end
        local source = EntIndexToHScript(ExtraData.source)
        local damage = ExtraData.damage

        local caster = self:GetCaster()
        local seed_heal = self:GetSpecialValueFor("seed_heal")

        -- UP 4.32
        if self:GetRank(32) then
            seed_heal = seed_heal + 50
        end

        local base_stats = caster:FindModifierByName("base_stats")
        if base_stats then seed_heal = seed_heal * base_stats:GetHealPower() end

        if source:GetTeamNumber() ~= caster:GetTeamNumber() then
            seed_heal = damage * 0.2
            local base_stats = caster:FindAbilityByName("base_stats")
            if base_stats then seed_heal = seed_heal * (1 + base_stats:GetSpellAmp()) end
        end

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
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then target:EmitSound("Druid.Seed.Heal") end
    end