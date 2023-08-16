hunter_special_values = class({})

function hunter_special_values:IsHidden() return true end
function hunter_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_special_values:OnCreated(kv)
end

function hunter_special_values:OnRefresh(kv)
end

function hunter_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function hunter_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "hunter_1__shot" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "damage" then return 1 end
		if value_name == "cd_mult_tooltip" then return 1 end

		if caster:FindAbilityByName("hunter_1__shot_rank_11") then
		end

    if caster:FindAbilityByName("hunter_1__shot_rank_12") then
		end

		if caster:FindAbilityByName("hunter_1__shot_rank_21") then
		end

    if caster:FindAbilityByName("hunter_1__shot_rank_22") then
		end

		if caster:FindAbilityByName("hunter_1__shot_rank_31") then
		end

    if caster:FindAbilityByName("hunter_1__shot_rank_32") then
		end

		if caster:FindAbilityByName("hunter_1__shot_rank_41") then
		end

    if caster:FindAbilityByName("hunter_1__shot_rank_42") then
		end
	end

  if ability:GetAbilityName() == "hunter_2__aim" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "lck" then return 1 end

		if caster:FindAbilityByName("hunter_2__aim_rank_11") then
		end

    if caster:FindAbilityByName("hunter_2__aim_rank_12") then
		end

		if caster:FindAbilityByName("hunter_2__aim_rank_21") then
		end

    if caster:FindAbilityByName("hunter_2__aim_rank_22") then
		end

		if caster:FindAbilityByName("hunter_2__aim_rank_31") then
		end

    if caster:FindAbilityByName("hunter_2__aim_rank_32") then
		end

		if caster:FindAbilityByName("hunter_2__aim_rank_41") then
		end

    if caster:FindAbilityByName("hunter_2__aim_rank_42") then
		end
	end

	if ability:GetAbilityName() == "hunter_3__radar" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
    if value_name == "radius" then return 1 end

		if caster:FindAbilityByName("hunter_3__radar_rank_11") then
		end

    if caster:FindAbilityByName("hunter_3__radar_rank_12") then
		end

		if caster:FindAbilityByName("hunter_3__radar_rank_21") then
		end

    if caster:FindAbilityByName("hunter_3__radar_rank_22") then
		end

		if caster:FindAbilityByName("hunter_3__radar_rank_31") then
		end

    if caster:FindAbilityByName("hunter_3__radar_rank_32") then
		end

		if caster:FindAbilityByName("hunter_3__radar_rank_41") then
		end

    if caster:FindAbilityByName("hunter_3__radar_rank_42") then
		end
	end

	if ability:GetAbilityName() == "hunter_4__bandage" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("hunter_4__bandage_rank_11") then
		end

    if caster:FindAbilityByName("hunter_4__bandage_rank_12") then
		end

		if caster:FindAbilityByName("hunter_4__bandage_rank_21") then
		end

    if caster:FindAbilityByName("hunter_4__bandage_rank_22") then
		end

		if caster:FindAbilityByName("hunter_4__bandage_rank_31") then
		end

    if caster:FindAbilityByName("hunter_4__bandage_rank_32") then
		end

		if caster:FindAbilityByName("hunter_4__bandage_rank_41") then
		end

    if caster:FindAbilityByName("hunter_4__bandage_rank_42") then
		end
	end

	if ability:GetAbilityName() == "hunter_5__trap" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
    if value_name == "AbilityCharges" then return 1 end
    if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "lifetime" then return 1 end

		if caster:FindAbilityByName("hunter_5__trap_rank_11") then
		end

    if caster:FindAbilityByName("hunter_5__trap_rank_12") then
		end

		if caster:FindAbilityByName("hunter_5__trap_rank_21") then
		end

    if caster:FindAbilityByName("hunter_5__trap_rank_22") then
		end

		if caster:FindAbilityByName("hunter_5__trap_rank_31") then
		end

    if caster:FindAbilityByName("hunter_5__trap_rank_32") then
		end

		if caster:FindAbilityByName("hunter_5__trap_rank_41") then
		end

    if caster:FindAbilityByName("hunter_5__trap_rank_42") then
		end
	end

  if ability:GetAbilityName() == "hunter_u__camouflage" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("hunter_u__camouflage_rank_11") then
		end

    if caster:FindAbilityByName("hunter_u__camouflage_rank_12") then
		end

		if caster:FindAbilityByName("hunter_u__camouflage_rank_21") then
		end

    if caster:FindAbilityByName("hunter_u__camouflage_rank_22") then
		end

		if caster:FindAbilityByName("hunter_u__camouflage_rank_31") then
		end

    if caster:FindAbilityByName("hunter_u__camouflage_rank_32") then
		end

		if caster:FindAbilityByName("hunter_u__camouflage_rank_41") then
		end

    if caster:FindAbilityByName("hunter_u__camouflage_rank_42") then
		end
	end

	return 0
end

function hunter_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "hunter_1__shot" then
		if value_name == "AbilityManaCost" then return 400 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 20 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "damage" then return 250 + (value_level * 5) end
		if value_name == "cd_mult_tooltip" then return ability:GetCooldown(ability:GetLevel()) * ability:GetSpecialValueFor("cd_mult") end
	end

  if ability:GetAbilityName() == "hunter_2__aim" then
		if value_name == "AbilityManaCost" then return 320 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 30 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "lck" then return 15 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "hunter_3__radar" then
		if value_name == "AbilityManaCost" then return 275 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 25 end
		if value_name == "rank" then return 6 + (value_level * 1) end
    if value_name == "radius" then return 600 + (value_level * 20) end
	end

	if ability:GetAbilityName() == "hunter_4__bandage" then
		if value_name == "AbilityManaCost" then return 0 end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "AbilityCastRange" then return 150 end
    if value_name == "AbilityCharges" then return 5 end
    if value_name == "AbilityChargeRestoreTime" then return 45 end

		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "hunter_5__trap" then
		if value_name == "AbilityManaCost" then return 250 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCastRange" then return 100 end
    if value_name == "AbilityCharges" then return 3 end
    if value_name == "AbilityChargeRestoreTime" then return 30 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "lifetime" then return 240 + (value_level * 6) end
	end

  if ability:GetAbilityName() == "hunter_u__camouflage" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 3 end
		if value_name == "rank" then return 9 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------