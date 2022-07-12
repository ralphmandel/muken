icebreaker_4_modifier_passive = class({})

function icebreaker_4_modifier_passive:IsHidden()
	return true
end

function icebreaker_4_modifier_passive:IsPurgable()
	return false
end

function icebreaker_4_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_4_modifier_passive:OnRefresh(kv)
end

function icebreaker_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function icebreaker_4_modifier_passive:OnAttackLanded(keys)
	if self.parent:IsIllusion() then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self:ShouldLaunch(keys.target) then
		self.ability:UseResources(true, false, true)
		self.ability:CreateMirrors(keys.target, 1)
	end
end

function icebreaker_4_modifier_passive:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.ability then
		if keys.ability == self:GetAbility() then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

-- UTILS -----------------------------------------------------------

function icebreaker_4_modifier_passive:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
		local flags = self.ability:GetAbilityTargetFlags()

		local nResult = UnitFilter(
			target,
			self.ability:GetAbilityTargetTeam(),
			self.ability:GetAbilityTargetType(),
			flags,
			self.caster:GetTeamNumber()
		)
		if nResult == UF_SUCCESS then
			self.cast = true
		end
	end

	if self.cast and self.ability:IsFullyCastable()
	and self.parent:IsSilenced() == false then
		return true
	end

	return false
end

-- EFFECTS -----------------------------------------------------------