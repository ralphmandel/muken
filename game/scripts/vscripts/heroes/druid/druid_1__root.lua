druid_1__root = class({})
LinkLuaModifier("druid_1_modifier_passive", "heroes/druid/druid_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root", "heroes/druid/druid_1_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root_effect", "heroes/druid/druid_1_modifier_root_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root_damage", "heroes/druid/druid_1_modifier_root_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_1__root:CalcStatus(duration, caster, target)
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

    function druid_1__root:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_1__root:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_1__root:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function druid_1__root:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_1__root:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_1__root:GetIntrinsicModifierName()
        return "druid_1_modifier_passive"
    end

    function druid_1__root:OnAbilityPhaseStart()
        if IsServer() then
            self:GetCaster():EmitSound("Druid.Root.Cast")
            self:GetCaster():EmitSound("Hero_EarthShaker.Whoosh")
        end
        
        return true
    end

    function druid_1__root:OnAbilityPhaseInterrupted()
        if IsServer() then
            self:GetCaster():StopSound("Druid.Root.Cast")
            self:GetCaster():StopSound("Hero_EarthShaker.Whoosh")
        end
    end

    function druid_1__root:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        self.origin = caster:GetOrigin()
        self.location = nil

        local name = ""
        local distance = self:GetCastRange(point, nil)
        local radius = self:GetSpecialValueFor("radius")
        local speed = self:GetSpecialValueFor("speed")
        local direction = point - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            bDeleteOnHit = true,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = 0,
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

    function druid_1__root:OnProjectileThink(vLocation)
        if self.location == nil then self.location = vLocation end

        local distance = (vLocation - self.location):Length2D()
        local radius = self:GetSpecialValueFor("radius")
        local bonus_duration = ((vLocation - self.origin):Length2D() / 300) - RandomFloat(0, 3)
        local bramble_duration = self:GetSpecialValueFor("bramble_duration") + bonus_duration

        if distance >= radius / 3 then
            self:CreateBush(self:RandomizeLocation(self.origin, vLocation, radius), bramble_duration, 1)
            self.location = vLocation
        end
    end

    function druid_1__root:RandomizeLocation(origin, point, radius)
        local distance = RandomInt(-radius, radius)
        local cross = CrossVectors(origin - point, Vector(0, 0, 1)):Normalized() * distance
        return point + cross
    end

    function druid_1__root:CreateBush(point, duration, type)
        local caster = self:GetCaster()
        CreateModifierThinker(
            caster, self, "druid_1_modifier_root", {duration = duration, type = type}, point, caster:GetTeamNumber(), false
        )
    end

    function druid_1__root:GetCastRange(vLocation, hTarget)
        local distance = self:GetSpecialValueFor("distance")
        return distance
    end

    function druid_1__root:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_1__root:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function druid_1__root:PlayEfxStart()
        local caster = self:GetCaster()
        local string = "particles/druid/druid_skill2_overgrowth.vpcf"
        local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())

        if IsServer() then caster:EmitSound("Hero_EarthShaker.EchoSlamSmall") end
    end