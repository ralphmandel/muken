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
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("druid_1__root_rank_11") then
      if value_name == "distance" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_12") then
      if value_name == "creation_speed" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_21") then
      if value_name == "special_silence" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_22") then
      if value_name == "special_disarm" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_31") then
      if value_name == "bush_duration" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_32") then
      if value_name == "special_permanent_bush" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_41") then
      if value_name == "special_bush_duration" then return 1 end
      if value_name == "special_root_duration" then return 1 end
      if value_name == "special_root_chance" then return 1 end
		end

    if caster:FindAbilityByName("druid_1__root_rank_42") then
      if value_name == "special_elden_radius" then return 1 end
      if value_name == "special_elden_damage" then return 1 end
      if value_name == "special_elden_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_2__armor" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
    if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("druid_2__armor_rank_21") then
      if value_name == "regen" then return 1 end
		end

		if caster:FindAbilityByName("druid_2__armor_rank_22") then
      if value_name == "def" then return 1 end
		end

		if caster:FindAbilityByName("druid_2__armor_rank_31") then
      if value_name == "special_res" then return 1 end
		end

    if caster:FindAbilityByName("druid_2__armor_rank_32") then
      if value_name == "special_root_chance" then return 1 end
      if value_name == "special_root_duration" then return 1 end
		end

    if caster:FindAbilityByName("druid_2__armor_rank_41") then
      if value_name == "special_charges" then return 1 end
		end

    if caster:FindAbilityByName("druid_2__armor_rank_42") then
      if value_name == "special_radius" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_3__totem" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("druid_3__totem_rank_11") then
      if value_name == "ms_limit" then return 1 end
		end

    if caster:FindAbilityByName("druid_3__totem_rank_12") then
      if value_name == "hits" then return 1 end
		end

		if caster:FindAbilityByName("druid_3__totem_rank_21") then
      if value_name == "duration" then return 1 end
		end

    if caster:FindAbilityByName("druid_3__totem_rank_31") then
      if value_name == "heal" then return 1 end
		end

    if caster:FindAbilityByName("druid_3__totem_rank_32") then
      if value_name == "mana" then return 1 end
		end

    if caster:FindAbilityByName("druid_3__totem_rank_41") then
      if value_name == "special_spike_damage" then return 1 end
		end

		if caster:FindAbilityByName("druid_3__totem_rank_42") then
      if value_name == "special_flame_damage" then return 1 end
      if value_name == "special_flame_slow" then return 1 end
      if value_name == "special_flame_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_4__form" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

    if caster:FindAbilityByName("druid_4__form_rank_11") then
      if value_name == "special_heal" then return 1 end
		end
    
    if caster:FindAbilityByName("druid_4__form_rank_12") then
      if value_name == "special_fear_duration" then return 1 end
		end

    if caster:FindAbilityByName("druid_4__form_rank_21") then
      if value_name == "main" then return 1 end
		end

    if caster:FindAbilityByName("druid_4__form_rank_22") then
      if value_name == "str" then return 1 end
      if value_name == "mnd" then return 1 end
      if value_name == "con" then return 1 end
		end

    if caster:FindAbilityByName("druid_4__form_rank_31") then
      if value_name == "ms_percent" then return 1 end
		end

    if caster:FindAbilityByName("druid_4__form_rank_32") then
      if value_name == "special_damage_return" then return 1 end
		end

    if caster:FindAbilityByName("druid_4__form_rank_41") then
      if value_name == "special_stun_duration" then return 1 end
      if value_name == "agi" then return 1 end
		end

		if caster:FindAbilityByName("druid_4__form_rank_42") then
      if value_name == "special_break_duration" then return 1 end
      if value_name == "agi" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_5__seed" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "mana_reduction" then return 1 end
		if value_name == "radius" then return 1 end

    if caster:FindAbilityByName("druid_5__seed_rank_12") then
      if value_name == "seed_speed" then return 1 end
		end

    if caster:FindAbilityByName("druid_5__seed_rank_21") then
      if value_name == "special_enemy_seed" then return 1 end
		end

    if caster:FindAbilityByName("druid_5__seed_rank_31") then
      if value_name == "special_branch" then return 1 end
    end

    if caster:FindAbilityByName("druid_5__seed_rank_32") then
      if value_name == "tree_chance" then return 1 end
      if value_name == "tree_interval" then return 1 end
      if value_name == "special_tree_seed_extra" then return 1 end
		end

    if caster:FindAbilityByName("druid_5__seed_rank_41") then
      if value_name == "special_ally_seed_extra" then return 1 end
		end

    if caster:FindAbilityByName("druid_5__seed_rank_42") then
      if value_name == "special_druid_seed_extra" then return 1 end
		end
	end

	if ability:GetAbilityName() == "druid_u__conversion" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "max_dominate" then return 1 end

		if caster:FindAbilityByName("druid_u__conversion_rank_11") then
      if value_name == "radius" then return 1 end
		end

    if caster:FindAbilityByName("druid_u__conversion_rank_12") then
      if value_name == "cast_range" then return 1 end
		end

		if caster:FindAbilityByName("druid_u__conversion_rank_21") then
      if value_name == "chance" then return 1 end
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
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
    if value_name == "AbilityCooldown" then return 15 - (value_level * 0.3) end
    if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "distance" then return 1500 end
    if value_name == "creation_speed" then return 900 end
    if value_name == "special_silence" then return 1 end
    if value_name == "special_disarm" then return 1 end
    if value_name == "bush_duration" then return 15 end
    if value_name == "special_permanent_bush" then return 1 end
    if value_name == "special_bush_duration" then return 3 end
    if value_name == "special_root_duration" then return 0.5 end
    if value_name == "special_root_chance" then return 25 end
    if value_name == "special_elden_radius" then return 600 end
    if value_name == "special_elden_damage" then return 250 end
    if value_name == "special_elden_duration" then return 3 end
	end

	if ability:GetAbilityName() == "druid_2__armor" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("druid_2__armor_rank_41") then
        return 120 * (1 + ((ability_level - 1) * 0.05))
      end
      return 160 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("druid_2__armor_rank_11") then
        return 30
      end
      return 36
    end
    
    if value_name == "AbilityCastRange" then
      if caster:FindAbilityByName("druid_2__armor_rank_12") then
        return 0
      end
      return 800
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "duration" then return 12 + (value_level * 0.3) end

    if value_name == "regen" then return 1 end
    if value_name == "def" then return 30 end
    if value_name == "special_res" then return 15 end
    if value_name == "special_root_chance" then return 15 end
    if value_name == "special_root_duration" then return 2 end
    if value_name == "special_charges" then return 2 end
    if value_name == "special_radius" then return 200 end
	end

	if ability:GetAbilityName() == "druid_3__totem" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
      if caster:FindAbilityByName("druid_3__totem_rank_22") then
        return 45
      end
      return 60
    end

    if value_name == "AbilityCastRange" then return 450 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 250 + (value_level * 5) end

    if value_name == "ms_limit" then return 275 end
    if value_name == "hits" then return 15 end
    if value_name == "duration" then return 30 end
    if value_name == "heal" then return 40 end
    if value_name == "mana" then return 30 end
    if value_name == "special_spike_damage" then return 75 end
    if value_name == "special_flame_damage" then return 50 end
    if value_name == "special_flame_slow" then return 100 end
    if value_name == "special_flame_duration" then return 5 end
	end

	if ability:GetAbilityName() == "druid_4__form" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 150 - (value_level * 5) end
		if value_name == "rank" then return 6 + (value_level * 1) end

    if value_name == "special_heal" then return 30 end
    if value_name == "special_fear_duration" then return 5 end
    if value_name == "main" then return 20 end
    if value_name == "str" then return 15 end
    if value_name == "mnd" then return 15 end
    if value_name == "con" then return 15 end
    if value_name == "ms_percent" then return 40 end
    if value_name == "special_damage_return" then return 50 end
    if value_name == "special_stun_duration" then return 0.5 end
    if value_name == "special_break_duration" then return 1.5 end
    if value_name == "agi" then return -100 end
	end

	if ability:GetAbilityName() == "druid_5__seed" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("druid_5__seed_rank_11") then
        return 200 * (1 + ((ability_level - 1) * 0.05))
      end
      return 0 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 1.5 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 600 + (value_level * 15) end

    if value_name == "mana_reduction" then
      if caster:FindAbilityByName("druid_5__seed_rank_11") then
        return -15
      end
      return -20 - (value_level * 1)
    end

    if value_name == "seed_speed" then return 300 end
    if value_name == "special_enemy_seed" then return 1 end
    if value_name == "tree_chance" then return 100 end
    if value_name == "tree_interval" then return 2 end
    if value_name == "special_branch" then return 1 end
    if value_name == "special_tree_seed_extra" then return 2 end
    if value_name == "special_ally_seed_extra" then return 2 end
    if value_name == "special_druid_seed_extra" then return 5 end
	end

	if ability:GetAbilityName() == "druid_u__conversion" then
		if value_name == "AbilityManaCost" then
      if caster:FindAbilityByName("druid_u__conversion_rank_22") then
        return 15 * (1 + ((ability_level - 1) * 0.05))
      end
      return 20 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 9 + (value_level * 1) end
    if value_name == "max_dominate" then return 20 + (value_level * 1) end

    if value_name == "radius" then return 325 end
		if value_name == "cast_range" then return 750 end
    if value_name == "chance" then return 3.5 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------