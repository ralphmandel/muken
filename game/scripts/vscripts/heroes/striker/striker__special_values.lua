striker__special_values = class({})

function striker__special_values:IsHidden() return true end
function striker__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function striker__special_values:OnCreated(kv)
end

function striker__special_values:OnRefresh(kv)
end

function striker__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function striker__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "striker_1__blow" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end

		if caster:FindAbilityByName("striker_1__blow_rank_11") then
			if value_name == "atk_range" then return 1 end
		end

		if caster:FindAbilityByName("striker_1__blow_rank_12") then
			if value_name == "knockback_chance" then return 1 end
		end

		if caster:FindAbilityByName("striker_1__blow_rank_21") then
			if value_name == "chance" then return 1 end
			if value_name == "hits" then return 1 end
		end

		if caster:FindAbilityByName("striker_1__blow_rank_32") then
			if value_name == "special_shake_damage" then return 1 end
			if value_name == "special_shake_radius" then return 1 end
		end

		if caster:FindAbilityByName("striker_1__blow_rank_41") then
			if value_name == "special_copy_number" then return 1 end
			if value_name == "special_copy_range" then return 1 end
		end
	end

	if ability:GetAbilityName() == "striker_2__shield" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("striker_2__shield_rank_11") then
			if value_name == "duration" then return 1 end
		end

		if caster:FindAbilityByName("striker_2__shield_rank_21") then
			if value_name == "hits" then return 1 end
			if value_name == "special_return" then return 1 end
		end

		if caster:FindAbilityByName("striker_2__shield_rank_31") then
			if value_name == "special_burn_radius" then return 1 end
			if value_name == "special_burn_damage" then return 1 end
		end

		if caster:FindAbilityByName("striker_2__shield_rank_41") then
			if value_name == "special_spell_immunity" then return 1 end
		end
	end

	if ability:GetAbilityName() == "striker_3__portal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("striker_3__portal_rank_11") then
		end

		if caster:FindAbilityByName("striker_3__portal_rank_21") then
		end

		if caster:FindAbilityByName("striker_3__portal_rank_31") then
		end
		
		if caster:FindAbilityByName("striker_3__portal_rank_41") then
		end
	end

	if ability:GetAbilityName() == "striker_4__hammer" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("striker_4__hammer_rank_11") then
		end

		if caster:FindAbilityByName("striker_4__hammer_rank_21") then
		end

		if caster:FindAbilityByName("striker_4__hammer_rank_31") then
		end

		if caster:FindAbilityByName("striker_4__hammer_rank_41") then
		end
	end

	if ability:GetAbilityName() == "striker_5__sof" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("striker_5__sof_rank_11") then
		end

		if caster:FindAbilityByName("striker_5__sof_rank_21") then
		end

		if caster:FindAbilityByName("striker_5__sof_rank_31") then
		end

		if caster:FindAbilityByName("striker_5__sof_rank_41") then
		end
	end

	if ability:GetAbilityName() == "striker_u__auto" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if caster:FindAbilityByName("striker_u__auto_rank_11") then
		end

		if caster:FindAbilityByName("striker_u__auto_rank_21") then
		end

		if caster:FindAbilityByName("striker_u__auto_rank_31") then
		end

		if caster:FindAbilityByName("striker_u__auto_rank_41") then
		end
	end

	return 0
end

function striker__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "striker_1__blow" then
		if value_name == "AbilityManaCost" then
			if caster:FindAbilityByName("striker_1__blow_rank_31") then
				return 100
			end
			return 0 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then
			if caster:FindAbilityByName("striker_1__blow_rank_31") then
				return 12
			end
			return 0
		end

		if value_name == "AbilityCastRange" then
			if caster:FindAbilityByName("striker_1__blow_rank_31") then
				return 450
			end
			return 0
		end

		if value_name == "atk_range" then return 80 end
		if value_name == "knockback_chance" then return 100 end
		if value_name == "chance" then return 10 end
		if value_name == "hits" then return 7 end
		if value_name == "special_shake_damage" then return 150 end
		if value_name == "special_shake_radius" then return 300 end
		if value_name == "special_copy_number" then return 2 end
		if value_name == "special_copy_range" then return 500 end
	end

	if ability:GetAbilityName() == "striker_2__shield" then
		if value_name == "AbilityManaCost" then return 120 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 - (value_level * 0.3) end

		if value_name == "duration" then return 15 end
		if value_name == "hits" then return 6 end
		if value_name == "special_return" then return 100 end
		if value_name == "special_burn_radius" then return 400 end
		if value_name == "special_burn_damage" then return 20 end
		if value_name == "special_spell_immunity" then return 1 end
	end

	if ability:GetAbilityName() == "striker_3__portal" then
		if value_name == "AbilityManaCost" then return 90 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 - (value_level * 0.2) end
	end

	if ability:GetAbilityName() == "striker_4__hammer" then
		if value_name == "AbilityManaCost" then return 150 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 25 - (value_level * 0.5) end
	end

	if ability:GetAbilityName() == "striker_5__sof" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 35 - (value_level * 0.7) end
	end

	if ability:GetAbilityName() == "striker_u__auto" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------