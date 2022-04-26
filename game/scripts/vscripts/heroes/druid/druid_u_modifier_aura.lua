druid_u_modifier_aura = class({})

function druid_u_modifier_aura:IsHidden()
	return true
end

function druid_u_modifier_aura:IsPurgable()
	return false
end

function druid_u_modifier_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function druid_u_modifier_aura:GetModifierAura()
	return "druid_u_modifier_aura_effect"
end

function druid_u_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function druid_u_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_u_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

--------------------------------------------------------------------------------

function druid_u_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.extra_hp = 0
	self.heal_amp = self.ability:GetSpecialValueFor("heal_amp")

	if IsServer() then
		self:PlayEfxStart()
	end
end

function druid_u_modifier_aura:OnRefresh(kv)
	-- UP 4.11
	if self.ability:GetRank(11) then
		self.ability:RemoveBonus("_2_DEX", self.parent)
		self.ability:AddBonus("_2_DEX", self.parent, 7, 0, nil)
	end

	-- UP 4.12
	if self.ability:GetRank(12) then
		self.extra_hp = 200
	end

	-- UP 4.41
	if self.ability:GetRank(41) then
		self.damageTable = {
			--victim = target,
			attacker = self.caster,
			damage = 50,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
		self.info = {
			Target = self.caster,
			--Source = self.parent,
			Ability = self.ability,	
			EffectName = "particles/druid/druid_ult_projectile.vpcf",
			iMoveSpeed = self.ability:GetSpecialValueFor("seed_speed"),
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = 100,
			iVisionTeamNumber = self.caster:GetTeamNumber()
		}
		if IsServer() then self:StartIntervalThink(2.5) end
	end
end

function druid_u_modifier_aura:OnRemoved()
	self.ability:RemoveBonus("_2_DEX", self.parent)
end

--------------------------------------------------------------------------------

function druid_u_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function druid_u_modifier_aura:GetModifierExtraHealthBonus()
    return self.extra_hp
end

function druid_u_modifier_aura:GetModifierHealAmplify_PercentageTarget()
    return self.heal_amp
end

function druid_u_modifier_aura:OnAttacked(keys)
	if keys.attacker == self.parent then return end
	if keys.attacker:HasModifier("druid_u_modifier_aura_effect") == false then return end
	local heal = keys.original_damage * 0.05

	-- UP 4.21
	if self.ability:GetRank(21) then
		if heal >= 1 then
			keys.attacker:Heal(heal, nil)
			self:PlayEfxLifesteal(keys.attacker)
		end
		heal = heal * 0.5
		if heal >= 1 then
			self.parent:Heal(heal, nil)
			self:PlayEfxLifesteal(self.parent)
		end
	end
end

function druid_u_modifier_aura:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false
	)

	local count = 0

	for _,enemy in pairs(enemies) do
		count = count + 1
		if RandomInt(1, count) == 1 then
			self.info.Source = enemy
			self.info.ExtraData = {damage = self.damageTable.damage, source = enemy:entindex()}
			ProjectileManager:CreateTrackingProjectile(self.info)

			self.damageTable.victim = enemy
			ApplyDamage(self.damageTable)

			self:PlayEfxReverseSeed(enemy)
		end
	end
end

--------------------------------------------------------------------------------

function druid_u_modifier_aura:PlayEfxStart()
	local string = "particles/druid/druid_ult_passive.vpcf"
	local effect_aura = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_aura, 0, self.parent:GetOrigin())
	self:AddParticle(effect_aura, false, false, -1, false, false)
end

function druid_u_modifier_aura:PlayEfxLifesteal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end

function druid_u_modifier_aura:PlayEfxReverseSeed(target)
	local particle = "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	if IsServer() then target:EmitSound("Hero_Treant.LeechSeed.Tick") end
end