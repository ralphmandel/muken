item_rare_arcane_hammer = class({})
LinkLuaModifier("item_rare_arcane_hammer_mod_passive", "items/item_rare_arcane_hammer_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_arcane_hammer_mod_silence", "items/item_rare_arcane_hammer_mod_silence", LUA_MODIFIER_MOTION_NONE)

function item_rare_arcane_hammer:CalcStatus(duration, caster, target)
    local time = duration
	local base_stats_caster = nil
	local base_stats_target = nil

    if caster ~= nil then
		base_stats_caster = caster:FindAbilityByName("base_stats")
	end

	if target ~= nil then
		base_stats_target = target:FindAbilityByName("base_stats")
	end

	if caster == nil then
		if target ~= nil then
			if base_stats_target then
				local value = base_stats_target.stat_total["RES"] * 0.7
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - (calc * 0.01))
			end
		end
	else
		if target == nil then
			if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if base_stats_caster and base_stats_target then
					local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + (calc * 0.01))
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - (calc * 0.01))
					end
				end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function item_rare_arcane_hammer:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_arcane_hammer:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_arcane_hammer:GetIntrinsicModifierName()
	return "item_rare_arcane_hammer_mod_passive"
end

function item_rare_arcane_hammer:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	if IsServer() then target:EmitSound("Arcane_Hammer.Start") end

	target:AddNewModifier(caster, self, "item_rare_arcane_hammer_mod_silence", {
		duration = self:CalcStatus(duration, caster, target)
	})
end

function item_rare_arcane_hammer:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()

	local result = UnitFilter(
		hTarget,	-- Target Filter
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
		0,	-- Unit Flag
		caster:GetTeamNumber()	-- Team reference
	)
	
	if result ~= UF_SUCCESS then
		return result
	end

	return UF_SUCCESS
end