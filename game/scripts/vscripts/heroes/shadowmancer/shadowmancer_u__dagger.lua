shadowmancer_u__dagger = class({})
LinkLuaModifier("shadowmancer_u_modifier_toxin", "heroes/shadowmancer/shadowmancer_u_modifier_toxin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadowmancer_u__dagger:CalcStatus(duration, caster, target)
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

    function shadowmancer_u__dagger:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadowmancer_u__dagger:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadowmancer_u__dagger:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function shadowmancer_u__dagger:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        self:CheckAbilityCharges(1)
    end

    function shadowmancer_u__dagger:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function shadowmancer_u__dagger:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local dagger_speed = self:GetSpecialValueFor("dagger_speed")
        local dagger_name = "particles/shadowmancer/dagger/shadowmancer_stifling_dagger_arcana_combined.vpcf"

        local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = dagger_name,
			iMoveSpeed = dagger_speed,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = 150,
			iVisionTeamNumber = caster:GetTeamNumber()
		}

        ProjectileManager:CreateTrackingProjectile(info)
		if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast") end
    end

    function shadowmancer_u__dagger:OnProjectileHit(hTarget, vLocation)
        local caster = self:GetCaster()
		if hTarget == nil then return end
		if hTarget:IsInvulnerable() then return end
		if hTarget:IsMagicImmune() then return end
		if hTarget:TriggerSpellAbsorb(self) then return end

        if IsServer() then hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target") end

        local target_toxin = hTarget:FindModifierByName("shadowmancer_u_modifier_toxin")
        if target_toxin == nil then return end

        local damage_percent = self:GetSpecialValueFor("damage_percent") * 0.01

		ApplyDamage({
			victim = hTarget,
			attacker = caster,
			damage = target_toxin:GetStackCount() * damage_percent,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})
		
		self:PlayEfxHit(hTarget)

		if hTarget:IsAlive() then
			hTarget:RemoveModifierByName("shadowmancer_u_modifier_toxin")
		else
			self:EndCooldown()
		end
	end

    function shadowmancer_u__dagger:ApplyToxin(target, amount)
        local caster = self:GetCaster()
        target:AddNewModifier(caster, self, "shadowmancer_u_modifier_toxin", {
            amount = math.floor(amount)
        })
    end

    function shadowmancer_u__dagger:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function shadowmancer_u__dagger:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function shadowmancer_u__dagger:PlayEfxHit(target)
        local particle_cast = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        AddFOWViewer(self:GetCaster():GetTeamNumber(), target:GetOrigin(), 150, 2, false)
        if IsServer() then target:EmitSound("Hero_QueenOfPain.ShadowStrike") end
    end