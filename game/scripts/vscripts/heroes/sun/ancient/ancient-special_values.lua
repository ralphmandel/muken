ancient_special_values = class({})

function ancient_special_values:IsHidden() return true end
function ancient_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_special_values:OnCreated(kv)
end

function ancient_special_values:OnRefresh(kv)
end

function ancient_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function ancient_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
  --"AbilityCastRange"
  --"AbilityCharges"
  --"AbilityChargeRestoreTime"

	if ability:GetAbilityName() == "ancient_1__smash" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "damage_percent" then return 1 end

		if caster:FindAbilityByName("ancient_1__smash_rank_11") then
		end

    if caster:FindAbilityByName("ancient_1__smash_rank_12") then
		end

		if caster:FindAbilityByName("ancient_1__smash_rank_21") then
		end

    if caster:FindAbilityByName("ancient_1__smash_rank_22") then
		end

		if caster:FindAbilityByName("ancient_1__smash_rank_31") then
		end

    if caster:FindAbilityByName("ancient_1__smash_rank_32") then
		end

		if caster:FindAbilityByName("ancient_1__smash_rank_41") then
		end

    if caster:FindAbilityByName("ancient_1__smash_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_2__leap" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end
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

	if ability:GetAbilityName() == "ancient_3__roar" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("ancient_3__roar_rank_11") then
		end

    if caster:FindAbilityByName("ancient_3__roar_rank_12") then
		end

		if caster:FindAbilityByName("ancient_3__roar_rank_21") then
		end

    if caster:FindAbilityByName("ancient_3__roar_rank_22") then
		end

		if caster:FindAbilityByName("ancient_3__roar_rank_31") then
		end

    if caster:FindAbilityByName("ancient_3__roar_rank_32") then
		end

		if caster:FindAbilityByName("ancient_3__roar_rank_41") then
		end

    if caster:FindAbilityByName("ancient_3__roar_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_4__walk" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("ancient_4__walk_rank_11") then
		end

    if caster:FindAbilityByName("ancient_4__walk_rank_12") then
		end

		if caster:FindAbilityByName("ancient_4__walk_rank_21") then
		end

    if caster:FindAbilityByName("ancient_4__walk_rank_22") then
		end

		if caster:FindAbilityByName("ancient_4__walk_rank_31") then
		end

    if caster:FindAbilityByName("ancient_4__walk_rank_32") then
		end

		if caster:FindAbilityByName("ancient_4__walk_rank_41") then
		end

    if caster:FindAbilityByName("ancient_4__walk_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_5__flesh" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "regen_percent" then return 1 end

		if caster:FindAbilityByName("ancient_5__flesh_rank_11") then
		end

    if caster:FindAbilityByName("ancient_5__flesh_rank_12") then
		end

		if caster:FindAbilityByName("ancient_5__flesh_rank_21") then
		end

    if caster:FindAbilityByName("ancient_5__flesh_rank_22") then
		end

		if caster:FindAbilityByName("ancient_5__flesh_rank_31") then
		end

    if caster:FindAbilityByName("ancient_5__flesh_rank_32") then
		end

		if caster:FindAbilityByName("ancient_5__flesh_rank_41") then
		end

    if caster:FindAbilityByName("ancient_5__flesh_rank_42") then
		end
	end

	if ability:GetAbilityName() == "ancient_u__fissure" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "energy_gain" then return 1 end

		if caster:FindAbilityByName("ancient_u__fissure_rank_11") then
		end

    if caster:FindAbilityByName("ancient_u__fissure_rank_12") then
		end

		if caster:FindAbilityByName("ancient_u__fissure_rank_21") then
		end

    if caster:FindAbilityByName("ancient_u__fissure_rank_22") then
		end

		if caster:FindAbilityByName("ancient_u__fissure_rank_31") then
		end

    if caster:FindAbilityByName("ancient_u__fissure_rank_32") then
		end

		if caster:FindAbilityByName("ancient_u__fissure_rank_41") then
		end

    if caster:FindAbilityByName("ancient_u__fissure_rank_42") then
		end
	end

	return 0
end

function ancient_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "ancient_1__smash" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "damage_percent" then return 75 + (value_level * 2.5) end
	end

	if ability:GetAbilityName() == "ancient_2__leap" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCharges" then return 3 end
    if value_name == "AbilityChargeRestoreTime" then return 8 end
    
    if value_name == "jump_distance" then
      return 100 + (caster:FindAbilityByName("ancient__jump"):GetLevel() * ability:GetCurrentAbilityCharges() * 0.5)
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 330 + (value_level * 15) end
	end

  if ability:GetAbilityName() == "ancient_3__roar" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 40 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 700 + (value_level * 50) end
	end

	if ability:GetAbilityName() == "ancient_4__walk" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 15 + (value_level * 0.5) end
	end

	if ability:GetAbilityName() == "ancient_5__flesh" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "regen_percent" then return 70 + (value_level * 5) end
	end

	if ability:GetAbilityName() == "ancient_u__fissure" then
		if value_name == "AbilityManaCost" then  
      local total_min_cost = caster:GetMaxMana() * ability:GetSpecialValueFor("min_cost") * 0.01
      if total_min_cost > caster:GetMana() then return total_min_cost else return caster:GetMana() end
    end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "energy_gain" then return 90 + (value_level * 5) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------