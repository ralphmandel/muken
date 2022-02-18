shadow_1_modifier_faster = class({})

--------------------------------------------------------------------------------

function shadow_1_modifier_faster:IsHidden()
	return true
end

function shadow_1_modifier_faster:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function shadow_1_modifier_faster:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = 40})
end

function shadow_1_modifier_faster:OnRefresh( kv )
end

function shadow_1_modifier_faster:OnRemoved( kv )
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

-- function shadow_1_modifier_faster:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
-- 	}

-- 	return state
-- end