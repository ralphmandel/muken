lawbreaker_special_values = class({})

function lawbreaker_special_values:IsHidden() return true end
function lawbreaker_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_special_values:OnCreated(kv)
end

function lawbreaker_special_values:OnRefresh(kv)
end

function lawbreaker_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function lawbreaker_special_values:GetModifierOverrideAbilitySpecial(keys)
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
		if value_name == "max_shots" then return 1 end

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

	if ability:GetAbilityName() == "lawbreaker_4__rain" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("lawbreaker_4__rain_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_4__rain_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_4__rain_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_4__rain_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_4__rain_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_4__rain_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_4__rain_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_4__rain_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_5__blink" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_5__blink_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_5__blink_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_5__blink_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_5__blink_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_5__blink_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_5__blink_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_5__blink_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_5__blink_rank_42") then
		end
	end

	if ability:GetAbilityName() == "lawbreaker_u__form" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("lawbreaker_u__form_rank_11") then
		end

    if caster:FindAbilityByName("lawbreaker_u__form_rank_12") then
		end

		if caster:FindAbilityByName("lawbreaker_u__form_rank_21") then
		end

    if caster:FindAbilityByName("lawbreaker_u__form_rank_22") then
		end

		if caster:FindAbilityByName("lawbreaker_u__form_rank_31") then
		end

    if caster:FindAbilityByName("lawbreaker_u__form_rank_32") then
		end

		if caster:FindAbilityByName("lawbreaker_u__form_rank_41") then
		end

    if caster:FindAbilityByName("lawbreaker_u__form_rank_42") then
		end
	end

	return 0
end

function lawbreaker_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "lawbreaker_1__shot" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_2__combo" then
		if value_name == "AbilityManaCost" then
      return ability:GetCurrentAbilityCharges() * 5 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "max_shots" then return 15 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_3__grenade" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_4__rain" then
		if value_name == "AbilityManaCost" then return 115 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 20 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 300 + (value_level * 10) end
	end

	if ability:GetAbilityName() == "lawbreaker_5__blink" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "lawbreaker_u__form" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------