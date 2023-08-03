templar_special_values = class({})

function templar_special_values:IsHidden() return true end
function templar_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_special_values:OnCreated(kv)
end

function templar_special_values:OnRefresh(kv)
end

function templar_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function templar_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
  --"AbilityCastRange"
  --"AbilityCharges"
  --"AbilityChargeRestoreTime"

	if ability:GetAbilityName() == "templar_1__shield" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("templar_1__shield_rank_11") then
		end

    if caster:FindAbilityByName("templar_1__shield_rank_12") then
		end

		if caster:FindAbilityByName("templar_1__shield_rank_21") then
		end

    if caster:FindAbilityByName("templar_1__shield_rank_22") then
		end

		if caster:FindAbilityByName("templar_1__shield_rank_31") then
		end

    if caster:FindAbilityByName("templar_1__shield_rank_32") then
		end

		if caster:FindAbilityByName("templar_1__shield_rank_41") then
		end

    if caster:FindAbilityByName("templar_1__shield_rank_42") then
		end
	end

	if ability:GetAbilityName() == "templar_2__barrier" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("templar_2__barrier_rank_11") then
		end

    if caster:FindAbilityByName("templar_2__barrier_rank_12") then
		end

		if caster:FindAbilityByName("templar_2__barrier_rank_21") then
		end

    if caster:FindAbilityByName("templar_2__barrier_rank_22") then
		end

		if caster:FindAbilityByName("templar_2__barrier_rank_31") then
		end

    if caster:FindAbilityByName("templar_2__barrier_rank_32") then
		end

		if caster:FindAbilityByName("templar_2__barrier_rank_41") then
		end

    if caster:FindAbilityByName("templar_2__barrier_rank_42") then
		end
	end

	if ability:GetAbilityName() == "templar_3__circle" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("templar_3__circle_rank_11") then
		end

    if caster:FindAbilityByName("templar_3__circle_rank_12") then
		end

		if caster:FindAbilityByName("templar_3__circle_rank_21") then
		end

    if caster:FindAbilityByName("templar_3__circle_rank_22") then
		end

		if caster:FindAbilityByName("templar_3__circle_rank_31") then
		end

    if caster:FindAbilityByName("templar_3__circle_rank_32") then
		end

		if caster:FindAbilityByName("templar_3__circle_rank_41") then
		end

    if caster:FindAbilityByName("templar_3__circle_rank_42") then
		end
	end

	if ability:GetAbilityName() == "templar_4__hammer" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("templar_4__hammer_rank_11") then
		end

    if caster:FindAbilityByName("templar_4__hammer_rank_12") then
		end

		if caster:FindAbilityByName("templar_4__hammer_rank_21") then
		end

    if caster:FindAbilityByName("templar_4__hammer_rank_22") then
		end

		if caster:FindAbilityByName("templar_4__hammer_rank_31") then
		end

    if caster:FindAbilityByName("templar_4__hammer_rank_32") then
		end

		if caster:FindAbilityByName("templar_4__hammer_rank_41") then
		end

    if caster:FindAbilityByName("templar_4__hammer_rank_42") then
		end
	end

	if ability:GetAbilityName() == "templar_5__reborn" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
    if value_name == "percent" then return 1 end

		if caster:FindAbilityByName("templar_5__reborn_rank_11") then
		end

    if caster:FindAbilityByName("templar_5__reborn_rank_12") then
		end

		if caster:FindAbilityByName("templar_5__reborn_rank_21") then
		end

    if caster:FindAbilityByName("templar_5__reborn_rank_22") then
		end

		if caster:FindAbilityByName("templar_5__reborn_rank_31") then
		end

    if caster:FindAbilityByName("templar_5__reborn_rank_32") then
		end

		if caster:FindAbilityByName("templar_5__reborn_rank_41") then
		end

    if caster:FindAbilityByName("templar_5__reborn_rank_42") then
		end
	end

	if ability:GetAbilityName() == "templar_u__praise" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "heal" then return 1 end

		if caster:FindAbilityByName("templar_u__praise_rank_11") then
		end

    if caster:FindAbilityByName("templar_u__praise_rank_12") then
		end

		if caster:FindAbilityByName("templar_u__praise_rank_21") then
		end

    if caster:FindAbilityByName("templar_u__praise_rank_22") then
		end

		if caster:FindAbilityByName("templar_u__praise_rank_31") then
		end

    if caster:FindAbilityByName("templar_u__praise_rank_32") then
		end

		if caster:FindAbilityByName("templar_u__praise_rank_41") then
		end

    if caster:FindAbilityByName("templar_u__praise_rank_42") then
		end
	end

	return 0
end

function templar_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "templar_1__shield" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "templar_2__barrier" then
		if value_name == "AbilityManaCost" then return 225 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 17 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 500 + (value_level * 50) end
	end

	if ability:GetAbilityName() == "templar_3__circle" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "templar_4__hammer" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "templar_5__reborn" then
		if value_name == "AbilityManaCost" then return 450 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 75 end
		if value_name == "AbilityCastRange" then return 300 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "percent" then return 40 + (value_level * 2) end
	end

	if ability:GetAbilityName() == "templar_u__praise" then
		if value_name == "AbilityManaCost" then return 550 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 120 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "heal" then return 50 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------