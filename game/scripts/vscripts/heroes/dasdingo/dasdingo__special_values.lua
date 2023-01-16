dasdingo__special_values = class({})

function dasdingo__special_values:IsHidden() return true end
function dasdingo__special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo__special_values:OnCreated(kv)
end

function dasdingo__special_values:OnRefresh(kv)
end

function dasdingo__special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo__special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function dasdingo__special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "dasdingo_1__heal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_1__heal_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_1__heal_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_1__heal_rank_31") then
		end

		if caster:FindAbilityByName("dasdingo_1__heal_rank_41") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_2__aura" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_2__aura_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_2__aura_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_2__aura_rank_31") then
		end

		if caster:FindAbilityByName("dasdingo_2__aura_rank_41") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_3__fire" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_3__fire_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_3__fire_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_3__fire_rank_31") then
		end
		
		if caster:FindAbilityByName("dasdingo_3__fire_rank_41") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_4__tribal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_31") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_41") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_5__lash" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_5__lash_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_5__lash_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_5__lash_rank_31") then
		end

		if caster:FindAbilityByName("dasdingo_5__lash_rank_41") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_u__maledict" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_u__maledict_rank_11") then
		end

		if caster:FindAbilityByName("dasdingo_u__maledict_rank_21") then
		end

		if caster:FindAbilityByName("dasdingo_u__maledict_rank_31") then
		end

		if caster:FindAbilityByName("dasdingo_u__maledict_rank_41") then
		end
	end

	return 0
end

function dasdingo__special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "dasdingo_1__heal" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_2__aura" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_3__fire" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_4__tribal" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_5__lash" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_u__maledict" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------