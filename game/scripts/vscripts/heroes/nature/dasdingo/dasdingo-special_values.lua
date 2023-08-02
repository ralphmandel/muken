dasdingo_special_values = class({})

function dasdingo_special_values:IsHidden() return true end
function dasdingo_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_special_values:OnCreated(kv)
end

function dasdingo_special_values:OnRefresh(kv)
end

function dasdingo_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function dasdingo_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "dasdingo_1__field" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

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

	if ability:GetAbilityName() == "dasdingo_2__tree" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("dasdingo_2__tree_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_2__tree_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_2__tree_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_2__tree_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_2__tree_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_2__tree_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_2__tree_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_2__tree_rank_42") then
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
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "atk_range" then return 1 end

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

	if ability:GetAbilityName() == "dasdingo_5__hex" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("dasdingo_5__hex_rank_11") then
		end

    if caster:FindAbilityByName("dasdingo_5__hex_rank_12") then
		end

		if caster:FindAbilityByName("dasdingo_5__hex_rank_21") then
		end

    if caster:FindAbilityByName("dasdingo_5__hex_rank_22") then
		end

		if caster:FindAbilityByName("dasdingo_5__hex_rank_31") then
		end

    if caster:FindAbilityByName("dasdingo_5__hex_rank_32") then
		end

		if caster:FindAbilityByName("dasdingo_5__hex_rank_41") then
		end

    if caster:FindAbilityByName("dasdingo_5__hex_rank_42") then
		end
	end

	if ability:GetAbilityName() == "dasdingo_u__curse" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "damage" then return 1 end

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

function dasdingo_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "dasdingo_1__field" then
		if value_name == "AbilityManaCost" then return 280 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 15 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.3) end
	end

	if ability:GetAbilityName() == "dasdingo_2__tree" then
		if value_name == "AbilityManaCost" then return 320 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 4 end
    if value_name == "AbilityChargeRestoreTime" then return 60 end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "radius" then return 700 + (value_level * 20) end
	end

	if ability:GetAbilityName() == "dasdingo_3__leech" then
		if value_name == "AbilityManaCost" then return 300 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 30 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
    if value_name == "AbilityChannelTime" then return caster:FindAbilityByName("dasdingo__bind"):GetLevel() * 0.01 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 400 + (value_level * 20) end
	end

	if ability:GetAbilityName() == "dasdingo_4__tribal" then
		if value_name == "AbilityManaCost" then return 260 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 24 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "atk_range" then return 600 + (value_level * 15) end
	end

	if ability:GetAbilityName() == "dasdingo_5__hex" then
		if value_name == "AbilityManaCost" then return 240 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 18 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 3 + (value_level * 0.1) end
	end

	if ability:GetAbilityName() == "dasdingo_u__curse" then
		if value_name == "AbilityManaCost" then return 500 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 100 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("cast_range") end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "damage" then return 200 + (value_level * 10) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------