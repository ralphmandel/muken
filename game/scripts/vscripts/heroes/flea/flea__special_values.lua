flea__special_values = class({})

function flea__special_values:IsHidden() return true end
function flea__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea__special_values:OnCreated(kv)
end

function flea__special_values:OnRefresh(kv)
end

function flea__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function flea__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "flea_1__precision" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("flea_1__precision_rank_11") then
			if value_name == "refresh" then return 1 end
		end

		if caster:FindAbilityByName("flea_1__precision_rank_21") then
			if value_name == "charges" then return 1 end
		end

		if caster:FindAbilityByName("flea_1__precision_rank_31") then
			if value_name == "special_manaburn" then return 1 end
		end

		if caster:FindAbilityByName("flea_1__precision_rank_32") then
			if value_name == "special_purge" then return 1 end
		end

		if caster:FindAbilityByName("flea_1__precision_rank_41") then
			if value_name == "special_pact_damage" then return 1 end
			if value_name == "special_pact_radius" then return 1 end
			if value_name == "special_pact_pulses" then return 1 end
		end
	end

	if ability:GetAbilityName() == "flea_2__speed" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("flea_2__speed_rank_11") then
			if value_name == "min_speed" then return 1 end
		end

		if caster:FindAbilityByName("flea_2__speed_rank_21") then
			if value_name == "max_speed" then return 1 end
		end

		if caster:FindAbilityByName("flea_2__speed_rank_22") then
			if value_name == "duration" then return 1 end
			if value_name == "special_phase" then return 1 end
		end

		if caster:FindAbilityByName("flea_2__speed_rank_31") then
			if value_name == "special_charge" then return 1 end
		end
	end

	if ability:GetAbilityName() == "flea_3__jump" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "radius_impact" then return 1 end

		if caster:FindAbilityByName("flea_3__jump_rank_21") then
			if value_name == "silence_duration" then return 1 end
		end

		if caster:FindAbilityByName("flea_3__jump_rank_22") then
			if value_name == "hits" then return 1 end
		end

		if caster:FindAbilityByName("flea_3__jump_rank_31") then
			if value_name == "special_reset_chance" then return 1 end
		end
	end

	if ability:GetAbilityName() == "flea_4__smoke" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("flea_4__smoke_rank_11") then
			if value_name == "debuff_init" then return 1 end
		end

		if caster:FindAbilityByName("flea_4__smoke_rank_12") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("flea_4__smoke_rank_31") then
			if value_name == "special_invi_chance" then return 1 end
			if value_name == "special_invi_delay" then return 1 end
		end

		if caster:FindAbilityByName("flea_4__smoke_rank_41") then
			if value_name == "special_allies" then return 1 end
		end
	end

	if ability:GetAbilityName() == "flea_5__desolator" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("flea_5__desolator_rank_11") then
		end

		if caster:FindAbilityByName("flea_5__desolator_rank_21") then
		end

		if caster:FindAbilityByName("flea_5__desolator_rank_31") then
		end

		if caster:FindAbilityByName("flea_5__desolator_rank_41") then
		end
	end

	if ability:GetAbilityName() == "flea_u__weakness" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("flea_u__weakness_rank_21") then
			if value_name == "target_duration" then return 1 end
			if value_name == "caster_duration" then return 1 end
		end

		if caster:FindAbilityByName("flea_u__weakness_rank_22") then
			if value_name == "max_stack" then return 1 end
		end

		if caster:FindAbilityByName("flea_u__weakness_rank_31") then
			if value_name == "special_respawn_mult" then return 1 end
		end
	end

	return 0
end

function flea__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "flea_1__precision" then
		if value_name == "AbilityManaCost" then
			local mp_reduction = 0
			if caster:FindAbilityByName("flea_1__precision_rank_12") then
				mp_reduction = 20
			end
			return (100 * (1 + ((ability_level - 1) * 0.05))) - mp_reduction
		end

		if value_name == "duration" then
			return 9 + (value_level * 0.25)
		end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "refresh" then return 30 end
		if value_name == "charges" then return 4 end
		if value_name == "special_manaburn" then return 4 end
		if value_name == "special_purge" then return 1 end
		if value_name == "special_pact_damage" then return 50 end
		if value_name == "special_pact_radius" then return 325 end
		if value_name == "special_pact_pulses" then return 7 end
	end

	if ability:GetAbilityName() == "flea_2__speed" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end

		if value_name == "min_speed" then return 250 end
		if value_name == "max_speed" then return 75 end
		if value_name == "duration" then return 5 end
		if value_name == "special_phase" then return 1 end
		if value_name == "special_charge" then return 1 end
	end

	if ability:GetAbilityName() == "flea_3__jump" then
		if value_name == "AbilityManaCost" then return 125 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end

		if value_name == "radius_impact" then
			return 280 + (value_level * 10)
		end

		if value_name == "silence_duration" then return 5 end
		if value_name == "hits" then return 2 end
		if value_name == "special_reset_chance" then return 5 end
	end

	if ability:GetAbilityName() == "flea_4__smoke" then
		if value_name == "AbilityManaCost" then return 150 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 45 end
		if value_name == "AbilityCastRange" then return 450 end

		if value_name == "radius" then
			return 360 + (value_level * 10)
		end

		if value_name == "debuff_init" then return 70 end
		if value_name == "duration" then return 15 end
		if value_name == "special_invi_chance" then return 5 end
		if value_name == "special_invi_delay" then return 2 end
		if value_name == "special_allies" then return 1 end
	end

	if ability:GetAbilityName() == "flea_5__desolator" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
	end

	if ability:GetAbilityName() == "flea_u__weakness" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("flea_u__weakness_rank_22") then
				return 1
			end
			return 1.5
		end

		if value_name == "target_duration" then return 60 end
		if value_name == "caster_duration" then return 15 end
		if value_name == "max_stack" then return 8 end
		if value_name == "special_respawn_mult" then return 10 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------