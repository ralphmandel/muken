flea_4_modifier_hidden = class({})

function flea_4_modifier_hidden:IsHidden()
	return true
end

function flea_4_modifier_hidden:IsPurgable()
	return true
end

function flea_4_modifier_hidden:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_hidden:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then
		for i = 1, #cosmetics.cosmetic, 1 do
			local invi_cosmetic = cosmetics.cosmetic[i]:AddNewModifier(
				self:GetParent(), self:GetAbility(), "flea_4_modifier_hidden", {}
			)
		end
	end
end

function flea_4_modifier_hidden:OnRefresh(kv)
end

function flea_4_modifier_hidden:OnRemoved()
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then
		for i = 1, #cosmetics.cosmetic, 1 do
			local mod = cosmetics.cosmetic[i]:FindAllModifiersByName("flea_4_modifier_hidden")
			for _,modifier in pairs(mod) do
				if modifier:GetAbility() == self:GetAbility() then modifier:Destroy() end
			end
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_hidden:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------