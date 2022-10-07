osiris_2__wave = class({})
LinkLuaModifier("osiris_2_modifier_wave", "heroes/osiris/osiris_2_modifier_wave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function osiris_2__wave:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function osiris_2__wave:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function osiris_2__wave:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function osiris_2__wave:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function osiris_2__wave:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function osiris_2__wave:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function osiris_2__wave:OnAbilityPhaseStart()
        if not self:CheckVectorTargetPosition() then return false end
        return true
    end

    function osiris_2__wave:OnSpellStart()
        local caster = self:GetCaster()
        local vect_targets = self:GetVectorTargetPosition()
        local direction = vect_targets.direction
        local init_pos = vect_targets.init_pos
        local end_pos = vect_targets.end_pos

        caster:SetForwardVector(direction)
        self:CreateWave(caster, init_pos, direction)
    end

    function osiris_2__wave:CreateWave(caster, origin, direction)
        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = origin,
            
            bDeleteOnHit = false,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = "particles/osiris/osiris_grit_wave.vpcf",
            fDistance = 1000,
            fStartRadius = 100,
            fEndRadius = 100,
            vVelocity = direction * 500,
        
            bReplaceExisting = false,
            
            bProvidesVision = true,
            iVisionRadius = 150,
            iVisionTeamNumber = caster:GetTeamNumber(),
        }
        self.projectile = ProjectileManager:CreateLinearProjectile(info)
    end

    function osiris_2__wave:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function osiris_2__wave:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS