genuine_1_modifier_orb = class ({})

function genuine_1_modifier_orb:IsHidden()
    return false
end

function genuine_1_modifier_orb:IsPurgable()
    return false
end

-----------------------------------------------------------

function genuine_1_modifier_orb:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.proj = false
	self.cast = false
	self.records = {}
end

function genuine_1_modifier_orb:OnRefresh(kv)
end

function genuine_1_modifier_orb:OnRemoved(kv)
end

------------------------------------------------------------

function genuine_1_modifier_orb:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_TAKEDAMAGE,

		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_PROJECTILE_NAME
	}

	return funcs
end

function genuine_1_modifier_orb:OnDeath(keys)
	if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return	end
	if keys.unit:IsIllusion() then return end

	-- UP 1.11
	if self.ability:GetRank(11) then
		local mana = 40

		if keys.unit:IsHero() then mana = 200 end

		self.parent:GiveMana(mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, mana, self.caster)
	end
end

function genuine_1_modifier_orb:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.unit:IsBuilding() then return end

	-- UP 1.22
	if self.ability:GetRank(22)
	and self.ability.spell_lifesteal == true then
		local heal = keys.original_damage * 0.2
		self.parent:Heal(heal, self.ability)
		self:PlayEfxSpellLifesteal(self.parent)
		self.ability.spell_lifesteal = false
	end
end

function genuine_1_modifier_orb:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	if self:ShouldLaunch(keys.target) and self.proj == true then
		self.ability:UseResources(true, false, true)
		self.records[keys.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire(keys) end
	end

	self.cast = false
end

function genuine_1_modifier_orb:GetModifierProcAttack_Feedback(keys)
	if self.records[keys.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact(keys) end
	end
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
		if keys.ability == self:GetAbility() then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

function genuine_1_modifier_orb:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end

	if self:ShouldLaunch(self.caster:GetAggroTarget()) then
		self.proj = true
		return self.ability:GetProjectileName()
	end

	self.proj = false
end

function genuine_1_modifier_orb:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget ~= CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget(target) == UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(
				target,
				self.ability:GetAbilityTargetTeam(),
				self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(),
				self.caster:GetTeamNumber()
			)
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end

	if self.cast and self.ability:IsFullyCastable()
	and self.parent:IsSilenced() == false then
		return true
	end

	return false
end

-----------------------------------------------------------

function genuine_1_modifier_orb:PlayEfxSpellLifesteal(target)
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end