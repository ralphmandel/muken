ancient__special_values = class({})

function ancient__special_values:IsHidden() return true end
function ancient__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient__special_values:OnCreated(kv)
end

function ancient__special_values:OnRefresh(kv)
end

function ancient__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function ancient__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "ancient_1__power" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("ancient_1__power_rank_11") then
		end

    if caster:FindAbilityByName("ancient_1__power_rank_12") then
		end

		if caster:FindAbilityByName("ancient_1__power_rank_21") then
		end

    if caster:FindAbilityByName("ancient_1__power_rank_22") then
		end

		if caster:FindAbilityByName("ancient_1__power_rank_31") then
		end

    if caster:FindAbilityByName("ancient_1__power_rank_32") then
		end

		if caster:FindAbilityByName("ancient_1__power_rank_41") then
		end

    if caster:FindAbilityByName("ancient_1__power_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_2__leap" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "jump_distance" then return 1 end

		if caster:FindAbilityByName("ancient_2__leap_rank_11") then
		end

    if caster:FindAbilityByName("ancient_2__leap_rank_12") then
		end

		if caster:FindAbilityByName("ancient_2__leap_rank_21") then
		end

    if caster:FindAbilityByName("ancient_2__leap_rank_22") then
		end

		if caster:FindAbilityByName("ancient_2__leap_rank_31") then
		end

    if caster:FindAbilityByName("ancient_2__leap_rank_32") then
		end

		if caster:FindAbilityByName("ancient_2__leap_rank_41") then
		end

    if caster:FindAbilityByName("ancient_2__leap_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_3__walk" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("ancient_3__walk_rank_11") then
		end

    if caster:FindAbilityByName("ancient_3__walk_rank_12") then
		end

		if caster:FindAbilityByName("ancient_3__walk_rank_21") then
		end

    if caster:FindAbilityByName("ancient_3__walk_rank_22") then
		end

		if caster:FindAbilityByName("ancient_3__walk_rank_31") then
		end

    if caster:FindAbilityByName("ancient_3__walk_rank_32") then
		end

		if caster:FindAbilityByName("ancient_3__walk_rank_41") then
		end

    if caster:FindAbilityByName("ancient_3__walk_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_4__flesh" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("ancient_4__flesh_rank_11") then
		end

    if caster:FindAbilityByName("ancient_4__flesh_rank_12") then
		end

		if caster:FindAbilityByName("ancient_4__flesh_rank_21") then
		end

    if caster:FindAbilityByName("ancient_4__flesh_rank_22") then
		end

		if caster:FindAbilityByName("ancient_4__flesh_rank_31") then
		end

    if caster:FindAbilityByName("ancient_4__flesh_rank_32") then
		end

		if caster:FindAbilityByName("ancient_4__flesh_rank_41") then
		end

    if caster:FindAbilityByName("ancient_4__flesh_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_5__petrify" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("ancient_5__petrify_rank_11") then
		end

    if caster:FindAbilityByName("ancient_5__petrify_rank_12") then
		end

		if caster:FindAbilityByName("ancient_5__petrify_rank_21") then
		end

    if caster:FindAbilityByName("ancient_5__petrify_rank_22") then
		end

		if caster:FindAbilityByName("ancient_5__petrify_rank_31") then
		end

    if caster:FindAbilityByName("ancient_5__petrify_rank_32") then
		end

		if caster:FindAbilityByName("ancient_5__petrify_rank_41") then
		end

    if caster:FindAbilityByName("ancient_5__petrify_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_u__final" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("ancient_u__final_rank_11") then
		end

    if caster:FindAbilityByName("ancient_u__final_rank_12") then
		end

		if caster:FindAbilityByName("ancient_u__final_rank_21") then
		end

    if caster:FindAbilityByName("ancient_u__final_rank_22") then
		end

		if caster:FindAbilityByName("ancient_u__final_rank_31") then
		end

    if caster:FindAbilityByName("ancient_u__final_rank_32") then
		end

		if caster:FindAbilityByName("ancient_u__final_rank_41") then
		end

    if caster:FindAbilityByName("ancient_u__final_rank_42") then
		end
	end

	return 0
end

function ancient__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "ancient_1__power" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "ancient_2__leap" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 13 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "jump_distance" then return caster:FindAbilityByName("ancient__jump"):GetLevel() * 1.5 end
	end

	if ability:GetAbilityName() == "ancient_3__walk" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "ancient_4__flesh" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "ancient_5__petrify" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 25 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "ancient_u__final" then
		if value_name == "AbilityManaCost" then  
      local total_min_cost = caster:GetMaxMana() * ability:GetSpecialValueFor("min_cost") * 0.01
      if total_min_cost > caster:GetMana() then return total_min_cost else return caster:GetMana() end
    end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------