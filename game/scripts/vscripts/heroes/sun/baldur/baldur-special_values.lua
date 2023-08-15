baldur_special_values = class({})

function baldur_special_values:IsHidden() return true end
function baldur_special_values:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_special_values:OnCreated(kv)
end

function baldur_special_values:OnRefresh(kv)
end

function baldur_special_values:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_special_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}

	return funcs
end

function baldur_special_values:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
  --"AbilityCastRange"
  --"AbilityCharges"
  --"AbilityChargeRestoreTime"

	if ability:GetAbilityName() == "baldur_1__power" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCharges" then return 1 end
		if value_name == "AbilityChargeRestoreTime" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("baldur_1__power_rank_11") then
		end

    if caster:FindAbilityByName("baldur_1__power_rank_12") then
		end

		if caster:FindAbilityByName("baldur_1__power_rank_21") then
		end

    if caster:FindAbilityByName("baldur_1__power_rank_22") then
		end

		if caster:FindAbilityByName("baldur_1__power_rank_31") then
		end

    if caster:FindAbilityByName("baldur_1__power_rank_32") then
		end

		if caster:FindAbilityByName("baldur_1__power_rank_41") then
		end

    if caster:FindAbilityByName("baldur_1__power_rank_42") then
		end
	end

	if ability:GetAbilityName() == "baldur_2__dash" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
    if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "cast_range" then return 1 end

		if caster:FindAbilityByName("baldur_2__dash_rank_11") then
		end

    if caster:FindAbilityByName("baldur_2__dash_rank_12") then
		end

		if caster:FindAbilityByName("baldur_2__dash_rank_21") then
		end

    if caster:FindAbilityByName("baldur_2__dash_rank_22") then
		end

		if caster:FindAbilityByName("baldur_2__dash_rank_31") then
		end

    if caster:FindAbilityByName("baldur_2__dash_rank_32") then
		end

		if caster:FindAbilityByName("baldur_2__dash_rank_41") then
		end

    if caster:FindAbilityByName("baldur_2__dash_rank_42") then
		end
	end

	if ability:GetAbilityName() == "baldur_3__barrier" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "barrier_min" then return 1 end

		if caster:FindAbilityByName("baldur_3__barrier_rank_11") then
		end

    if caster:FindAbilityByName("baldur_3__barrier_rank_12") then
		end

		if caster:FindAbilityByName("baldur_3__barrier_rank_21") then
		end

    if caster:FindAbilityByName("baldur_3__barrier_rank_22") then
		end

		if caster:FindAbilityByName("baldur_3__barrier_rank_31") then
		end

    if caster:FindAbilityByName("baldur_3__barrier_rank_32") then
		end

		if caster:FindAbilityByName("baldur_3__barrier_rank_41") then
		end

    if caster:FindAbilityByName("baldur_3__barrier_rank_42") then
		end
	end

	if ability:GetAbilityName() == "baldur_4__rear" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end

		if caster:FindAbilityByName("baldur_4__rear_rank_11") then
		end

    if caster:FindAbilityByName("baldur_4__rear_rank_12") then
		end

		if caster:FindAbilityByName("baldur_4__rear_rank_21") then
		end

    if caster:FindAbilityByName("baldur_4__rear_rank_22") then
		end

		if caster:FindAbilityByName("baldur_4__rear_rank_31") then
		end

    if caster:FindAbilityByName("baldur_4__rear_rank_32") then
		end

		if caster:FindAbilityByName("baldur_4__rear_rank_41") then
		end

    if caster:FindAbilityByName("baldur_4__rear_rank_42") then
		end
	end

	if ability:GetAbilityName() == "baldur_5__fire" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "AbilityCastRange" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "range" then return 1 end

		if caster:FindAbilityByName("baldur_5__fire_rank_11") then
		end

    if caster:FindAbilityByName("baldur_5__fire_rank_12") then
		end

		if caster:FindAbilityByName("baldur_5__fire_rank_21") then
		end

    if caster:FindAbilityByName("baldur_5__fire_rank_22") then
		end

		if caster:FindAbilityByName("baldur_5__fire_rank_31") then
		end

    if caster:FindAbilityByName("baldur_5__fire_rank_32") then
		end

		if caster:FindAbilityByName("baldur_5__fire_rank_41") then
		end

    if caster:FindAbilityByName("baldur_5__fire_rank_42") then
		end
	end

	if ability:GetAbilityName() == "baldur_u__endurance" then
		if value_name == "AbilityManaCost" then return 1 end
		if value_name == "AbilityCooldown" then return 1 end
		if value_name == "rank" then return 1 end
		if value_name == "duration" then return 1 end

		if caster:FindAbilityByName("baldur_u__endurance_rank_11") then
		end

    if caster:FindAbilityByName("baldur_u__endurance_rank_12") then
		end

		if caster:FindAbilityByName("baldur_u__endurance_rank_21") then
		end

    if caster:FindAbilityByName("baldur_u__endurance_rank_22") then
		end

		if caster:FindAbilityByName("baldur_u__endurance_rank_31") then
		end

    if caster:FindAbilityByName("baldur_u__endurance_rank_32") then
		end

		if caster:FindAbilityByName("baldur_u__endurance_rank_41") then
		end

    if caster:FindAbilityByName("baldur_u__endurance_rank_42") then
		end
	end

	return 0
end

function baldur_special_values:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "baldur_1__power" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
    if value_name == "AbilityCharges" then return 4 end
		if value_name == "AbilityChargeRestoreTime" then return 3 end

		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "baldur_2__dash" then
		if value_name == "AbilityManaCost" then
      if ability:GetCurrentAbilityCharges() == BALDUR_CHARGING 
      or ability:GetCurrentAbilityCharges() == BALDUR_READY_NO_MANACOST then
        return 0
      end

      return 250 * (1 + ((ability_level - 1) * 0.05))
    end

		if value_name == "AbilityCooldown" then return 18 end

    if value_name == "AbilityCastRange" then
      if ability:GetCurrentAbilityCharges() == BALDUR_CHARGING then
        return ability:GetSpecialValueFor("cast_range")
      end

      return 0
    end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "cast_range" then return 450 + (value_level * 15) end
	end

	if ability:GetAbilityName() == "baldur_3__barrier" then
		if value_name == "AbilityManaCost" then return 450 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 30 end
		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "barrier_min" then return 750 + (value_level * 25) end
	end

	if ability:GetAbilityName() == "baldur_4__rear" then
		if value_name == "AbilityManaCost" then return 0 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 0 end
		if value_name == "rank" then return 6 + (value_level * 1) end
	end

	if ability:GetAbilityName() == "baldur_5__fire" then
		if value_name == "AbilityManaCost" then return 180 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 16 end
    if value_name == "AbilityCastRange" then return ability:GetSpecialValueFor("range") - 150 end

		if value_name == "rank" then return 6 + (value_level * 1) end
		if value_name == "range" then return 800 + (value_level * 40) end
	end

	if ability:GetAbilityName() == "baldur_u__endurance" then
		if value_name == "AbilityManaCost" then return 800 * (1 + ((ability_level - 1) * 0.05)) end
		if value_name == "AbilityCooldown" then return 60 end
		if value_name == "rank" then return 9 + (value_level * 1) end
		if value_name == "duration" then return 30 + (value_level * 1) end
	end

	return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------