icebreaker_special_values = class({})

function icebreaker_special_values:IsHidden() return true end
function icebreaker_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_special_values:OnCreated(kv)
end

function icebreaker_special_values:OnRefresh(kv)
end

function icebreaker_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function icebreaker_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

  if value_name == "hypo_ms" then return 1 end
  if value_name == "hypo_as" then return 1 end
  if value_name == "max_hypo_stack" then return 1 end
  if value_name == "hypo_decay" then return 1 end
  if value_name == "frozen_duration" then return 1 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
      if value_name == "chance" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
      if value_name == "chance" then return 1 end
      if value_name == "special_hits" then return 1 end
      if value_name == "special_hits_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_21") then
      if value_name == "special_ms" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_22") then
      if value_name == "special_invi_delay" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_31") then
      if value_name == "special_bonus_damage" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_32") then
      if value_name == "special_mini_freeze" then return 1 end
      if value_name == "special_mini_freeze_chance" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_41") then
      if value_name == "special_blink_chance" then return 1 end
      if value_name == "special_copy_duration" then return 1 end
      if value_name == "special_copy_incoming" then return 1 end
      if value_name == "special_copy_outgoing" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_42") then
      if value_name == "special_cleave" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
    if value_name == "distance" then return 1 end
		if value_name == "speed" then return 1 end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_11") then
      if value_name == "special_knockback_distance" then return 1 end
      if value_name == "special_knockback_duration" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_12") then
      if value_name == "special_auto_charge" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_21") then
      if value_name == "hypo_stack_min" then return 1 end
      if value_name == "hypo_stack_max" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_22") then
      if value_name == "recharge" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_31") then
      if value_name == "special_damage" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_32") then
      if value_name == "special_mana_burn" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_41") then
      if value_name == "special_copy_duration" then return 1 end
      if value_name == "special_copy_incoming" then return 1 end
      if value_name == "special_copy_outgoing" then return 1 end
      if value_name == "special_copy_chance" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_42") then
      if value_name == "special_silence_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_3__skin" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_12") then
      if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_21") then
      if value_name == "special_mp_regen" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_22") then
      if value_name == "special_hp_regen" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_31") then
      if value_name == "special_block" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_32") then
      if value_name == "special_spread_radius" then return 1 end
      if value_name == "special_spread_stack" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_41") then
      if value_name == "special_mini_freeze" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_42") then
      if value_name == "layers" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_4__shivas" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "blast_radius" then return 1 end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_11") then
      if value_name == "slow" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_12") then
      if value_name == "blast_speed" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_22") then
      if value_name == "special_cooldown" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_31") then
      if value_name == "special_break" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_32") then
      if value_name == "special_heal" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_41") then
      if value_name == "hypo_stack" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_42") then
      if value_name == "special_fear_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_5__blink" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_11") then
      if value_name == "special_break_hypo_stack" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_12") then
      if value_name == "special_spread_radius" then return 1 end
      if value_name == "special_spread_stack" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_22") then
      if value_name == "cast_range" then return 1 end
      if value_name == "special_super_blink" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_32") then
      if value_name == "special_hypo_damage" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_41") then
      if value_name == "damage" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_42") then
      if value_name == "special_break_heal" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_u__zero" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_11") then
      if value_name == "ms_limit" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_12") then
      if value_name == "hits" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_22") then
      if value_name == "hypo_min_stack" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_31") then
      if value_name == "special_meteor_damage" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_32") then
      if value_name == "special_radius" then return 1 end
      if value_name == "special_fly_vision" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_41") then
      if value_name == "special_immunity" then return 1 end
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_42") then
      if value_name == "special_res_allies" then return 1 end
    end
	end

	return 0
end

