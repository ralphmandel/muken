shadowmancer_3_modifier_passive = class({})

function shadowmancer_3_modifier_passive:IsHidden()
	return true
end

function shadowmancer_3_modifier_passive:IsPurgable()
	return false
end

function shadowmancer_3_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.miss = 75
end

function shadowmancer_3_modifier_passive:OnRefresh(kv)
end

function shadowmancer_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function shadowmancer_3_modifier_passive:GetModifierPreAttack(keys)
	if self.parent:IsIllusion() then return end

	local shadow_lifetime = self.ability:GetSpecialValueFor("shadow_lifetime")
	local shadow_number = self.ability:GetSpecialValueFor("shadow_number")

	if self:ShouldLaunch(keys.target) then
		self.ability:UseResources(true, false, true)
		self.ability:CreateShadow(keys.target, shadow_lifetime, shadow_number, true, self.parent:IsIllusion())
	end
end

function shadowmancer_3_modifier_passive:OnOrder(keys)
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

function shadowmancer_3_modifier_passive:ShouldLaunch(target)
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