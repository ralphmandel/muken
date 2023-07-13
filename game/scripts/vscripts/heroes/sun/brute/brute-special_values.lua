brute_special_values = class({})

function brute_special_values:IsHidden() return true end
function brute_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function brute_special_values:OnCreated(kv)
end

function brute_special_values:OnRefresh(kv)
end

function brute_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function brute_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function brute_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "brute_1__spin" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "spin_interval" then return 1 end

		if caster:FindAbilityByName("brute_1__spin_rank_11") then
		end

    if caster:FindAbilityByName("brute_1__spin_rank_12") then
		end

		if caster:FindAbilityByName("brute_1__spin_rank_21") then
		end

    if caster:FindAbilityByName("brute_1__spin_rank_22") then
		end

		if caster:FindAbilityByName("brute_1__spin_rank_31") then
		end

    if caster:FindAbilityByName("brute_1__spin_rank_32") then
		end

		if caster:FindAbilityByName("brute_1__spin_rank_41") then
		end

    if caster:FindAbilityByName("brute_1__spin_rank_42") then
		end
	end

	if ability:GetAbilityName() == "brute_2__rage" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("brute_2__rage_rank_11") then
		end

    if caster:FindAbilityByName("brute_2__rage_rank_12") then
		end

		if caster:FindAbilityByName("brute_2__rage_rank_21") then
		end

    if caster:FindAbilityByName("brute_2__rage_rank_22") then
		end

		if caster:FindAbilityByName("brute_2__rage_rank_31") then
		end

    if caster:FindAbilityByName("brute_2__rage_rank_32") then
		end

		if caster:FindAbilityByName("brute_2__rage_rank_41") then
		end

    if caster:FindAbilityByName("brute_2__rage_rank_42") then
		end
	end

	if ability:GetAbilityName() == "brute_3__xcution" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("brute_3__xcution_rank_11") then
		end

    if caster:FindAbilityByName("brute_3__xcution_rank_12") then
		end

		if caster:FindAbilityByName("brute_3__xcution_rank_21") then
		end

    if caster:FindAbilityByName("brute_3__xcution_rank_22") then
		end

		if caster:FindAbilityByName("brute_3__xcution_rank_31") then
		end

    if caster:FindAbilityByName("brute_3__xcution_rank_32") then
		end

		if caster:FindAbilityByName("brute_3__xcution_rank_41") then
		end

    if caster:FindAbilityByName("brute_3__xcution_rank_42") then
		end
	end

	if ability:GetAbilityName() == "brute_4__sk4" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("brute_4__sk4_rank_11") then
		end

    if caster:FindAbilityByName("brute_4__sk4_rank_12") then
		end

		if caster:FindAbilityByName("brute_4__sk4_rank_21") then
		end

    if caster:FindAbilityByName("brute_4__sk4_rank_22") then
		end

		if caster:FindAbilityByName("brute_4__sk4_rank_31") then
		end

    if caster:FindAbilityByName("brute_4__sk4_rank_32") then
		end

		if caster:FindAbilityByName("brute_4__sk4_rank_41") then
		end

    if caster:FindAbilityByName("brute_4__sk4_rank_42") then
		end
	end

	if ability:GetAbilityName() == "brute_5__sk5" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("brute_5__sk5_rank_11") then
		end

    if caster:FindAbilityByName("brute_5__sk5_rank_12") then
		end

		if caster:FindAbilityByName("brute_5__sk5_rank_21") then
		end

    if caster:FindAbilityByName("brute_5__sk5_rank_22") then
		end

		if caster:FindAbilityByName("brute_5__sk5_rank_31") then
		end

    if caster:FindAbilityByName("brute_5__sk5_rank_32") then
		end

		if caster:FindAbilityByName("brute_5__sk5_rank_41") then
		end

    if caster:FindAbilityByName("brute_5__sk5_rank_42") then
		end
	end

	if ability:GetAbilityName() == "brute_u__mark" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("brute_u__mark_rank_11") then
		end

    if caster:FindAbilityByName("brute_u__mark_rank_12") then
		end

		if caster:FindAbilityByName("brute_u__mark_rank_21") then
		end

    if caster:FindAbilityByName("brute_u__mark_rank_22") then
		end

		if caster:FindAbilityByName("brute_u__mark_rank_31") then
		end

    if caster:FindAbilityByName("brute_u__mark_rank_32") then
		end

		if caster:FindAbilityByName("brute_u__mark_rank_41") then
		end

    if caster:FindAbilityByName("brute_u__mark_rank_42") then
		end
	end

	return 0
end

function brute_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "brute_1__spin" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "spin_interval" then return 0.5 - (value_level * 0.02) end
	end

	if ability:GetAbilityName() == "brute_2__rage" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "brute_3__xcution" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "brute_4__sk4" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "brute_5__sk5" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "brute_u__mark" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------