icebreaker_4_modifier_recharge = class({})

function icebreaker_4_modifier_recharge:IsHidden()
	return false
end

function icebreaker_4_modifier_recharge:IsPurgable()
	return false
end

function icebreaker_4_modifier_recharge:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_4_modifier_recharge:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function icebreaker_4_modifier_recharge:OnRefresh(kv)
end

function icebreaker_4_modifier_recharge:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_4_modifier_recharge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}

	return funcs
end

function icebreaker_4_modifier_recharge:OnAbilityExecuted(keys)
	if keys.unit == nil then return end
	if keys.unit ~= self.parent then return end
	if keys.ability == nil then return end
	if keys.ability:GetAbilityName() ~= self.ability:GetAbilityName() then return end

	local recharge = self.ability:GetSpecialValueFor("recharge")

	-- UP 4.31
	if self.ability:GetRank(31) then
		recharge = recharge - 2
	end

	self.ability:SetActivated(false)
	self:SetStackCount(recharge)
end

function icebreaker_4_modifier_recharge:OnStackCountChanged(old)
	if self:GetStackCount() < 0 then self:SetStackCount(0) end
	if self:GetStackCount() < 1 then self.ability:SetActivated(true) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------