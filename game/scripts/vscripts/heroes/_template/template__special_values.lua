template__special_values = class({})

function template__special_values:IsHidden() return true end
function template__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function template__special_values:OnCreated(kv)
end

function template__special_values:OnRefresh(kv)
end

function template__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function template__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function template__special_values:GetModifierOverrideAbilitySpecial(keys)
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability == "template_1__sk1" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability == "template_2__sk2" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability == "template_3__sk3" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability == "template_4__sk4" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability == "template_5__sk5" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability == "template_u__sk6" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	return 0
end

function template__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability == "template_1__sk1" then
	end

	if ability == "template_2__sk2" then
	end

	if ability == "template_3__sk3" then
	end

	if ability == "template_4__sk4" then
	end

	if ability == "template_5__sk5" then
	end

	if ability == "template_u__sk6" then
	end

	return 0
end

-- UTILS -----------------------------------------------------------


-- EFFECTS -----------------------------------------------------------