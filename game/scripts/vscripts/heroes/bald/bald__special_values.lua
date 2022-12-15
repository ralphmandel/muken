bald__special_values = class({})

function bald__special_values:IsHidden() return true end
function bald__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald__special_values:OnCreated(kv)
end

function bald__special_values:OnRefresh(kv)
end

function bald__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function bald__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "bald_1__power" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("bald_1__power_rank_21") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("bald_1__power_rank_31") then
			if value_name == "hit_build" then return 1 end
			if value_name == "hit_build_refresh" then return 1 end
		end

		if caster:FindAbilityByName("bald_1__power_rank_41") then
			if value_name == "bash_chance" then return 1 end
			if value_name == "bash_duration" then return 1 end
			if value_name == "bash_damage" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bald_2__bash" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("bald_2__bash_rank_22") then
			if value_name == "max_charge" then return 1 end
		end

		if caster:FindAbilityByName("bald_2__bash_rank_31") then
			if value_name == "bonus_ms" then return 1 end
			if value_name == "stun_immunity" then return 1 end
		end

		if caster:FindAbilityByName("bald_2__bash_rank_41") then
			if value_name == "bash_aoe" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bald_3__inner" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("bald_3__inner_rank_12") then
			if value_name == "buff_duration" then return 1 end
		end

		if caster:FindAbilityByName("bald_3__inner_rank_21") then
			if value_name == "hits" then return 1 end
			if value_name == "stack_duration" then return 1 end
		end
		
		if caster:FindAbilityByName("bald_3__inner_rank_41") then
			if value_name == "permanent_size" then return 1 end
			if value_name == "size_mult" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bald_4__clean" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("bald_4__clean_rank_11") then
			if value_name == "heal" then return 1 end
		end
		if caster:FindAbilityByName("bald_4__clean_rank_21") then
			if value_name == "duration" then return 1 end
		end
		if caster:FindAbilityByName("bald_4__clean_rank_31") then
			if value_name == "magical_damage" then return 1 end
		end
		if caster:FindAbilityByName("bald_4__clean_rank_41") then
			if value_name == "radius" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bald_5__spike" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "spike_radius" then return 1 end

		if caster:FindAbilityByName("bald_5__spike_rank_11") then
			if value_name == "damage" then return 1 end
		end

		if caster:FindAbilityByName("bald_5__spike_rank_21") then
			if value_name == "percent" then return 1 end
		end

		if caster:FindAbilityByName("bald_5__spike_rank_31") then
			if value_name == "charges" then return 1 end
		end

		if caster:FindAbilityByName("bald_5__spike_rank_32") then
			if value_name == "movespeed" then return 1 end
		end

		if caster:FindAbilityByName("bald_5__spike_rank_41") then
			if value_name == "absorb_skill" then return 1 end
		end
	end

	if ability:GetAbilityName() == "bald_u__vitality" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("bald_u__vitality_rank_12") then
			if value_name == "regen_in" then return 1 end
		end
		if caster:FindAbilityByName("bald_u__vitality_rank_21") then
			if value_name == "regen_out" then return 1 end
			if value_name == "delay" then return 1 end
		end
		if caster:FindAbilityByName("bald_u__vitality_rank_31") then
			if value_name == "lifesteal" then return 1 end
		end
	end

	return 0
end

function bald__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "bald_1__power" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "duration" then return 90 end
		if value_name == "hit_build" then return 5 end
		if value_name == "hit_build_refresh" then return 3 end
		if value_name == "bash_chance" then return 15 end
		if value_name == "bash_duration" then return 1 end
		if value_name == "bash_damage" then return 40 end
	end

	if ability:GetAbilityName() == "bald_2__bash" then
		if value_name == "AbilityManaCost" then
			if caster:FindAbilityByName("bald_2__bash_rank_11")
			or caster:HasModifier("bald_2_modifier_heap") then
				return 0
			end
			return 75 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then
			if caster:HasModifier("bald_2_modifier_heap") then
				if caster:FindAbilityByName("bald_2__bash_rank_21") then
					return 6
				end
				return 12
			end
			return 0.5
		end

		if value_name == "AbilityCastRange" then
			if caster:HasModifier("bald_2_modifier_heap") then
				return ability:GetSpecialValueFor("cast_range")
			end
			return 0
		end

		if value_name == "cast_range" then
			return (320 + (value_level * 5)) * caster:FindAbilityByName("bald__precache"):GetLevel() * 0.01
		end

		if value_name == "max_charge" then return 6 end
		if value_name == "bonus_ms" then return 30 end
		if value_name == "stun_immunity" then return 1 end
		if value_name == "bash_aoe" then return 175 end
	end

	if ability:GetAbilityName() == "bald_3__inner" then
		if value_name == "AbilityManaCost" then
			if ability:GetCurrentAbilityCharges() == 4 then
				return 150 * (1 + ((ability_level - 1) * 0.05))
			end
			return 0
		end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bald_3__inner_rank_11") then
				return 0
			end
			return 10
		end

		if value_name == "buff_duration" then return 25 end
		if value_name == "hits" then return 2 end
		if value_name == "stack_duration" then return 20 end
		if value_name == "permanent_size" then return 32 end
		if value_name == "size_mult" then return 2 end
	end

	if ability:GetAbilityName() == "bald_4__clean" then
		if value_name == "AbilityManaCost" then return 130 * (1 + ((ability_level - 1) * 0.05)) end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bald_4__clean_rank_21") then
				return 36
			end
			return 24
		end

		if value_name == "heal" then return 60 end
		if value_name == "duration" then return 12 end
		if value_name == "magical_damage" then return 150 end
		if value_name == "radius" then return 175 end
	end

	if ability:GetAbilityName() == "bald_5__spike" then
		if value_name == "AbilityManaCost" then
			if ability:GetCurrentAbilityCharges() == ability:GetSpecialValueFor("charges") then
				return 120 * (1 + ((ability_level - 1) * 0.05))
			end
			return 0
		end
		if value_name == "AbilityCooldown" then return 15 end

		if value_name == "AbilityCastRange" then
			if caster:FindAbilityByName("bald_5__spike_rank_12") then
				return 1200
			end
			return 400
		end

		if value_name == "spike_radius" then
			return 300 * caster:FindAbilityByName("bald__precache"):GetLevel() * 0.01
		end

		if value_name == "damage" then return 100 end
		if value_name == "percent" then return 75 end
		if value_name == "charges" then return 2 end
		if value_name == "movespeed" then return 50 end
		if value_name == "absorb_skill" then return 1 end
	end

	if ability:GetAbilityName() == "bald_u__vitality" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("bald_u__vitality_rank_11") then
				return 100
			end
			return 120
		end

		if value_name == "regen_in" then return 0.6 end
		if value_name == "regen_out" then return 1.75 end
		if value_name == "delay" then return 3 end
		if value_name == "lifesteal" then return 10 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------