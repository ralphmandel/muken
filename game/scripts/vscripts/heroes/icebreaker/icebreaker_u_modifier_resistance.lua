icebreaker_u_modifier_resistance = class({})

function icebreaker_u_modifier_resistance:IsHidden()
	return true
end

function icebreaker_u_modifier_resistance:IsPurgable()
    return false
end

function icebreaker_u_modifier_resistance:IsDebuff()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return true
	end
	return false
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_resistance:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local resistance = 30
	if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then resistance = -resistance end
	self.ability:AddBonus("_2_RES", self.parent, resistance, 0, nil)
end

function icebreaker_u_modifier_resistance:OnRefresh( kv )
end

function icebreaker_u_modifier_resistance:OnRemoved()
	self.ability:RemoveBonus("_2_RES", self.parent)
end