genuine_1_modifier_orb = class ({})

function genuine_1_modifier_orb:IsHidden()
    return false
end

function genuine_1_modifier_orb:IsPurgable()
    return false
end

-----------------------------------------------------------

function genuine_1_modifier_orb:OnCreated(kv)
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()

		self.atk_range = self.ability:GetSpecialValueFor("atk_range")
		
		self.proj = false
		self.cast = false
		self.pierce_records = {}
		self.records = {}
	end
end

function genuine_1_modifier_orb:OnRefresh(kv)
	self.atk_range = self.ability:GetSpecialValueFor("atk_range")
end

function genuine_1_modifier_orb:OnRemoved(kv)
end

------------------------------------------------------------

function genuine_1_modifier_orb:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_TAKEDAMAGE,

		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
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
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
    if keys.attacker ~= self.parent then return end
    if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsIllusion() then return end

	-- UP 1.11
	if self.ability:GetRank(11) then
		local mana = 50

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
		local heal = keys.original_damage * 0.5
		self.parent:Heal(heal, self.ability)
		self:PlayEfxSpellLifesteal(self.parent)
		self.ability.spell_lifesteal = false
	end
end

function genuine_1_modifier_orb:GetModifierAttackRangeBonus(keys)
	if self:GetAbility():IsCooldownReady()
	and self:GetAbility():GetAutoCastState() then
		return self.atk_range
	end
	
	return 0
end

function genuine_1_modifier_orb:GetModifierProjectileSpeedBonus(keys)
	local chance = 40
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	-- UP 1.32
	if self.ability:GetRank(32)
	and RandomFloat(1, 100) <= chance then
		self.proj = self:ShouldLaunch(self.caster:GetAggroTarget(), true)

		if self.proj then
			self.pierce_records[keys.record] = true
			return 1200
		end
		                                                                                                                                                                                                                                                                                                                                                                                              
		return 0
	end

	self.proj = self:ShouldLaunch(self.caster:GetAggroTarget(), false)
	return 0
end

function genuine_1_modifier_orb:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	if self.proj == true then
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
	if self.pierce_records[keys.record] then
		self.parent:PerformAttack(keys.target, true, true, true, true, false, false, true)
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact(keys) end
		return
	end

	if self.records[keys.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail(keys) end
	end
end

function genuine_1_modifier_orb:OnAttackRecordDestroy(keys)
	self.records[keys.record] = nil
	self.pierce_records[keys.record] = nil
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

	if self.proj == true then
		return self.ability:GetProjectileName()
	end
end

function genuine_1_modifier_orb:ShouldLaunch(target, pierce)
	if self.ability:GetAutoCastState() then
		local flags = self.ability:GetAbilityTargetFlags()
		if pierce then flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

		local nResult = UnitFilter(
			target,
			self.ability:GetAbilityTargetTeam(),
			self.ability:GetAbilityTargetType(),
			flags,
			self.caster:GetTeamNumber()
		)
		if nResult == UF_SUCCESS then
			if self.parent:HasModifier("genuine_u_modifier_caster") then
				if target:HasModifier("genuine_u_modifier_target") then
					self.cast = true
				end
			else
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