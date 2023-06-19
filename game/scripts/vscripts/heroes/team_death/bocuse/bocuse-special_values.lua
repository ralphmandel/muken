bocuse_special_values = class({})

function bocuse_special_values:IsHidden() return true end
function bocuse_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_special_values:OnCreated(kv)
end

function bocuse_special_values:OnRefresh(kv)
end

function bocuse_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function bocuse_special_values:GetModifierOverrideAbilitySpecial(keys)
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
			if value_name == "special_invulnerable" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_21") then
			if value_name == "special_bleeding_chance" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_1__julienne_rank_22") then
			if value_name == "bleeding_duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_1__julienne_rank_31") then
			if value_name == "stun_duration" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_1__julienne_rank_32") then
			if value_name == "special_stun_radius" then return 1 end
      if value_name == "special_stun_dmg" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_1__julienne_rank_41") then
			if value_name == "max_cut" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_1__julienne_rank_42") then
			if value_name == "special_frenesi_chance" then return 1 end
			if value_name == "special_max_cut" then return 1 end
			if value_name == "special_cut_speed" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_2__flambee" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

    if caster:FindAbilityByName("bocuse_2__flambee_rank_11") then
			if value_name == "ms" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_12") then
			if value_name == "blind" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_2__flambee_rank_21") then
			if value_name == "mana" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_22") then
			if value_name == "damage" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_31") then
			if value_name == "special_purge_allies" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_2__flambee_rank_32") then
			if value_name == "special_purge_enemies" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_2__flambee_rank_41") then
			if value_name == "special_second_flask" then return 1 end
			if value_name == "duration" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_2__flambee_rank_42") then
			if value_name == "cast_range" then return 1 end
			if value_name == "projectile_speed" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_3__sauce" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end

		if caster:FindAbilityByName("bocuse_3__sauce_rank_11") then
			if value_name == "special_slow_stack" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_3__sauce_rank_12") then
			if value_name == "special_slow_duration" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_3__sauce_rank_21") then
			if value_name == "special_dex" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_3__sauce_rank_22") then
			if value_name == "special_break" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_3__sauce_rank_31") then
			if value_name == "special_silence" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_3__sauce_rank_32") then
			if value_name == "special_disarm" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_3__sauce_rank_41") then
			if value_name == "damage_amp_stack" then return 1 end
		end
		
		if caster:FindAbilityByName("bocuse_3__sauce_rank_42") then
			if value_name == "special_lifesteal" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_4__mirepoix" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_point" then return 1 end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_11") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_21") then
			if value_name == "special_agi" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_4__mirepoix_rank_22") then
			if value_name == "atk_range" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_4__mirepoix_rank_31") then
			if value_name == "special_block" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_4__mirepoix_rank_32") then
			if value_name == "hp_regen" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_4__mirepoix_rank_41") then
			if value_name == "def" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_4__mirepoix_rank_42") then
			if value_name == "res" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_5__roux" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("bocuse_5__roux_rank_11") then
			if value_name == "slow" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_12") then
			if value_name == "special_pull" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_21") then
			if value_name == "cast_range" then return 1 end
		end

		if caster:FindAbilityByName("bocuse_5__roux_rank_31") then
			if value_name == "lifetime" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_5__roux_rank_32") then
			if value_name == "special_agi" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_5__roux_rank_41") then
			if value_name == "root_interval" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_5__roux_rank_42") then
			if value_name == "root_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bocuse_u__mise" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "speed_mult" then return 1 end


    if caster:FindAbilityByName("bocuse_u__mise_rank_11") then
			if value_name == "special_jump_distance" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_12") then
			if value_name == "special_unslow" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_21") then
			if value_name == "special_microstun_chance" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_22") then
			if value_name == "special_lck" then return 1 end
			if value_name == "special_incoming" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_31") then
			if value_name == "special_extra_damage" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_32") then
			if value_name == "duration" then return 1 end
		end

    if caster:FindAbilityByName("bocuse_u__mise_rank_41") then
			if value_name == "special_autocast_chance" then return 1 end
      if value_name == "special_autocast_duration" then return 1 end
		end
	end

	return 0
end

