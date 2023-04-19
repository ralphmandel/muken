lawbreaker__special_values = class({})

function lawbreaker__special_values:IsHidden() return true end
function lawbreaker__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker__special_values:OnCreated(kv)
end

function lawbreaker__special_values:OnRefresh(kv)
end

function lawbreaker__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function lawbreaker__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "lawbreaker_1__shot" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_1__shot_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_1__shot_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_1__shot_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_1__shot_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_1__shot_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_1__shot_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_1__shot_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_1__shot_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_2__combo" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_2__combo_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_2__combo_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_2__combo_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_2__combo_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_2__combo_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_2__combo_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_2__combo_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_2__combo_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_3__grenade" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_3__grenade_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_3__grenade_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_3__grenade_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_3__grenade_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_3__grenade_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_3__grenade_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_3__grenade_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_3__grenade_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_4__sk4" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_4__sk4_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_4__sk4_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_4__sk4_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_4__sk4_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_4__sk4_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_4__sk4_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_4__sk4_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_4__sk4_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_5__sk5" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_5__sk5_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_5__sk5_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_5__sk5_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_5__sk5_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_5__sk5_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_5__sk5_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_5__sk5_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_5__sk5_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_u__sk6" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_u__sk6_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_u__sk6_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_u__sk6_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_u__sk6_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_u__sk6_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_u__sk6_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_u__sk6_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_u__sk6_rank_42") then
		end
	end

	return 0
end

function lawbreaker__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "lawbreaker_1__shot" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_2__combo" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_3__grenade" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_4__sk4" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_5__sk5" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_u__sk6" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------