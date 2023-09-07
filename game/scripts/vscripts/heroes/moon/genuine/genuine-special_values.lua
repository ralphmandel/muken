genuine_special_values = class({})

function genuine_special_values:IsHidden() return true end
function genuine_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_special_values:OnCreated(kv)
end

function genuine_special_values:OnRefresh(kv)
end

function genuine_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function genuine_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

  if value_name == "special_starfall_damage" then return 1 end
	if value_name == "special_starfall_radius" then return 1 end
	if value_name == "special_starfall_delay" then return 1 end

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "charges" then return 1 end

		if caster:FindAbilityByName("genuine_1__shooting_rank_11") then
		end

    if caster:FindAbilityByName("genuine_1__shooting_rank_12") then
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_21") then
		end

    if caster:FindAbilityByName("genuine_1__shooting_rank_22") then
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_31") then
		end

    if caster:FindAbilityByName("genuine_1__shooting_rank_32") then
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_41") then
		end

    if caster:FindAbilityByName("genuine_1__shooting_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_2__fallen" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "distance" then return 1 end

		if caster:FindAbilityByName("genuine_2__fallen_rank_11") then
		end

    if caster:FindAbilityByName("genuine_2__fallen_rank_12") then
		end

    if caster:FindAbilityByName("genuine_2__fallen_rank_21") then
		end

    if caster:FindAbilityByName("genuine_2__fallen_rank_22") then
		end

		if caster:FindAbilityByName("genuine_2__fallen_rank_31") then
		end

    if caster:FindAbilityByName("genuine_2__fallen_rank_32") then
		end

		if caster:FindAbilityByName("genuine_2__fallen_rank_41") then
		end

    if caster:FindAbilityByName("genuine_2__fallen_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_3__travel" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "projectile_distance" then return 1 end

		if caster:FindAbilityByName("genuine_3__travel_rank_11") then
		end

    if caster:FindAbilityByName("genuine_3__travel_rank_12") then
		end

		if caster:FindAbilityByName("genuine_3__travel_rank_21") then
		end

    if caster:FindAbilityByName("genuine_3__travel_rank_22") then
		end

		if caster:FindAbilityByName("genuine_3__travel_rank_31") then
		end

    if caster:FindAbilityByName("genuine_3__travel_rank_32") then
		end

		if caster:FindAbilityByName("genuine_3__travel_rank_41") then
		end

    if caster:FindAbilityByName("genuine_3__travel_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_4__under" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "chance" then return 1 end

		if caster:FindAbilityByName("genuine_4__under_rank_11") then
		end

    if caster:FindAbilityByName("genuine_4__under_rank_12") then
		end

		if caster:FindAbilityByName("genuine_4__under_rank_21") then
		end

    if caster:FindAbilityByName("genuine_4__under_rank_22") then
		end

		if caster:FindAbilityByName("genuine_4__under_rank_31") then
		end

    if caster:FindAbilityByName("genuine_4__under_rank_32") then
		end

		if caster:FindAbilityByName("genuine_4__under_rank_41") then
		end

    if caster:FindAbilityByName("genuine_4__under_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_5__nightfall" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "arrow_range" then return 1 end

		if caster:FindAbilityByName("genuine_5__nightfall_rank_11") then
		end

    if caster:FindAbilityByName("genuine_5__nightfall_rank_12") then
		end

		if caster:FindAbilityByName("genuine_5__nightfall_rank_21") then
		end

    if caster:FindAbilityByName("genuine_5__nightfall_rank_22") then
		end

		if caster:FindAbilityByName("genuine_5__nightfall_rank_31") then
		end

    if caster:FindAbilityByName("genuine_5__nightfall_rank_32") then
		end

		if caster:FindAbilityByName("genuine_5__nightfall_rank_41") then
		end

    if caster:FindAbilityByName("genuine_5__nightfall_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_u__morning" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("genuine_u__morning_rank_11") then
		end

    if caster:FindAbilityByName("genuine_u__morning_rank_12") then
		end

		if caster:FindAbilityByName("genuine_u__morning_rank_21") then
		end

    if caster:FindAbilityByName("genuine_u__morning_rank_22") then
		end

		if caster:FindAbilityByName("genuine_u__morning_rank_31") then
		end

    if caster:FindAbilityByName("genuine_u__morning_rank_32") then
		end

		if caster:FindAbilityByName("genuine_u__morning_rank_41") then
		end

    if caster:FindAbilityByName("genuine_u__morning_rank_42") then
		end
	end

	return 0
end

function genuine_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

  if value_name == "special_starfall_damage" then return 100 end
	if value_name == "special_starfall_radius" then return 250 end
	if value_name == "special_starfall_delay" then return 0.5 end

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then return 25 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return caster:Script_GetAttackRange() end
    if value_name == "AbilityCharges" then return ability:GetSpecialValueFor("charges") end
    if value_name == "AbilityChargeRestoreTime" then return 1.5 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "charges" then return 18 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "genuine_2__fallen" then
		if value_name == "AbilityManaCost" then return 175 * (1 + ((ability_level - 1) * 0.05)) end
    if value_name == "AbilityCooldown" then return 15 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "distance" then return 600 + (value_level * 50) end
	end

	if ability:GetAbilityName() == "genuine_3__travel" then
		if value_name == "AbilityManaCost" then
      if ability:GetCurrentAbilityCharges() == 1 then return 0 end
      return 225 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 18 end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "projectile_distance" then return 900 + (value_level * 50) end
	end

	if ability:GetAbilityName() == "genuine_4__under" then
		if value_name == "AbilityManaCost" then return 0 end
    if value_name == "AbilityCooldown" then return 0 end
    if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "chance" then return 17 + (value_level * 0.5) end
	end

	if ability:GetAbilityName() == "genuine_5__nightfall" then
		if value_name == "AbilityManaCost" then return 175 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("arrow_range") end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 10 end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "arrow_range" then return 1800 + (value_level * 100) end
	end

	if ability:GetAbilityName() == "genuine_u__morning" then
		if value_name == "AbilityManaCost" then return 950 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 120 end
		if value_name == "rank" then return 9 + (value_level * 1) end
    if value_name == "duration" then return 15 + (value_level * 0.5) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------