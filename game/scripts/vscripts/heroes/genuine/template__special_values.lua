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
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "template_1__sk1" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_1__sk1_rank_11") then
		end

		if caster:FindAbilityByName("template_1__sk1_rank_21") then
		end

		if caster:FindAbilityByName("template_1__sk1_rank_31") then
		end

		if caster:FindAbilityByName("template_1__sk1_rank_41") then
		end
	end

	if ability:GetAbilityName() == "template_2__sk2" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_2__sk2_rank_11") then
		end

		if caster:FindAbilityByName("template_2__sk2_rank_21") then
		end

		if caster:FindAbilityByName("template_2__sk2_rank_31") then
		end

		if caster:FindAbilityByName("template_2__sk2_rank_41") then
		end
	end

	if ability:GetAbilityName() == "template_3__sk3" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_3__sk3_rank_11") then
		end

		if caster:FindAbilityByName("template_3__sk3_rank_21") then
		end

		if caster:FindAbilityByName("template_3__sk3_rank_31") then
		end
		
		if caster:FindAbilityByName("template_3__sk3_rank_41") then
		end
	end

	if ability:GetAbilityName() == "template_4__sk4" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_4__sk4_rank_11") then
		end

		if caster:FindAbilityByName("template_4__sk4_rank_21") then
		end

		if caster:FindAbilityByName("template_4__sk4_rank_31") then
		end

		if caster:FindAbilityByName("template_4__sk4_rank_41") then
		end
	end

	if ability:GetAbilityName() == "template_5__sk5" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_5__sk5_rank_11") then
		end

		if caster:FindAbilityByName("template_5__sk5_rank_21") then
		end

		if caster:FindAbilityByName("template_5__sk5_rank_31") then
		end

		if caster:FindAbilityByName("template_5__sk5_rank_41") then
		end
	end

	if ability:GetAbilityName() == "template_u__sk6" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("template_u__sk6_rank_11") then
		end

		if caster:FindAbilityByName("template_u__sk6_rank_21") then
		end

		if caster:FindAbilityByName("template_u__sk6_rank_31") then
		end

		if caster:FindAbilityByName("template_u__sk6_rank_41") then
		end
	end

	return 0
end

function template__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "template_1__sk1" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "template_2__sk2" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "template_3__sk3" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "template_4__sk4" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "template_5__sk5" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "template_u__sk6" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------