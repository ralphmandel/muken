icebreaker__special_values = class({})

function icebreaker__special_values:IsHidden() return true end
function icebreaker__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__special_values:OnCreated(kv)
end

function icebreaker__special_values:OnRefresh(kv)
end

function icebreaker__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function icebreaker__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
			if value_name == "stack_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_21") then
			if value_name == "damage" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_31") then
			if value_name == "special_blink_chance" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_41") then
			if value_name == "special_instant_duration" then return 1 end
			if value_name == "chance" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "distance" then return 1 end
		if value_name == "speed" then return 1 end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_11") then
			if value_name == "recharge" then return 1 end
			if value_name == "special_auto_charge" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_21") then
			if value_name == "stack_max" then return 1 end
			if value_name == "stack_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_31") then
			if value_name == "special_path_lifetime" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_32") then
			if value_name == "special_silence_duration" then return 1 end
			if value_name == "special_damage_percent" then return 1 end
			if value_name == "special_knockback" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_41") then
			if value_name == "special_mirror_lifetime" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_3__shard" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_11") then
			if value_name == "ms_limit" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_21") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_22") then
			if value_name == "intervals" then return 1 end
		end
		
		if caster:FindAbilityByName("icebreaker_3__shard_rank_31") then
			if value_name == "special_bonus_vision" then return 1 end
			if value_name == "special_truesight" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_41") then
			if value_name == "special_meteor_damage" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_4__mirror" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_11") then
			if value_name == "chance" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_12") then
			if value_name == "invi_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_21") then
			if value_name == "illusion_lifetime" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_31") then
			if value_name == "special_spell_chance" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_32") then
			if value_name == "special_splash_radius" then return 1 end
			if value_name == "special_instant_duration" then return 1 end
			if value_name == "special_stack" then return 1 end
			if value_name == "special_stack_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_5__shivas" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "blast_radius" then return 1 end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_11") then
			if value_name == "movespeed" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_21") then
			if value_name == "frozen_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_41") then
			if value_name == "special_cooldown" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_u__blink" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "damage" then return 1 end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_21") then
			if value_name == "special_no_roots" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_41") then
			if value_name == "special_spellsteal" then return 1 end
			if value_name == "special_spellsteal_kill" then return 1 end
		end
	end

	return 0
end

function icebreaker__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "stack_duration" then return 6 end
		if value_name == "damage" then return 60 end
		if value_name == "special_blink_chance" then return 15 end
		if value_name == "special_instant_duration" then return 0.2 end
		if value_name == "chance" then return 35 end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "distance" then return 850 + (value_level * 50) end
		if value_name == "speed" then return 675 + (value_level * 25) end

		if value_name == "recharge" then return 15 end
		if value_name == "special_auto_charge" then return 2 end
		if value_name == "stack_max" then return 5 end
		if value_name == "stack_duration" then return 10 end
		if value_name == "special_path_lifetime" then return 10 end
		if value_name == "special_silence_duration" then return 2 end
		if value_name == "special_damage_percent" then return 3 end
		if value_name == "special_knockback" then return 1 end
		if value_name == "special_mirror_lifetime" then return 5 end
	end

	if ability:GetAbilityName() == "icebreaker_3__shard" then
		if value_name == "AbilityManaCost" then return 185 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 120 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 500 + (value_level * 12.5) end

		if value_name == "ms_limit" then return 175 end
		if value_name == "duration" then return 60 end
		if value_name == "intervals" then return 3 end
		if value_name == "special_bonus_vision" then return 50 end
		if value_name == "special_truesight" then return 1 end
		if value_name == "special_meteor_damage" then return 75 end
	end

	if ability:GetAbilityName() == "icebreaker_4__mirror" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "chance" then return 17 end
		if value_name == "invi_duration" then return 3 end
		if value_name == "illusion_lifetime" then return 10 end
		if value_name == "special_spell_chance" then return 50 end
		if value_name == "special_splash_radius" then return 350 end
		if value_name == "special_instant_duration" then return 0.5 end
		if value_name == "special_stack" then return 1 end
		if value_name == "special_stack_duration" then return 5 end
	end

	if ability:GetAbilityName() == "icebreaker_5__shivas" then
		if value_name == "AbilityManaCost" then return 150 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 100 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "blast_radius" then return 850 + (value_level * 50) end

		if value_name == "movespeed" then return 50 end
		if value_name == "frozen_duration" then return 10 end
		if value_name == "special_cooldown" then return 5 end
	end

	if ability:GetAbilityName() == "icebreaker_u__blink" then
		if value_name == "AbilityManaCost" then
			if caster:FindAbilityByName("icebreaker_u__blink_rank_11") then
				return 80 * (1 + ((ability_level - 1) * 0.05))
			end
			return 100 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("icebreaker_u__blink_rank_12") then
				return 5
			end
			return 10
		end

		if value_name == "AbilityCastRange" then
			if caster:FindAbilityByName("icebreaker_u__blink_rank_21") then
				return 1000
			end
			return 500
		end

		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "damage" then return 200 + (value_level * 5) end

		if value_name == "special_no_roots" then return 1 end
		if value_name == "special_spellsteal" then return 50 end
		if value_name == "special_spellsteal_kill" then return 150 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------