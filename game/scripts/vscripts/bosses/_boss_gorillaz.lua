_boss_gorillaz = class({})
LinkLuaModifier("_boss_gorillaz_modifier_passive", "bosses/_boss_gorillaz_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mk_gorillaz_buff", "bosses/mk_gorillaz_buff", LUA_MODIFIER_MOTION_NONE)

function _boss_gorillaz:CalcStatus(duration, caster, target)
	if caster == nil or target == nil then return duration end
	if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
	local base_stats = caster:FindAbilityByName("base_stats")

	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
	else
		if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
		duration = duration * (1 - target:GetStatusResistance())
	end
	
	return duration
end

function _boss_gorillaz:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function _boss_gorillaz:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function _boss_gorillaz:GetIntrinsicModifierName()
	return "_boss_gorillaz_modifier_passive"
end