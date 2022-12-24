bloodstained__special_values = class({})

function bloodstained__special_values:IsHidden() return true end
function bloodstained__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__special_values:OnCreated(kv)
end

function bloodstained__special_values:OnRefresh(kv)
end

function bloodstained__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function bloodstained__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "bloodstained_1__rage" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("bloodstained_1__rage_rank_11") then
			if value_name == "resistance" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_1__rage_rank_31") then
			if value_name == "special_call_radius" then return 1 end
			if value_name == "special_call_duration" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_1__rage_rank_41") then
			if value_name == "special_cleave" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bloodstained_2__lifesteal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_11") then
		end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_21") then
		end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_31") then
		end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_41") then
		end
	end

	if ability:GetAbilityName() == "bloodstained_3__curse" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_11") then
		end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_21") then
		end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_31") then
		end
		
		if caster:FindAbilityByName("bloodstained_3__curse_rank_41") then
		end
	end

	if ability:GetAbilityName() == "bloodstained_4__frenzy" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_11") then
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_21") then
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_31") then
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_41") then
		end
	end

	if ability:GetAbilityName() == "bloodstained_5__tear" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_11") then
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_21") then
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_31") then
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_41") then
		end
	end

	if ability:GetAbilityName() == "bloodstained_u__seal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("bloodstained_u__seal_rank_12") then
			if value_name == "slow_duration" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_u__seal_rank_21") then
			if value_name == "copy_number" then return 1 end
			if value_name == "copy_duration" then return 1 end
			if value_name == "hp_stolen" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_u__seal_rank_41") then
			if value_name == "special_bleeding" then return 1 end
			if value_name == "special_refresh" then return 1 end
		end
	end

	return 0
end

function bloodstained__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "bloodstained_1__rage" then
		if value_name == "AbilityManaCost" then return 125 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bloodstained_1__rage_rank_21") then
				return 0
			end
			return 8
		end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.3) end
		if value_name == "resistance" then return 50 end
		if value_name == "special_call_radius" then return 450 end
		if value_name == "special_call_duration" then return 5 end
		if value_name == "special_cleave" then return 70 end
	end

	if ability:GetAbilityName() == "bloodstained_2__lifesteal" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "bloodstained_3__curse" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "bloodstained_4__frenzy" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "bloodstained_5__tear" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "bloodstained_u__seal" then
		if value_name == "AbilityManaCost" then
			local manacost = 250 * (1 + ((ability_level - 1) * 0.05))
			if caster:FindAbilityByName("bloodstained_u__seal_rank_11") then
				manacost = manacost - 100
			end
			return manacost
		end

		if value_name == "AbilityCooldown" then return 200 end
		if value_name == "AbilityCastRange" then return 450 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.5) end

		if value_name == "slow_duration" then return 3 end
		if value_name == "copy_number" then return 2 end
		if value_name == "copy_duration" then return 20 end
		if value_name == "hp_stolen" then return 10 end
		if value_name == "special_bleeding" then return 1 end
		if value_name == "special_refresh" then return 40 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------