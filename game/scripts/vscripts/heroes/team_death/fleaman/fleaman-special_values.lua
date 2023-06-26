fleaman_special_values = class({})

function fleaman_special_values:IsHidden() return true end
function fleaman_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_special_values:OnCreated(kv)
end

function fleaman_special_values:OnRefresh(kv)
end

function fleaman_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function fleaman_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "fleaman_1__precision" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("fleaman_1__precision_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_1__precision_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_1__precision_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_1__precision_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_1__precision_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_1__precision_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_1__precision_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_1__precision_rank_42") then
		end
	end

	if ability:GetAbilityName() == "fleaman_2__speed" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("fleaman_2__speed_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_2__speed_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_2__speed_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_2__speed_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_2__speed_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_2__speed_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_2__speed_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_2__speed_rank_42") then
		end
	end

	if ability:GetAbilityName() == "fleaman_3__jump" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "distance" then return 1 end

		if caster:FindAbilityByName("fleaman_3__jump_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_3__jump_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_3__jump_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_3__jump_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_3__jump_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_3__jump_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_3__jump_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_3__jump_rank_42") then
		end
	end

	if ability:GetAbilityName() == "fleaman_4__strip" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("fleaman_4__strip_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_4__strip_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_4__strip_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_4__strip_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_4__strip_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_4__strip_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_4__strip_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_4__strip_rank_42") then
		end
	end

	if ability:GetAbilityName() == "fleaman_5__steal" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("fleaman_5__steal_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_5__steal_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_5__steal_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_5__steal_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_5__steal_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_5__steal_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_5__steal_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_5__steal_rank_42") then
		end
	end

	if ability:GetAbilityName() == "fleaman_u__smoke" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("fleaman_u__smoke_rank_11") then
		end

    if caster:FindAbilityByName("fleaman_u__smoke_rank_12") then
		end

		if caster:FindAbilityByName("fleaman_u__smoke_rank_21") then
		end

    if caster:FindAbilityByName("fleaman_u__smoke_rank_22") then
		end

		if caster:FindAbilityByName("fleaman_u__smoke_rank_31") then
		end

    if caster:FindAbilityByName("fleaman_u__smoke_rank_32") then
		end

		if caster:FindAbilityByName("fleaman_u__smoke_rank_41") then
		end

    if caster:FindAbilityByName("fleaman_u__smoke_rank_42") then
		end
	end

	return 0
end

function fleaman_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "fleaman_1__precision" then
		if value_name == "AbilityManaCost" then return 200 * (1 + ((ability_level - 1) * 0.05)) end
    if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCharges" then return 3 end
    if value_name == "AbilityChargeRestoreTime" then return 25 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "duration" then return 12 + (value_level * 0.3) end
	end

	if ability:GetAbilityName() == "fleaman_2__speed" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "fleaman_3__jump" then
		if value_name == "AbilityManaCost" then return 250 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 20 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "distance" then return 750 + (value_level * 25) end
	end

	if ability:GetAbilityName() == "fleaman_4__strip" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "fleaman_5__steal" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "fleaman_u__smoke" then
		if value_name == "AbilityManaCost" then return 350 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 40 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("radius") - 50 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "radius" then return 500 + (value_level * 10) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------