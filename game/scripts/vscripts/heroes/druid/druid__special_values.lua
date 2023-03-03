druid__special_values = class({})

function druid__special_values:IsHidden() return true end
function druid__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid__special_values:OnCreated(kv)
end

function druid__special_values:OnRefresh(kv)
end

function druid__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function druid__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "druid_1__root" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "distance" then return 1 end

		if caster:FindAbilityByName("druid_1__root_rank_11") then
      if value_name == "creation_speed" then return 1 end
		end

		if caster:FindAbilityByName("druid_1__root_rank_21") then
      if value_name == "bush_duration" then return 1 end
		end

		if caster:FindAbilityByName("druid_1__root_rank_31") then
      if value_name == "special_damage" then return 1 end
		end

		if caster:FindAbilityByName("druid_1__root_rank_41") then
      if value_name == "special_bush_duration" then return 1 end
      if value_name == "special_root_duration" then return 1 end
      if value_name == "special_root_chance" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_2__armor" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_2__armor_rank_11") then
		end

		if caster:FindAbilityByName("druid_2__armor_rank_21") then
		end

		if caster:FindAbilityByName("druid_2__armor_rank_31") then
		end

		if caster:FindAbilityByName("druid_2__armor_rank_41") then
		end
	end

	if ability:GetAbilityName() == "druid_3__totem" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_3__totem_rank_11") then
		end

		if caster:FindAbilityByName("druid_3__totem_rank_21") then
		end

		if caster:FindAbilityByName("druid_3__totem_rank_31") then
		end
		
		if caster:FindAbilityByName("druid_3__totem_rank_41") then
		end
	end

	if ability:GetAbilityName() == "druid_4__form" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_4__form_rank_11") then
		end

		if caster:FindAbilityByName("druid_4__form_rank_21") then
		end

		if caster:FindAbilityByName("druid_4__form_rank_31") then
		end

		if caster:FindAbilityByName("druid_4__form_rank_41") then
		end
	end

	if ability:GetAbilityName() == "druid_5__seed" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_5__seed_rank_11") then
		end

		if caster:FindAbilityByName("druid_5__seed_rank_21") then
		end

		if caster:FindAbilityByName("druid_5__seed_rank_31") then
		end

		if caster:FindAbilityByName("druid_5__seed_rank_41") then
		end
	end

	if ability:GetAbilityName() == "druid_u__conversion" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_u__conversion_rank_11") then
		end

		if caster:FindAbilityByName("druid_u__conversion_rank_21") then
		end

		if caster:FindAbilityByName("druid_u__conversion_rank_31") then
		end

		if caster:FindAbilityByName("druid_u__conversion_rank_41") then
		end
	end

	return 0
end

function druid__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "druid_1__root" then
		if value_name == "AbilityManaCost" then return 125 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 12 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("distance") end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "distance" then return 1000 + (value_level * 100) end

    if value_name == "creation_speed" then return 750 end
    if value_name == "bush_duration" then return 10 end
    if value_name == "special_damage" then return 75 end
    if value_name == "special_bush_duration" then return 2 end
    if value_name == "special_root_duration" then return 0.5 end
    if value_name == "special_root_chance" then return 25 end
	end

	if ability:GetAbilityName() == "druid_2__armor" then
		if value_name == "AbilityManaCost" then return 140 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "druid_3__totem" then
		if value_name == "AbilityManaCost" then return 165 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "druid_4__form" then
		if value_name == "AbilityManaCost" then return 180 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "druid_5__seed" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "druid_u__conversion" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------