druid_2__root = class({})
LinkLuaModifier("druid_2_modifier_aura", "heroes/druid/druid_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_aura_effect", "heroes/druid/druid_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_2__root:CalcStatus(duration, caster, target)
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

    function druid_2__root:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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

    function druid_2__root:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        self.origin = caster:GetOrigin()

        local name = ""
        local distance = self:GetCastRange(point, nil)
        local radius = self:GetAOERadius()
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
            bProvidesVision = true,
            iVisionRadius = radius + 50,
            iVisionTeamNumber = caster:GetTeamNumber()
        }

        ProjectileManager:CreateLinearProjectile(info)
    end

    function druid_2__root:OnProjectileThink(vLocation)
        local caster = self:GetCaster()
        local grasp_duration = self:GetSpecialValueFor("grasp_duration")
        local distance = 50

        if self.location == nil then
            self.location = vLocation
        else
            distance = (vLocation - self.location):Length2D()
        end

        if distance >= 50 then
            CreateModifierThinker(
                caster, self, "druid_2_modifier_aura", {duration = grasp_duration},
                self:RandomizeLocation(vLocation), caster:GetTeamNumber(), false
            )
            self.location = vLocation
        end
    end

    function druid_2__root:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("distance")
    end

    function druid_2__root:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_2__root:RandomizeLocation(point)
        local distance = RandomInt(-100, 100)
        local cross = CrossVectors(self.origin - point, Vector(0, 0, 1)):Normalized() * distance
        return point + cross
    end

-- EFFECTS