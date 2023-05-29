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

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "atk_range" then return 1 end

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

	if ability:GetAbilityName() == "genuine_3__morning" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_3__morning_rank_11") then
		end

    if caster:FindAbilityByName("genuine_3__morning_rank_12") then
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_21") then
		end

    if caster:FindAbilityByName("genuine_3__morning_rank_22") then
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_31") then
		end

    if caster:FindAbilityByName("genuine_3__morning_rank_32") then
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_41") then
		end

    if caster:FindAbilityByName("genuine_3__morning_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_4__awakening" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_4__awakening_rank_11") then
		end

    if caster:FindAbilityByName("genuine_4__awakening_rank_12") then
		end

		if caster:FindAbilityByName("genuine_4__awakening_rank_21") then
		end

    if caster:FindAbilityByName("genuine_4__awakening_rank_22") then
		end

		if caster:FindAbilityByName("genuine_4__awakening_rank_31") then
		end

    if caster:FindAbilityByName("genuine_4__awakening_rank_32") then
		end

		if caster:FindAbilityByName("genuine_4__awakening_rank_41") then
		end

    if caster:FindAbilityByName("genuine_4__awakening_rank_42") then
		end
	end

	if ability:GetAbilityName() == "genuine_5__nightfall" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

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

	if ability:GetAbilityName() == "genuine_u__star" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_u__star_rank_11") then
		end

    if caster:FindAbilityByName("genuine_u__star_rank_12") then
		end

		if caster:FindAbilityByName("genuine_u__star_rank_21") then
		end

    if caster:FindAbilityByName("genuine_u__star_rank_22") then
		end

		if caster:FindAbilityByName("genuine_u__star_rank_31") then
		end

    if caster:FindAbilityByName("genuine_u__star_rank_32") then
		end

		if caster:FindAbilityByName("genuine_u__star_rank_41") then
		end

    if caster:FindAbilityByName("genuine_u__star_rank_42") then
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

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then return 40 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "atk_range" then return 0 + (value_level * 30) end
	end

	if ability:GetAbilityName() == "genuine_2__fallen" then
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 24 - (value_level * 0.6) end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "genuine_3__morning" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "genuine_4__awakening" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "genuine_5__nightfall" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "genuine_u__star" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------