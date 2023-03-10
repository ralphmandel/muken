genuine__special_values = class({})

function genuine__special_values:IsHidden() return true end
function genuine__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine__special_values:OnCreated(kv)
end

function genuine__special_values:OnRefresh(kv)
end

function genuine__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function genuine__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if value_name == "starfall_damage" then return 1 end
	if value_name == "starfall_radius" then return 1 end
	if value_name == "starfall_delay" then return 1 end

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "proj_speed" then return 1 end

		if caster:FindAbilityByName("genuine_1__shooting_rank_12") then
			if value_name == "damage" then return 1 end
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_21") then
			if value_name == "atk_range" then return 1 end
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_31") then
			if value_name == "special_starfall_combo" then return 1 end
			if value_name == "special_starfall_tick" then return 1 end
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_32") then
			if value_name == "special_lifesteal" then return 1 end
		end

		if caster:FindAbilityByName("genuine_1__shooting_rank_41") then
			if value_name == "special_fear_chance" then return 1 end
			if value_name == "special_fear_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "genuine_2__fallen" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_2__fallen_rank_11") then
			if value_name == "mana_steal" then return 1 end
		end

		if caster:FindAbilityByName("genuine_2__fallen_rank_12") then
			if value_name == "fear_duration" then return 1 end
		end

		if caster:FindAbilityByName("genuine_2__fallen_rank_21") then
			if value_name == "speed" then return 1 end
			if value_name == "radius" then return 1 end
			if value_name == "distance" then return 1 end
			if value_name == "special_wide" then return 1 end
		end

		if caster:FindAbilityByName("genuine_2__fallen_rank_31") then
			if value_name == "special_dispel_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "genuine_3__morning" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_3__morning_rank_11") then
			if value_name == "bonus_night_vision" then return 1 end
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_12") then
			if value_name == "int" then return 1 end
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_21") then
			if value_name == "force_night_time" then return 1 end
		end
		
		if caster:FindAbilityByName("genuine_3__morning_rank_31") then
			if value_name == "special_purge" then return 1 end
			if value_name == "special_ms" then return 1 end
		end

		if caster:FindAbilityByName("genuine_3__morning_rank_32") then
			if value_name == "special_agi" then return 1 end
		end
	end

	if ability:GetAbilityName() == "genuine_4__nightfall" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("genuine_4__nightfall_rank_21") then
			if value_name == "res" then return 1 end
		end

		if caster:FindAbilityByName("genuine_4__nightfall_rank_22") then
			if value_name == "debuff_power" then return 1 end
		end

		if caster:FindAbilityByName("genuine_4__nightfall_rank_41") then
			if value_name == "special_damage" then return 1 end
		end

		if caster:FindAbilityByName("genuine_4__nightfall_rank_42") then
			if value_name == "special_night_vision" then return 1 end
		end
	end

	if ability:GetAbilityName() == "genuine_5__awakening" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "damage" then return 1 end

		if caster:FindAbilityByName("genuine_5__awakening_rank_11") then
			if value_name == "arrow_range" then return 1 end
			if value_name == "arrow_speed" then return 1 end
		end

		if caster:FindAbilityByName("genuine_5__awakening_rank_12") then
			if value_name == "channel_time" then return 1 end
		end

		if caster:FindAbilityByName("genuine_5__awakening_rank_21") then
			if value_name == "charges" then return 1 end
		end

		if caster:FindAbilityByName("genuine_5__awakening_rank_31") then
			if value_name == "special_bash_power" then return 1 end
		end
	end

	if ability:GetAbilityName() == "genuine_u__star" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("genuine_u__star_rank_21") then
			if value_name == "target_damage_percent" then return 1 end
		end

		if caster:FindAbilityByName("genuine_u__star_rank_41") then
			if value_name == "special_starfall" then return 1 end
		end

		if caster:FindAbilityByName("genuine_u__star_rank_42") then
			if value_name == "special_purge" then return 1 end
		end
	end

	return 0
end

function genuine__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if value_name == "starfall_damage" then return 125 end
	if value_name == "starfall_radius" then return 250 end
	if value_name == "starfall_delay" then return 0.5 end

	if ability:GetAbilityName() == "genuine_1__shooting" then
		if value_name == "AbilityManaCost" then
			if caster:FindAbilityByName("genuine_1__shooting_rank_11") then
				return (20 * (1 + ((ability_level - 1) * 0.05))) - 5
			end
			return 20 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "AbilityCastRange" then return caster:Script_GetAttackRange() end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "proj_speed" then return 700 + (value_level * 50) end

		if value_name == "damage" then return 50 end
		if value_name == "atk_range" then return 300 end
		if value_name == "special_starfall_combo" then return 5 end
		if value_name == "special_starfall_tick" then return 5 end
		if value_name == "special_lifesteal" then return 30 end
		if value_name == "special_fear_chance" then return 10 end
		if value_name == "special_fear_duration" then return 1 end
	end

	if ability:GetAbilityName() == "genuine_2__fallen" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 14 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "mana_steal" then return 70 end
		if value_name == "fear_duration" then return 2.25 end
		if value_name == "speed" then return 2000 end
		if value_name == "radius" then return 400 end
		if value_name == "distance" then return 1000 end
		if value_name == "special_wide" then return 1 end
		if value_name == "special_dispel_duration" then return 6 end
	end

	if ability:GetAbilityName() == "genuine_3__morning" then
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 16 - (value_level * 0.4) end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "bonus_night_vision" then return 500 end
		if value_name == "int" then return 20 end
		if value_name == "force_night_time" then return 100 end
		if value_name == "special_purge" then return 1 end
		if value_name == "special_ms" then return 50 end
		if value_name == "special_agi" then return 15 end
	end

	if ability:GetAbilityName() == "genuine_4__nightfall" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 5 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "res" then return -10 end
		if value_name == "debuff_power" then return 60 end
		if value_name == "special_damage" then return 50 end
		if value_name == "special_night_vision" then return -300 end
	end

	if ability:GetAbilityName() == "genuine_5__awakening" then
		if value_name == "AbilityManaCost" then return 30 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 60 end
		if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("arrow_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "damage" then return 400 + (value_level * 10) end

		if value_name == "arrow_range" then return 3600 end
		if value_name == "arrow_speed" then return 3600 end
		if value_name == "channel_time" then return 5 end
		if value_name == "charges" then return 4 end
		if value_name == "special_bash_power" then return 750 end
	end

	if ability:GetAbilityName() == "genuine_u__star" then
		if value_name == "AbilityManaCost" then return 180 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 45 end
		if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.3) end
		if value_name == "cast_range" then return 450 + (value_level * 15) end

		if value_name == "target_damage_percent" then return 50 end
		if value_name == "special_starfall" then return 3 end
		if value_name == "special_purge" then return 3 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------