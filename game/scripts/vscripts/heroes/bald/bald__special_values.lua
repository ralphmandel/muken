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

		if ability:GetRank(21) then
			if value_name == "duration" then return 1 end
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability:GetAbilityName() == "bald_2__bash" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "cast_range" then return 1 end

		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(22) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability:GetAbilityName() == "bald_3__inner" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(12) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability:GetAbilityName() == "bald_4__clean" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability:GetAbilityName() == "bald_5__spike" then
		if ability:GetRank(11) then
		end
		if ability:GetRank(12) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
		end
		if ability:GetRank(32) then
		end
		if ability:GetRank(41) then
		end
	end

	if ability:GetAbilityName() == "bald_u__vitality" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end

		if ability:GetRank(11) then
		end
		if ability:GetRank(12) then
		end
		if ability:GetRank(21) then
		end
		if ability:GetRank(31) then
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
	end

	if ability:GetAbilityName() == "bald_2__bash" then
		if value_name == "AbilityManaCost" then
			if caster:HasModifier("bald_2_modifier_heap") then
				return 0
			end
			return 75 * (1 + ((ability_level - 1) * 0.05))
		end

		if value_name == "AbilityCooldown" then
			if caster:HasModifier("bald_2_modifier_heap") then
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
	end

	if ability:GetAbilityName() == "bald_3__inner" then
	end

	if ability:GetAbilityName() == "bald_4__clean" then
	end

	if ability:GetAbilityName() == "bald_5__spike" then
	end

	if ability:GetAbilityName() == "bald_u__vitality" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 120 end
	end

	return 0
end

-- UTILS -----------------------------------------------------------


-- EFFECTS -----------------------------------------------------------