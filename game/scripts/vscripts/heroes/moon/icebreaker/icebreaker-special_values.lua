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

  if value_name == "frozen_duration" then return 1 end
  if value_name == "max_hypo_stack" then return 1 end
  if value_name == "hypo_duration" then return 1 end
  if value_name == "slow_ms" then return 1 end
  if value_name == "slow_as" then return 1 end
  if value_name == "slow_duration" then return 1 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "chance" then return 1 end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_22") then
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_31") then
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_32") then
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_41") then
		end

    if caster:FindAbilityByName("icebreaker_1__frost_rank_42") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
    if value_name == "distance" then return 1 end
		if value_name == "speed" then return 1 end

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
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

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
		if value_name == "blast_radius" then return 1 end

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
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
    if value_name == "rank" then return 1 end
    if value_name == "cast_range" then return 1 end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_12") then
		end

		if caster:FindAbilityByName("icebreaker_5__blink_rank_21") then
		end

    if caster:FindAbilityByName("icebreaker_5__blink_rank_22") then
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
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

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

function icebreaker_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

  if value_name == "frozen_duration" then return 3 end
  if value_name == "max_hypo_stack" then return 10 end
  if value_name == "hypo_duration" then return 3 end
  if value_name == "slow_ms" then return 10 end
  if value_name == "slow_as" then return 10 end
  if value_name == "slow_duration" then return 1 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return caster:Script_GetAttackRange() end
    if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "chance" then return 75 + (value_level * 2.5) end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "distance" then return 1500 + (value_level * 50) end
		if value_name == "speed" then return 600 + (value_level * 50) end
	end

	if ability:GetAbilityName() == "icebreaker_3__skin" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 18 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 9 + (value_level * 0.5) end
	end

	if ability:GetAbilityName() == "icebreaker_4__shivas" then
		if value_name == "AbilityManaCost" then return 325 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 30 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "blast_radius" then return 750 + (value_level * 25) end
	end

	if ability:GetAbilityName() == "icebreaker_5__blink" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
    if value_name == "AbilityCharges" then return 2 end
    if value_name == "AbilityChargeRestoreTime" then return 15 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "cast_range" then return 750 + (value_level * 125) end
	end

	if ability:GetAbilityName() == "icebreaker_u__zero" then
		if value_name == "AbilityManaCost" then return 950 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 120 end
    if value_name == "AbilityCastRange" then return 150 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 20 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------