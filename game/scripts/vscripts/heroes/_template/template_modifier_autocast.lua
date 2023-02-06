template_modifier_autocast = class({})

function template_modifier_autocast:IsHidden() return true end
function template_modifier_autocast:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function template_modifier_autocast:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function template_modifier_autocast:OnRefresh(kv)
end

function template_modifier_autocast:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function template_modifier_autocast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function template_modifier_autocast:OnAttackLanded(keys)
	if self.parent:IsIllusion() then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self:ShouldLaunch(keys.target) then
		self.ability:UseResources(true, false, true)
	end
end

function template_modifier_autocast:OnOrder(keys)
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

function template_modifier_autocast:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
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

	if self.cast and self.ability:IsFullyCastable()
	and self.parent:IsSilenced() == false then
		return true
	end

	return false
end

-- EFFECTS -----------------------------------------------------------