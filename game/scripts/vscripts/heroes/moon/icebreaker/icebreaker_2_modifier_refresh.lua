icebreaker_2_modifier_refresh = class({})

function icebreaker_2_modifier_refresh:IsHidden() return false end
function icebreaker_2_modifier_refresh:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_2_modifier_refresh:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.ability:SetActivated(false)

	if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("recharge")) end
end

function icebreaker_2_modifier_refresh:OnRefresh(kv)
end

function icebreaker_2_modifier_refresh:OnRemoved()
	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_2_modifier_refresh:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_2_modifier_refresh:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:HasModifier("icebreaker__modifier_frozen") then return end

	if IsServer() then self:DecrementStackCount() end
end

function icebreaker_2_modifier_refresh:OnStackCountChanged(old)
	if self:GetStackCount() ~= old and self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------