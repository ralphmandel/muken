icebreaker__special_values = class({})

function icebreaker__special_values:IsHidden() return true end
function icebreaker__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__special_values:OnCreated(kv)
end

function icebreaker__special_values:OnRefresh(kv)
end

function icebreaker__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function icebreaker__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_11") then
			if value_name == "stack_duration" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_21") then
			if value_name == "damage" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_31") then
			if value_name == "special_blink_chance" then return 1 end
		end

		if caster:FindAbilityByName("icebreaker_1__frost_rank_41") then
			if value_name == "special_instant_duration" then return 1 end
		end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_21") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_31") then
		end

		if caster:FindAbilityByName("icebreaker_2__wave_rank_41") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_3__shard" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_21") then
		end

		if caster:FindAbilityByName("icebreaker_3__shard_rank_31") then
		end
		
		if caster:FindAbilityByName("icebreaker_3__shard_rank_41") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_4__mirror" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_21") then
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_31") then
		end

		if caster:FindAbilityByName("icebreaker_4__mirror_rank_41") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_5__shivas" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_21") then
		end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_31") then
		end

		if caster:FindAbilityByName("icebreaker_5__shivas_rank_41") then
		end
	end

	if ability:GetAbilityName() == "icebreaker_u__blink" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_11") then
		end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_21") then
		end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_31") then
		end

		if caster:FindAbilityByName("icebreaker_u__blink_rank_41") then
		end
	end

	return 0
end

function icebreaker__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "icebreaker_1__frost" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end

		if value_name == "stack_duration" then return 6 end
		if value_name == "damage" then return 60 end
		if value_name == "special_blink_chance" then return 15 end
		if value_name == "special_instant_duration" then return 0.2 end
	end

	if ability:GetAbilityName() == "icebreaker_2__wave" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_3__shard" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_4__mirror" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_5__shivas" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "icebreaker_u__blink" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------