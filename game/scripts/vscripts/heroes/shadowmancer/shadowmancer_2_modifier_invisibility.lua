shadowmancer_2_modifier_invisibility = class({})

function shadowmancer_2_modifier_invisibility:IsHidden()
	return true
end

function shadowmancer_2_modifier_invisibility:IsPurgable()
	return true
end

function shadowmancer_2_modifier_invisibility:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_2_modifier_invisibility:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then
		for i = 1, #cosmetics.cosmetic, 1 do
			local invi_cosmetic = cosmetics.cosmetic[i]:AddNewModifier(
				self:GetParent(), self:GetAbility(), "shadowmancer_2_modifier_invisibility", {}
			)
		end
	end
end

function shadowmancer_2_modifier_invisibility:OnRefresh(kv)
end

function shadowmancer_2_modifier_invisibility:OnRemoved()
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then
		for i = 1, #cosmetics.cosmetic, 1 do
			local mod = cosmetics.cosmetic[i]:FindAllModifiersByName("shadowmancer_2_modifier_invisibility")
			for _,modifier in pairs(mod) do
				if modifier:GetAbility() == self:GetAbility() then modifier:Destroy() end
			end
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_2_modifier_invisibility:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------