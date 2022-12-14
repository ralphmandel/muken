flea_2_modifier_passive = class({})

function flea_2_modifier_passive:IsHidden() return false end
function flea_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.ability.origin = self:GetParent():GetOrigin()
	self.energy = 0

	if IsServer() then self:StartIntervalThink(0.1) end
end

function flea_2_modifier_passive:OnRefresh(kv)
end

function flea_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_2_modifier_passive:GetModifierMoveSpeed_AbsoluteMin()
	if IsServer() then
		if self:GetParent():PassivesDisabled() == false then
			local min_speed = self:GetAbility():GetSpecialValueFor("min_speed")
			if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then min_speed = min_speed + 75 end
			return min_speed
		end

		return 0
	end
end

function flea_2_modifier_passive:GetModifierConstantHealthRegen()
	if IsServer() then
		if self:GetParent():PassivesDisabled() == false then
			local min_speed = self:GetAbility():GetSpecialValueFor("min_speed")
			local regen = self:GetAbility():GetSpecialValueFor("regen") * 0.01
			if self:GetAbility():GetCurrentAbilityCharges() % 3 == 0 then regen = regen * 1.5 end
			return (self:GetParent():GetIdealSpeed() - min_speed - 50) * regen
		end

		return 0
	end
end

function flea_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	self.parent:AddNewModifier(self.caster, self.ability, "flea_2_modifier_speed", {
		duration = CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)
	})

	if self:GetStackCount() == 100 then
		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(3, self.caster, keys.target)
		})

		self.energy = 0
	end
end

function flea_2_modifier_passive:OnIntervalThink()
	local distance = (self.ability.origin - self.parent:GetOrigin()):Length2D()
	self.ability.origin = self.parent:GetOrigin()

	if self.ability:GetSpecialValueFor("special_charge") then
		self.energy = self.energy + distance
		if self.energy > 4000 then self.energy = 4000 end
	end

	if IsServer() then
		self:SetStackCount(math.floor(self.energy * 0.025))
		self:StartIntervalThink(0.1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------