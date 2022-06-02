shadow_3_modifier_walk_cosmetic = class({})

function shadow_3_modifier_walk_cosmetic:IsHidden()
	return true
end

function shadow_3_modifier_walk_cosmetic:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_3_modifier_walk_cosmetic:OnCreated(kv)
end

function shadow_3_modifier_walk_cosmetic:OnRefresh(kv)
end

function shadow_3_modifier_walk_cosmetic:OnRemoved()
end

-----------------------------------------------------------

function shadow_3_modifier_walk_cosmetic:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

function shadow_3_modifier_walk_cosmetic:GetModifierInvisibilityLevel()
	return 1
end

-----------------------------------------------------------

-- function shadow_3_modifier_walk_cosmetic:GetEffectName()
-- 	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_active_blur.vpcf"
-- end

-- function shadow_3_modifier_walk_cosmetic:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end