function bocuse_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "bocuse_1__julienne" then
		if value_name == "AbilityManaCost" then return 110 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 17 end
		if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 350 + (value_level * 20) end

    if value_name == "cast_point" then return 0.1 end
    if value_name == "special_invulnerable" then return 1 end
    if value_name == "special_bleeding_chance" then return 7 end
    if value_name == "bleeding_duration" then return 6 end
    if value_name == "stun_duration" then return 4 end
    if value_name == "special_stun_radius" then return 350 end
    if value_name == "special_stun_dmg" then return 125 end
    if value_name == "max_cut" then return 10 end
    if value_name == "special_frenesi_chance" then return 40 end
    if value_name == "special_max_cut" then return 7 end
    if value_name == "special_cut_speed" then return 7.5 end
	end

	if ability:GetAbilityName() == "bocuse_2__flambee" then
		if value_name == "AbilityManaCost" then return 125 * (1 + ((ability_level - 1) * 0.05)) end
		
    if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("bocuse_2__flambee_rank_42") then
        return 24
      end
      return 30
    end

		if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 240 + (value_level * 12) end

    if value_name == "ms" then return 75 end
    if value_name == "blind" then return 25 end
    if value_name == "mana" then return 40 end
    if value_name == "damage" then return 40 end
    if value_name == "special_purge_allies" then return 1 end
    if value_name == "special_purge_enemies" then return 1 end
    if value_name == "special_second_flask" then return 1 end
    if value_name == "duration" then return 15 end
    if value_name == "cast_range" then return 0 end
    if value_name == "projectile_speed" then return 1800 end
	end

	if ability:GetAbilityName() == "bocuse_3__sauce" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "special_slow_stack" then return 5 end
    if value_name == "special_slow_duration" then return 0.75 end
    if value_name == "special_dex" then return -30 end
    if value_name == "special_break" then return 1 end
    if value_name == "special_silence" then return 1 end
    if value_name == "special_disarm" then return 1 end
    if value_name == "damage_amp_stack" then return 10 end
    if value_name == "special_lifesteal" then return 20 end
	end

	if ability:GetAbilityName() == "bocuse_4__mirepoix" then
		if value_name == "AbilityManaCost" then return 175 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("bocuse_4__mirepoix_rank_12") then
        return 90
      end
      return 120
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_point" then return 4 - (value_level * 0.2) end

    if value_name == "duration" then return 50 end
    if value_name == "special_agi" then return 20 end
    if value_name == "atk_range" then return 120 end
    if value_name == "special_block" then return 20 end
    if value_name == "hp_regen" then return 2 end
    if value_name == "def" then return 50 end
    if value_name == "res" then return 50 end
	end

	if ability:GetAbilityName() == "bocuse_5__roux" then
		if value_name == "AbilityManaCost" then return 135 * (1 + ((ability_level - 1) * 0.05)) end
		
    if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("bocuse_5__roux_rank_22") then
        return 30
      end
      return 45
    end
    
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 400 + (value_level * 10) end

    if value_name == "slow" then return 160 end
    if value_name == "special_pull" then return 1 end
    if value_name == "cast_range" then return 0 end
    if value_name == "lifetime" then return 30 end
    if value_name == "special_agi" then return -10 end
    if value_name == "root_interval" then return 1 end
    if value_name == "root_duration" then return 4 end
	end

	if ability:GetAbilityName() == "bocuse_u__mise" then
		if value_name == "AbilityManaCost" then return 130 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("bocuse_u__mise_rank_42") then
        return 20
      end
      return 37
    end

		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "speed_mult" then return 120 + (value_level * 1) end

		if value_name == "special_jump_distance" then return 500 end
    if value_name == "special_unslow" then return 1 end
    if value_name == "special_microstun_chance" then return 50 end
    if value_name == "special_lck" then return 30 end
    if value_name == "special_incoming" then return 30 end
    if value_name == "special_extra_damage" then return 10 end
    if value_name == "duration" then return 8 end
    if value_name == "special_autocast_chance" then return 10 end
    if value_name == "special_autocast_duration" then return ability:GetSpecialValueFor("duration") * 0.25 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------