icebreaker_2_modifier_refresh = class({})

function icebreaker_2_modifier_refresh:IsHidden()
	return false
end

function icebreaker_2_modifier_refresh:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function icebreaker_2_modifier_refresh:OnCreated( kv )

	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.hits = self.ability:GetSpecialValueFor("refresh_hits")

	-- UP 2.11
	if self.ability:GetRank(11) then
		self.hits = self.hits - 2
	end

	self:SetStackCount(self.hits)
end

function icebreaker_2_modifier_refresh:OnRefresh( kv )
end

function icebreaker_2_modifier_refresh:OnRemoved()
	self.ability:SetActivated(true)
end

--------------------------------------------------------------------------------

function icebreaker_2_modifier_refresh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
	
	return funcs
end


function icebreaker_2_modifier_refresh:GetModifierProcAttack_Feedback( params )
	if self:GetStackCount() > 1 then
		self:DecrementStackCount()
	else
		self:Destroy()
	end
end