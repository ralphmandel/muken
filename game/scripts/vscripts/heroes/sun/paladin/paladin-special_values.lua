paladin_special_values = class({})

function paladin_special_values:IsHidden() return true end
function paladin_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_special_values:OnCreated(kv)
end

function paladin_special_values:OnRefresh(kv)
end

function paladin_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function paladin_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "paladin_1__link" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end
		if value_name == "max_range" then return 1 end

		if caster:FindAbilityByName("paladin_1__link_rank_11") then
		end

    if caster:FindAbilityByName("paladin_1__link_rank_12") then
		end

		if caster:FindAbilityByName("paladin_1__link_rank_21") then
		end

    if caster:FindAbilityByName("paladin_1__link_rank_22") then
		end

		if caster:FindAbilityByName("paladin_1__link_rank_31") then
		end

    if caster:FindAbilityByName("paladin_1__link_rank_32") then
		end

		if caster:FindAbilityByName("paladin_1__link_rank_41") then
		end

    if caster:FindAbilityByName("paladin_1__link_rank_42") then
		end
	end

	if ability:GetAbilityName() == "paladin_2__shield" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("paladin_2__shield_rank_11") then
		end

    if caster:FindAbilityByName("paladin_2__shield_rank_12") then
		end

		if caster:FindAbilityByName("paladin_2__shield_rank_21") then
		end

    if caster:FindAbilityByName("paladin_2__shield_rank_22") then
		end

		if caster:FindAbilityByName("paladin_2__shield_rank_31") then
		end

    if caster:FindAbilityByName("paladin_2__shield_rank_32") then
		end

		if caster:FindAbilityByName("paladin_2__shield_rank_41") then
		end

    if caster:FindAbilityByName("paladin_2__shield_rank_42") then
		end
	end

	if ability:GetAbilityName() == "paladin_3__hammer" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("paladin_3__hammer_rank_11") then
		end

    if caster:FindAbilityByName("paladin_3__hammer_rank_12") then
		end

		if caster:FindAbilityByName("paladin_3__hammer_rank_21") then
		end

    if caster:FindAbilityByName("paladin_3__hammer_rank_22") then
		end

		if caster:FindAbilityByName("paladin_3__hammer_rank_31") then
		end

    if caster:FindAbilityByName("paladin_3__hammer_rank_32") then
		end

		if caster:FindAbilityByName("paladin_3__hammer_rank_41") then
		end

    if caster:FindAbilityByName("paladin_3__hammer_rank_42") then
		end
	end

	if ability:GetAbilityName() == "paladin_4__magnus" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("paladin_4__magnus_rank_11") then
		end

    if caster:FindAbilityByName("paladin_4__magnus_rank_12") then
		end

		if caster:FindAbilityByName("paladin_4__magnus_rank_21") then
		end

    if caster:FindAbilityByName("paladin_4__magnus_rank_22") then
		end

		if caster:FindAbilityByName("paladin_4__magnus_rank_31") then
		end

    if caster:FindAbilityByName("paladin_4__magnus_rank_32") then
		end

		if caster:FindAbilityByName("paladin_4__magnus_rank_41") then
		end

    if caster:FindAbilityByName("paladin_4__magnus_rank_42") then
		end
	end

	if ability:GetAbilityName() == "paladin_5__reborn" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("paladin_5__reborn_rank_11") then
		end

    if caster:FindAbilityByName("paladin_5__reborn_rank_12") then
		end

		if caster:FindAbilityByName("paladin_5__reborn_rank_21") then
		end

    if caster:FindAbilityByName("paladin_5__reborn_rank_22") then
		end

		if caster:FindAbilityByName("paladin_5__reborn_rank_31") then
		end

    if caster:FindAbilityByName("paladin_5__reborn_rank_32") then
		end

		if caster:FindAbilityByName("paladin_5__reborn_rank_41") then
		end

    if caster:FindAbilityByName("paladin_5__reborn_rank_42") then
		end
	end

	if ability:GetAbilityName() == "paladin_u__faith" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("paladin_u__faith_rank_11") then
		end

    if caster:FindAbilityByName("paladin_u__faith_rank_12") then
		end

		if caster:FindAbilityByName("paladin_u__faith_rank_21") then
		end

    if caster:FindAbilityByName("paladin_u__faith_rank_22") then
		end

		if caster:FindAbilityByName("paladin_u__faith_rank_31") then
		end

    if caster:FindAbilityByName("paladin_u__faith_rank_32") then
		end

		if caster:FindAbilityByName("paladin_u__faith_rank_41") then
		end

    if caster:FindAbilityByName("paladin_u__faith_rank_42") then
		end
	end

	return 0
end

function paladin_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "paladin_1__link" then
		if value_name == "AbilityManaCost" then return 400 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 90 end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "cast_range" then return 500 + (value_level * 25) end
		if value_name == "max_range" then return 1000 + (value_level * 25) end
	end

	if ability:GetAbilityName() == "paladin_2__shield" then
		if value_name == "AbilityManaCost" then return 275 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 24 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "reduction" then return 50 + (value_level * 2) end
	end

	if ability:GetAbilityName() == "paladin_3__hammer" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "paladin_4__magnus" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "paladin_5__reborn" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "paladin_u__faith" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------