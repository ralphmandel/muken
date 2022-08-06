bocuse_2__flask = class({})
LinkLuaModifier("bocuse_2_modifier_buff", "heroes/bocuse/bocuse_2_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_debuff", "heroes/bocuse/bocuse_2_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_2__flask:CalcStatus(duration, caster, target)
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

    function bocuse_2__flask:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_2__flask:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_2__flask:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function bocuse_2__flask:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bocuse_2__flask:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bocuse_2__flask:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if caster == target then
            --caster:FindModifierByName("base_hero_mod"):ChangeActivity("trapper")
            caster:StartGestureWithPlaybackRate(ACT_DOTA_VICTORY, 2)
        else
            local rand = RandomInt(1,3)
            --if rand == 1 then self.parent:AddActivityModifier("ti10_pudge") end
            if rand == 1 then caster:AddActivityModifier("") end
            if rand == 2 then caster:AddActivityModifier("ftp_dendi_back") end
            if rand == 3 then caster:AddActivityModifier("trapper") end
            caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        end

        return true
    end

    function bocuse_2__flask:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FindModifierByName("base_hero_mod"):ChangeActivity("trapper")
        caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        caster:FadeGesture(ACT_DOTA_VICTORY)
    end

    function bocuse_2__flask:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        caster:FindModifierByName("base_hero_mod"):ChangeActivity("trapper")

        if caster == target then
            Timers:CreateTimer(0.6, function()
                caster:FadeGesture(ACT_DOTA_VICTORY)
            end)
            
            self:BreakFlask(target)
            return
        end
        
        caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)

		local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			
			EffectName = "particles/bocuse/bocuse_flambee.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
			bDodgeable = true
		}

		ProjectileManager:CreateTrackingProjectile(info)
		if IsServer() then caster:EmitSound("Hero_OgreMagi.Ignite.Cast") end
    end

    function bocuse_2__flask:OnProjectileHit(hTarget, vLocation)
		if not hTarget then return end
		if hTarget:TriggerSpellAbsorb(self) then return end

		self:BreakFlask(hTarget)
	end

    function bocuse_2__flask:BreakFlask(target)
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local radius = self:GetSpecialValueFor("radius")

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(), target:GetOrigin(), nil, radius,
            DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
		)

        for _,unit in pairs(units) do
            self:PlayEfxHit(unit)
            if target:GetTeamNumber() == caster:GetTeamNumber() then
                --unit:AddNewModifier(caster, self, "bocuse_2_modifier_buff", {
                --    duration = self:CalcStatus(duration, caster, unit)
                --})
            else
                --unit:AddNewModifier(caster, self, "bocuse_2_modifier_debuff", {
                --    duration = self:CalcStatus(duration, caster, unit)
                --})
            end
        end

		self:PlayEfxImpact(target, radius)
		GridNav:DestroyTreesAroundPoint(target:GetOrigin(), radius , false)
        AddFOWViewer(caster:GetTeamNumber(), caster:GetOrigin(), radius, 1, true)
	end

    function bocuse_2__flask:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function bocuse_2__flask:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_2__flask:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function bocuse_2__flask:PlayEfxImpact(target, radius)
        local caster = self:GetCaster()
        local particle_cast = "particles/bocuse/bocuse_flambee_impact.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

        particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
        effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        if IsServer() then
            if caster == target then
                target:EmitSound("DOTA_Item.HealingSalve.Activate")
				target:EmitSound("Hero_Brewmaster.Brawler.Crit")
            else
                target:EmitSound("Hero_OgreMagi.Ignite.Target")
            end
        end
    end

    function bocuse_2__flask:PlayEfxHit(target)
        local particle_cast = "particles/bocuse/bocuse_flambee_impact_fire_ring.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
    end