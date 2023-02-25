genuine_2_modifier_dispel = class({})

function genuine_2_modifier_dispel:IsHidden() return false end
function genuine_2_modifier_dispel:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_2_modifier_dispel:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.parent:Purge(true, false, false, false, false)
end

function genuine_2_modifier_dispel:OnRefresh( kv )
end

function genuine_2_modifier_dispel:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_2_modifier_dispel:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}

	return state
end

function genuine_2_modifier_dispel:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_2_modifier_dispel:GetEffectName()
	return "particles/econ/wards/ti8_ward/ti8_ward_true_sight_ambient.vpcf"
end

function genuine_2_modifier_dispel:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end