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

    if caster:FindAbilityByName("bloodstained_1__rage_rank_22") then
			if value_name == "str_init" then return 1 end
			if value_name == "str_gain" then return 1 end
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
			if value_name == "heal_power" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_31") then
			if value_name == "special_kill_radius" then return 1 end
			if value_name == "special_kill_heal" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_2__lifesteal_rank_41") then
			if value_name == "base_heal" then return 1 end
			if value_name == "bonus_heal" then return 1 end
			if value_name == "special_cap" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bloodstained_3__curse" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end
		if value_name == "max_range" then return 1 end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_11") then
			if value_name == "slow" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_21") then
			if value_name == "shared_damage" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_31") then
			if value_name == "special_reset" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_3__curse_rank_32") then
			if value_name == "special_curse_damage" then return 1 end
			if value_name == "special_curse_interval" then return 1 end
		end
		
		if caster:FindAbilityByName("bloodstained_3__curse_rank_41") then
			if value_name == "special_curse_purge" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bloodstained_4__frenzy" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_11") then
			if value_name == "ms" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_21") then
			if value_name == "chance" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_31") then
			if value_name == "special_bleed_chance" then return 1 end
			if value_name == "special_bleed_duration" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_4__frenzy_rank_41") then
      if value_name == "duration" then return 1 end
			if value_name == "special_immortality" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bloodstained_5__tear" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "blood_percent" then return 1 end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_11") then
			if value_name == "hp_lost" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_21") then
			if value_name == "radius" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_22") then
			if value_name == "blood_duration" then return 1 end
			if value_name == "special_init_loss" then return 1 end
		end

		if caster:FindAbilityByName("bloodstained_5__tear_rank_31") then
			if value_name == "special_copy_leech" then return 1 end
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
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bloodstained_1__rage_rank_21") then
				return 0
			end
			return 8
		end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.25) end

		if value_name == "resistance" then return 50 end
    if value_name == "str_init" then return 0 end
    if value_name == "str_gain" then return 2 end
		if value_name == "special_call_radius" then return 450 end
		if value_name == "special_call_duration" then return 5 end
		if value_name == "special_cleave" then return 70 end
	end

	if ability:GetAbilityName() == "bloodstained_2__lifesteal" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "heal_power" then return 30 end
		if value_name == "special_kill_radius" then return 1000 end
		if value_name == "special_kill_heal" then return 25 end
		if value_name == "base_heal" then return 10 end
		if value_name == "bonus_heal" then return 15 end
		if value_name == "special_cap" then return 25 end
	end

	if ability:GetAbilityName() == "bloodstained_3__curse" then
		if value_name == "AbilityManaCost" then return 135 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 30 end

		if value_name == "AbilityCastRange" then
			return ability:GetSpecialValueFor("cast_range")
		end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 325 + (value_level * 25) end
		if value_name == "max_range" then return ability:GetSpecialValueFor("cast_range") + 200 end

		if value_name == "slow" then return 30 end
		if value_name == "shared_damage" then return 60 end
		if value_name == "special_reset" then return 1 end
    if value_name == "special_curse_damage" then return 3 end
		if value_name == "special_curse_interval" then return 2 end
		if value_name == "special_curse_purge" then return 500 end
	end

	if ability:GetAbilityName() == "bloodstained_4__frenzy" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bloodstained_4__frenzy_rank_21") then
				return 0
			end
			return 5
		end

		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "ms" then return 75 end
		if value_name == "chance" then return 10 end
    if value_name == "duration" then return 4 end
		if value_name == "special_bleed_chance" then return 5 end
		if value_name == "special_bleed_duration" then return 10 end
		if value_name == "special_immortality" then return 1 end
	end

	if ability:GetAbilityName() == "bloodstained_5__tear" then
		if value_name == "AbilityManaCost" then
      if ability:GetCurrentAbilityCharges() == 2 then
        return 0
      end
      return 100 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bloodstained_5__tear_rank_12") then
				return 45
			end		
			return 60
		end
		
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "blood_percent" then return 9 + (value_level * 0.1) end

		if value_name == "hp_lost" then return 2.5 end
		if value_name == "radius" then return 375 end
		if value_name == "blood_duration" then return 25 end
		if value_name == "special_init_loss" then return 500 end
		if value_name == "special_copy_leech" then return 1 end
	end

	if ability:GetAbilityName() == "bloodstained_u__seal" then
		if value_name == "AbilityManaCost" then
			if caster:FindAbilityByName("bloodstained_u__seal_rank_11") then
				return 175 * (1 + ((ability_level - 1) * 0.05))
			end
			return 225 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then return 200 end
		if value_name == "AbilityCastRange" then return 450 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.5) end

		if value_name == "slow_duration" then return 3 end
		if value_name == "copy_number" then return 2 end
		if value_name == "copy_duration" then return 20 end
		if value_name == "hp_stolen" then return 5 end
		if value_name == "special_bleeding" then return 1 end
		if value_name == "special_refresh" then return 40 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------