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

	if ability:GetAbilityName() == "dasdingo_1__field" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("dasdingo_1__field_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_1__field_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_1__field_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_1__field_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_1__field_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_1__field_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_1__field_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_1__field_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_2__shield" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_2__shield_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_2__shield_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_2__shield_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_2__shield_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_2__shield_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_2__shield_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_2__shield_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_2__shield_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_3__leech" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityChannelTime" then return 1 end

		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("dasdingo_3__leech_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_3__leech_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_3__leech_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_3__leech_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_3__leech_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_3__leech_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_3__leech_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_3__leech_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_4__tribal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_4__tribal_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_4__tribal_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_4__tribal_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_4__tribal_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_4__tribal_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_5__fire" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_5__fire_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_5__fire_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_5__fire_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_5__fire_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_5__fire_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_5__fire_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_5__fire_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_5__fire_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_u__curse" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("dasdingo_u__curse_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_u__curse_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_u__curse_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_u__curse_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_u__curse_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_u__curse_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_u__curse_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_u__curse_rank_42") then
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

	if ability:GetAbilityName() == "dasdingo_1__field" then
		if value_name == "AbilityManaCost" then return 115 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 20 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 275 + (value_level * 10) end
	end

	if ability:GetAbilityName() == "dasdingo_2__shield" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_3__leech" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
    if value_name == "AbilityChannelTime" then return caster:FindAbilityByName("dasdingo__bind"):GetLevel() * 0.01 end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 450 + (value_level * 15) end
	end

	if ability:GetAbilityName() == "dasdingo_4__tribal" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_5__fire" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "dasdingo_u__curse" then
		if value_name == "AbilityManaCost" then return 100 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 10 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------