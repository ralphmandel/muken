genuine_5_modifier_charges = class({})

function genuine_5_modifier_charges:IsHidden()
	return false
end

function genuine_5_modifier_charges:IsPurgable()
	return false
end

function genuine_5_modifier_charges:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_charges:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.recharge_time = self.ability:GetSpecialValueFor("recharge_time")
	self.ability.charges = self.ability:GetSpecialValueFor("charges")

	if IsServer() then self:SetStackCount(self.ability.charges) end
end

function genuine_5_modifier_charges:OnRefresh(kv)
end

function genuine_5_modifier_charges:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_charges:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}

	return funcs
end

function genuine_5_modifier_charges:OnDeath(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
    if keys.attacker ~= self.parent then return end
    if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsIllusion() then return end
	if keys.inflictor == nil then return end
	if keys.inflictor ~= self.ability then return end

	-- UP 5.11
	if self.ability:GetRank(11) then
		local mana = 50
		if keys.unit:IsHero() then mana = 200 end
		self.parent:GiveMana(mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, mana, self.caster)
	end
end

function genuine_5_modifier_charges:OnAbilityExecuted(keys)
	if keys.unit == nil then return end
	if keys.unit ~= self.parent then return end
	if keys.ability == nil then return end
	if keys.ability:GetAbilityName() ~= self.ability:GetAbilityName() then return end

	Timers:CreateTimer((0.1), function()
		if self.ability ~= nil then
			if IsValidEntity(self.ability) then
				self.ability:EndCooldown()
				self:DecrementStackCount()
			end
		end
	end)

	self.parent:AddNewModifier(self.caster, self.ability, "genuine_5_modifier_recharge", {duration = self.recharge_time})
end

function genuine_5_modifier_charges:OnStackCountChanged(keys)
	self.ability:SetActivated(self:GetStackCount() > 0)
end

-- function genuine_5_modifier_charges:OnIntervalThink()
-- 	self:SetStackCount(self.ability.charges)
-- 	self:StartIntervalThink(-1)
-- end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------