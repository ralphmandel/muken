druid_2__root = class({})
LinkLuaModifier("druid_2_modifier_passive", "heroes/druid/druid_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_aura", "heroes/druid/druid_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_aura_effect", "heroes/druid/druid_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_armor", "heroes/druid/druid_2_modifier_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_2__root:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
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
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function druid_2__root:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_2__root:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_2__root:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("druid__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        return att.talents[2][upgrade]
    end

    function druid_2__root:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local att = caster:FindAbilityByName("druid__attributes")
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

    function druid_2__root:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function druid_2__root:GetIntrinsicModifierName()
        return "druid_2_modifier_passive"
    end

    function druid_2__root:OnAbilityPhaseStart()
        if IsServer() then
            self:GetCaster():EmitSound("Druid.Root.Cast")
            self:GetCaster():EmitSound("Hero_EarthShaker.Whoosh")
        end
        return true
    end

    function druid_2__root:OnAbilityPhaseInterrupted()
        if IsServer() then
            self:GetCaster():StopSound("Druid.Root.Cast")
            self:GetCaster():StopSound("Hero_EarthShaker.Whoosh")
        end
    end

    function druid_2__root:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        self.origin = caster:GetOrigin()
        self.bramble_duration = self:GetSpecialValueFor("bramble_duration")
        self.location = nil

        local name = ""
        local distance = self:GetCastRange(point, nil)
        local radius = self:GetAOERadius()
        local speed = self:GetSpecialValueFor("speed")
        local flag = DOTA_UNIT_TARGET_FLAG_NONE

        local direction = point - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()

        -- UP 2.11
        if self:GetRank(11) then
            speed = speed + 800
        end

        -- UP 2.41
        if self:GetRank(41) then
            self.bramble_duration = self.bramble_duration + 10
        end

        -- UP 2.42
        if self:GetRank(42) then
            local damageTable = {
                --victim = target,
                attacker = caster,
                damage = RandomInt(150, 175),
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }

            local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), caster:GetOrigin(), nil, 500,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                16, 0, false
            )
    
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(caster, self, "_modifier_root", {
                    duration = self:CalcStatus(2, caster, enemy),
                    effect = 6
                })
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end
        end

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
            iVisionRadius = radius + 50,
            iVisionTeamNumber = caster:GetTeamNumber()
        }

        ProjectileManager:CreateLinearProjectile(info)
        self:PlayEfxStart()
    end

    function druid_2__root:OnProjectileThink(vLocation)
        local caster = self:GetCaster()

        if self.location == nil then
            self.location = vLocation
        end

        local distance = (vLocation - self.location):Length2D()

        if distance >= self:GetAOERadius() / 3 then
            CreateModifierThinker(
                caster, self, "druid_2_modifier_aura", {duration = self.bramble_duration},
                self:RandomizeLocation(vLocation), caster:GetTeamNumber(), false
            )
            self.location = vLocation

            -- UP 2.21
            if self:GetRank(21) then
                local allies = FindUnitsInRadius(
                    caster:GetTeamNumber(), vLocation, nil, self:GetAOERadius(),
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    0, 0, false
                )
        
                for _,ally in pairs(allies) do
                    ally:AddNewModifier(caster, self, "druid_2_modifier_armor", {
                        duration = self:CalcStatus(5, caster, ally)
                    })
                end
            end
        end
    end

    function druid_2__root:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("distance")
    end

    function druid_2__root:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_2__root:RandomizeLocation(point)
        local distance = RandomInt(-self:GetAOERadius(), self:GetAOERadius())
        local cross = CrossVectors(self.origin - point, Vector(0, 0, 1)):Normalized() * distance
        return point + cross
    end

-- EFFECTS

    function druid_2__root:PlayEfxStart()
        local caster = self:GetCaster()
        local string = "particles/druid/druid_skill2_overgrowth.vpcf"

        -- UP 2.42
        if self:GetRank(42) then
            string = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf"
        end

        local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        if IsServer() then caster:EmitSound("Hero_EarthShaker.EchoSlamSmall") end
    end