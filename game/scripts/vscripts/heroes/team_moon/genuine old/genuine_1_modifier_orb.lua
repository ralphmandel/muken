genuine_1_modifier_orb = class ({})

function genuine_1_modifier_orb:IsHidden() return false end
function genuine_1_modifier_orb:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_1_modifier_orb:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
	self.cast = false
	self.records = {}
end

function genuine_1_modifier_orb:OnRefresh(kv)
  RemoveBonus(self.ability, "_2_LCK", self.parent)
  AddBonus(self.ability, "_2_LCK", self.parent, self.ability:GetSpecialValueFor("special_lck"), 0, nil)
end

function genuine_1_modifier_orb:OnRemoved(kv)
  RemoveBonus(self.ability, "_2_LCK", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_1_modifier_orb:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function genuine_1_modifier_orb:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end

	if self:ShouldLaunch(self.caster:GetAggroTarget()) then
		return self.ability:GetProjectileName()
	end
end

function genuine_1_modifier_orb:GetModifierAttackRangeBonus(keys)
	if self:ShouldLaunch(self.caster:GetAggroTarget()) then
		return self.ability:GetSpecialValueFor("atk_range")
	end

	return 0
end

function genuine_1_modifier_orb:GetModifierProjectileSpeedBonus(keys)
	if self:ShouldLaunch(self.caster:GetAggroTarget()) then
		return self.ability:GetSpecialValueFor("proj_speed")
	end

	return 0
end

function genuine_1_modifier_orb:GetModifierProcAttack_Feedback(keys)
	if self.records[keys.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact(keys) end
	end
end

function genuine_1_modifier_orb:OnTakeDamage(keys)
	if keys.inflictor ~= self.ability then return end
  if keys.damage_type ~= self.ability:GetAbilityDamageType() then return end

	local heal = keys.original_damage * self.ability:GetSpecialValueFor("special_spell_lifesteal") * 0.01

	if heal > 0 then
		self.parent:Heal(heal, self.ability)
		self:PlayEfxSpellLifesteal()
	end
end

function genuine_1_modifier_orb:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	if self:ShouldLaunch(keys.target) then
		self.ability:UseResources(true, false, false, false)
		self.records[keys.record] = true

		if self.ability.OnOrbFire then self.ability:OnOrbFire(keys) end
	end

	self.cast = false
end

function genuine_1_modifier_orb:OnAttackFail(keys)
	if self.records[keys.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail(keys) end
	end
end

function genuine_1_modifier_orb:OnAttackRecordDestroy(keys)
	self.records[keys.record] = nil
end

function genuine_1_modifier_orb:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.ability then
		if keys.ability == self:GetAbility() and keys.order_type == 6 then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

-- UTILS -----------------------------------------------------------

function genuine_1_modifier_orb:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
		local nResult = UnitFilter(
			target, self.ability:GetAbilityTargetTeam(),
			self.ability:GetAbilityTargetType(),
			self.ability:GetAbilityTargetFlags(),
			self.caster:GetTeamNumber()
		)

		if nResult == UF_SUCCESS then
			self.cast = true
		end
	end

	if self.cast and self.parent:IsSilenced() == false
  and self.parent:GetMana() >= self.ability:GetManaCost(self.ability:GetLevel()) then
		return true
	end

	return false
end

-- EFFECTS -----------------------------------------------------------

function genuine_1_modifier_orb:PlayEfxSpellLifesteal()
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end