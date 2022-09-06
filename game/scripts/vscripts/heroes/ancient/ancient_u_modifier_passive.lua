ancient_u_modifier_passive = class({})

function ancient_u_modifier_passive:IsHidden()
	return true
end

function ancient_u_modifier_passive:IsPurgable()
	return false
end

function ancient_u_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local energy_loss = self.ability:GetSpecialValueFor("energy_loss")
	if IsServer() then self:StartIntervalThink(1 / energy_loss) end
end

function ancient_u_modifier_passive:OnRefresh(kv)
end

function ancient_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function ancient_u_modifier_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:PassivesDisabled() then return end

	self.ability:AddEnergy(keys.inflictor)
end

function ancient_u_modifier_passive:OnIntervalThink()
	self.parent:ReduceMana(1)
	self.ability:UpdateResistance()

	local energy_loss = self.ability:GetSpecialValueFor("energy_loss")
	if IsServer() then self:StartIntervalThink(1 / energy_loss) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------