bloodstained_u_modifier_hp_bonus = class({})

--------------------------------------------------------------------------------
function bloodstained_u_modifier_hp_bonus:IsPurgable()
	return false
end

function bloodstained_u_modifier_hp_bonus:IsHidden()
	return false
end

function bloodstained_u_modifier_hp_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function bloodstained_u_modifier_hp_bonus:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.bonus)
		self:StartIntervalThink(0.2)
	end
end

--------------------------------------------------------------------------------
function bloodstained_u_modifier_hp_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	}

	return funcs
end

function bloodstained_u_modifier_hp_bonus:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

function bloodstained_u_modifier_hp_bonus:OnIntervalThink()
	if IsServer() then
		self:DecrementStackCount()
		local void = self:GetParent():FindAbilityByName("_void")
		if void ~= nil then void:SetLevel(1) end
		if self:GetStackCount() < 1 then self:Destroy() end
	end
end