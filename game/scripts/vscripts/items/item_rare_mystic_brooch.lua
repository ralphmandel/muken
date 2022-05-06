item_rare_mystic_brooch = class({})
LinkLuaModifier("item_rare_mystic_brooch_mod_passive", "items/item_rare_mystic_brooch_mod_passive", LUA_MODIFIER_MOTION_NONE)

function item_rare_mystic_brooch:CalcStatus(duration, caster, target)
	local time = duration
	local caster_int = nil
	local caster_mnd = nil
	local target_res = nil

	if caster ~= nil then
		caster_int = caster:FindModifierByName("_1_INT_modifier")
		caster_mnd = caster:FindModifierByName("_2_MND_modifier")
	end

	if target ~= nil then
		target_res = target:FindModifierByName("_2_RES_modifier")
	end

	if caster == nil then
		if target ~= nil then
			if target_res then time = time * (1 - target_res:GetStatus()) end
		end
	else
		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end
	end

	if time < 0 then time = 0 end
	return time
end

function item_rare_mystic_brooch:AddBonus(string, target, const, percent, time)
	local att = target:FindAbilityByName(string)
	if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
end

function item_rare_mystic_brooch:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_mystic_brooch:GetIntrinsicModifierName()
	return "item_rare_mystic_brooch_mod_passive"
end