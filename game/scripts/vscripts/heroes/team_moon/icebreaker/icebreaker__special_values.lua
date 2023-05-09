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

  if value_name == "hypo_ms" then return 1 end
  if value_name == "hypo_as" then return 1 end
  if value_name == "max_hypo_stack" then return 1 end
  if value_name == "decay" then return 1 end
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

		if caster:FindAbilityByName("icebreaker_2__wave_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_22") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_2__wave_rank_42") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_3__skin" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_22") then
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_3__skin_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_3__skin_rank_42") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_4__shivas" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_22") then
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_4__shivas_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_4__shivas_rank_42") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_5__blink" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_22") then
      if value_name == "special_super_blink" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_42") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_u__zero" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_22") then
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_u__zero_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_u__zero_rank_42") then
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

  if value_name == "hypo_ms" then return 7 end
  if value_name == "hypo_as" then return 0.15 end
  if value_name == "max_hypo_stack" then return 10 end
  if value_name == "decay" then return 4 end
  if value_name == "frozen_duration" then return 4 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
        return 50 * (1 + ((ability_level - 1) * 0.05))
      end
      return 0 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
        return 18
      end
      return 0
    end
		
    if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "chance" then
      if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
        return 45
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
    if value_name == "special_copy_duration" then return 10 end
    if value_name == "special_copy_incoming" then return 500 end
    if value_name == "special_copy_outgoing" then return 25 end
    if value_name == "special_cleave" then return 1 end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_3__skin" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_4__shivas" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_5__blink" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("icebreaker_u__blink_rank_21") then
        return 60 * (1 + ((ability_level - 1) * 0.05))
			end
      return 90 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 15 - (value_level * 0.5) end

    if value_name == "AbilityCastRange" then
			if caster:FindAbilityByName("icebreaker_u__blink_rank_22") then
				return 1200
			end
			return 800
		end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "special_super_blink" then return 1 end
	end

	if ability:GetAbilityName() == "icebreaker_u__zero" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------