function icebreaker_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

  if value_name == "hypo_ms" then
    if caster:FindAbilityByName("icebreaker_5__blink_rank_31") then
      return 10
		end
    return 7
  end

  if value_name == "hypo_decay" then
    if caster:FindAbilityByName("icebreaker_5__blink_rank_32") then
      return 6
		end
    return 4
  end

  if value_name == "frozen_duration" then
    if caster:FindAbilityByName("icebreaker_4__shivas_rank_31") then
      return 6
		end
    return 4
  end

  if value_name == "hypo_as" then return 0.15 end
  if value_name == "max_hypo_stack" then return 10 end
  if value_name == "special_copy_duration" then return 5 end
  if value_name == "special_copy_incoming" then return 500 end
  if value_name == "special_copy_outgoing" then return 25 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
        return 100 * (1 + ((ability_level - 1) * 0.05))
      end
      return 0 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
        return 15 * (1 + ((ability_level - 1) * 0.1))
      end
      return 0
    end
		
    if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "chance" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
        return 40 + (10 * (1 - ((ability_level - 1) * 0.05)))
      end
      if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
        return 30
      end
    end

    if value_name == "special_hits" then return 5 end
    if value_name == "special_hits_duration" then return 5 end
    if value_name == "special_ms" then return 50 end
    if value_name == "special_invi_delay" then return 5 end
    if value_name == "special_bonus_damage" then return 40 end
    if value_name == "special_mini_freeze" then return 0.5 end
    if value_name == "special_mini_freeze_chance" then return 50 end
    if value_name == "special_blink_chance" then return 25 end
    if value_name == "special_cleave" then return 1 end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("icebreaker_2__wave_rank_21") then
        return 240 * (1 + ((ability_level - 1) * 0.05))
      end
      return 180 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "distance" then return 500 + (value_level * 50) end
		if value_name == "speed" then return 1200 + (value_level * 30) end

    if value_name == "special_knockback_distance" then return 100 end
    if value_name == "special_knockback_duration" then return 0.2 end
    if value_name == "special_auto_charge" then return 3 end
    if value_name == "hypo_stack_min" then return 3 end
    if value_name == "hypo_stack_max" then return 5 end
    if value_name == "recharge" then return 9 end
    if value_name == "special_damage" then return 1.5 end
    if value_name == "special_mana_burn" then return 5 end
    if value_name == "special_copy_chance" then return 20 end
    if value_name == "special_silence_duration" then return 1 end
	end

	if ability:GetAbilityName() == "icebreaker_3__skin" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		
    if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("icebreaker_3__skin_rank_11") then
        return 20
      end
      return 24
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 750 + (value_level * 50) end

    if value_name == "duration" then return 14 end
    if value_name == "special_mp_regen" then return 7.5 end
    if value_name == "special_hp_regen" then return 30 end
    if value_name == "special_block" then return 1 end
    if value_name == "special_spread_radius" then return 350 end
    if value_name == "special_spread_stack" then return 1 end
    if value_name == "special_mini_freeze" then return 0.5 end
    if value_name == "layers" then return 10 end
	end

	if ability:GetAbilityName() == "icebreaker_4__shivas" then
		if value_name == "AbilityManaCost" then return 220 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("icebreaker_4__shivas_rank_21") then
        return 30
      end
      return 40
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "blast_radius" then return 700 + (value_level * 35) end

    if value_name == "slow" then return 25 end
    if value_name == "blast_speed" then return 525 end
    if value_name == "special_cooldown" then return 3 end
    if value_name == "special_break" then return 1 end
    if value_name == "special_heal" then return 250 end
    if value_name == "hypo_stack" then return 10 end
    if value_name == "special_fear_duration" then return 5 end
	end

	if ability:GetAbilityName() == "icebreaker_5__blink" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("icebreaker_5__blink_rank_21") then
        return 100 * (1 + ((ability_level - 1) * 0.05))
			end
      return 150 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 15 - ((ability_level - 1) * 0.5) end
		if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "special_break_hypo_stack" then return 1 end
    if value_name == "special_spread_radius" then return 350 end
    if value_name == "special_spread_stack" then return 1 end
    if value_name == "cast_range" then return 1200 end
    if value_name == "special_super_blink" then return 1 end
    if value_name == "damage" then return 350 end
    if value_name == "special_hypo_damage" then return 25 end
    if value_name == "special_break_heal" then return 50 end
	end

	if ability:GetAbilityName() == "icebreaker_u__zero" then
		if value_name == "AbilityManaCost" then return 325 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("icebreaker_u__zero_rank_21") then
        return 125
      end
      return 175
    end

		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 30 + (value_level * 1) end

    if value_name == "ms_limit" then return 175 end
    if value_name == "hits" then return 15 end
    if value_name == "hypo_min_stack" then return 3 end
    if value_name == "special_meteor_damage" then return 50 end
    if value_name == "special_radius" then return 25 end
    if value_name == "special_fly_vision" then return 1 end
    if value_name == "special_immunity" then return 1 end
    if value_name == "special_res_allies" then return 1 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------