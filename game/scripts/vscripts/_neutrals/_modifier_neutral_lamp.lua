_modifier_neutral_lamp = class({})

function _modifier_neutral_lamp:IsHidden()
	return true
end

function _modifier_neutral_lamp:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_lamp:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.take_damage = 0
	self:StartIntervalThink(1)
	--self.spot = kv.spot
end

function _modifier_neutral_lamp:OnRefresh( kv )
end

function _modifier_neutral_lamp:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_lamp:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function _modifier_neutral_lamp:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	--if keys.attacker == nil then return end
	--if keys.attacker:IsBaseNPC() == false then return end
	self.take_damage = self.take_damage + (keys.damage * 0.5)
end

function _modifier_neutral_lamp:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	--if self.parent:IsStunned() then return end
	if self.parent:IsDominated() then return end

	self.take_damage = self.take_damage - 20
	if self.take_damage < 0 then self.take_damage = 0 end

	if RandomFloat(0, 100) < self.take_damage then
		self:TryCast_Skill_1(target)
		return
	end
end

function _modifier_neutral_lamp:TryCast_Skill_1(target)
	local ability = self.parent:FindAbilityByName("spike_armor")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	self.take_damage = 0
	ability:CastAbility()
end