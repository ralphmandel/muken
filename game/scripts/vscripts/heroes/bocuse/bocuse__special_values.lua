bocuse__special_values = class({})

function bocuse__special_values:IsHidden() return true end
function bocuse__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse__special_values:OnCreated(kv)
end

function bocuse__special_values:OnRefresh(kv)
end

function bocuse__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function bocuse__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "bocuse_1__julienne" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_11") then
			if value_name == "cast_point" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_12") then
			if value_name == "max_cut" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_21") then
			if value_name == "stun_duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_31") then
			if value_name == "special_bleeding_chance" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_2__flambee" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_11") then
			if value_name == "cast_range" then return 1 end
			if value_name == "projectile_speed" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_12") then
			if value_name == "mana_percent" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_21") then
			if value_name == "effect_blind" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_22") then
			if value_name == "effect_resist" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_31") then
			if value_name == "special_init" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_32") then
			if value_name == "special_second_flask" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_3__sauce" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end

		-- if caster:FindAbilityByName("bocuse_3__sauce_rank_31") then
		-- 	if value_name == "special_purge_chance" then return 1 end
		-- end

		if caster:FindAbilityByName("bocuse_3__sauce_rank_31") then
			if value_name == "special_break" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_3__sauce_rank_41") then
			if value_name == "special_silence" then return 1 end
		end
		
		if caster:FindAbilityByName("bocuse_3__sauce_rank_42") then
			if value_name == "special_heal_allies" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_4__mirepoix" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_11") then
			if value_name == "cast_point" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_12") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_21") then
			if value_name == "base_aspd" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_22") then
			if value_name == "atk_range" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_5__roux" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("bocuse_5__roux_rank_11") then
			if value_name == "lifetime" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_12") then
			if value_name == "root_interval" then return 1 end
			if value_name == "root_duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_21") then
			if value_name == "slow" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_22") then
			if value_name == "cast_range" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_41") then
			if value_name == "special_mobility" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_u__mise" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "speed_mult" then return 1 end

		if caster:FindAbilityByName("bocuse_u__mise_rank_31") then
			if value_name == "special_jump_duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_u__mise_rank_32") then
			if value_name == "special_extra_damage" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_u__mise_rank_41") then
			if value_name == "special_autocast_chance" then return 1 end
			if value_name == "special_autocast_duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_u__mise_rank_42") then
			if value_name == "special_microstun_chance" then return 1 end
		end
	end

	return 0
end

function bocuse__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "bocuse_1__julienne" then
		if value_name == "AbilityManaCost" then return 125 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end
		if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 375 + (value_level * 25) end

		if value_name == "cast_point" then return 0.1 end
		if value_name == "max_cut" then return 7 end
		if value_name == "stun_duration" then return 3 end
		if value_name == "special_bleeding_chance" then return 10 end
	end

	if ability:GetAbilityName() == "bocuse_2__flambee" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 24 end

		if value_name == "AbilityCastRange" then
			return ability:GetSpecialValueFor("cast_range")
		end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 240 + (value_level * 10) end

		if value_name == "cast_range" then return 1000 end
		if value_name == "projectile_speed" then return 1200 end
		if value_name == "mana_percent" then return 2 end
		if value_name == "effect_blind" then return 50 end
		if value_name == "effect_resist" then return 50 end
		if value_name == "special_init" then return 1 end
		if value_name == "special_second_flask" then return 1 end
	end

	if ability:GetAbilityName() == "bocuse_3__sauce" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		--if value_name == "special_purge_chance" then return 5 end
		if value_name == "special_break" then return 1 end
		if value_name == "special_silence" then return 1 end
		if value_name == "special_heal_allies" then return 1 end
	end

	if ability:GetAbilityName() == "bocuse_4__mirepoix" then
		if value_name == "AbilityManaCost" then return 140 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 60 - (value_level * 2.5) end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "cast_point" then return 1 end
		if value_name == "duration" then return 40 end
		if value_name == "base_aspd" then return 0.9 end
		if value_name == "atk_range" then return 75 end
	end

	if ability:GetAbilityName() == "bocuse_5__roux" then
		if value_name == "AbilityManaCost" then return 170 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 45 end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 400 + (value_level * 10) end

		if value_name == "lifetime" then return 30 end
		if value_name == "root_interval" then return 4 end
		if value_name == "root_duration" then return 2 end
		if value_name == "slow" then return 75 end
		if value_name == "cast_range" then return 0 end
		if value_name == "special_mobility" then return -15 end
	end

	if ability:GetAbilityName() == "bocuse_u__mise" then
		if value_name == "AbilityManaCost" then return 150 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 35 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "speed_mult" then return 120 + (value_level) end

		if value_name == "special_jump_duration" then return 0.5 end
		if value_name == "special_extra_damage" then return 10 end
		if value_name == "special_autocast_chance" then return 12 end
		if value_name == "special_autocast_duration" then return 1 end
		if value_name == "special_microstun_chance" then return 35 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------