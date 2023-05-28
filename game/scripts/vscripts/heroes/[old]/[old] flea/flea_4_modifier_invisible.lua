flea_4_modifier_invisible = class({})

function flea_4_modifier_invisible:IsHidden() return true end
function flea_4_modifier_invisible:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_invisible:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:AddNewModifier(nil, "flea_4_modifier_invisible") end
end

function flea_4_modifier_invisible:OnRefresh(kv)
end

function flea_4_modifier_invisible:OnRemoved()
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:RemoveModifierByName(nil, "flea_4_modifier_invisible") end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_invisible:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------